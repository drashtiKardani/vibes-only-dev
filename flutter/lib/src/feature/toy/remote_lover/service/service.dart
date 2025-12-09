import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/constants.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/nodes/commands.dart';

import '../../../../service/logger.dart';
import '../errors.dart';
import 'nodes/state.dart';

class RemoteLoverService {
  RemoteLoverService();

  RemoteLoverConnection? _activeConnection;

  RemoteLoverConnection? get activeConnection {
    if (_activeConnection == null) {
      Logger.remoteLover.i('You requested for `activeConnection`, but there is none.');
    }
    return _activeConnection;
  }

  Future<RemoteLoverInitiatedConnection> initiateConnection({String? toyName}) async {
    String code;
    DatabaseReference ref;
    DataSnapshot snapshot;
    do {
      code = _generateCode();
      ref = FirebaseDatabase.instance.ref('${Node.root}/$code');
      snapshot = await ref.get();
      Logger.remoteLover.i('Trying to create connection with code: $code');
    } while (snapshot.exists);

    final stateNode = StateNode(connectionRoot: ref);
    await stateNode.setToInitiated();
    stateNode.stream
        .firstWhere((state) => state == ConnectionState.ended)
        .then((_) => Future.delayed(const Duration(seconds: 10), () => ref.remove()));
    ref.child(Node.toyName).set(toyName);
    ref.child(Node.initiatedAt).set(DateTime.now().toString());
    ref.child(Node.initiatedByUid).set(FirebaseAuth.instance.currentUser?.uid);
    ref.child(Node.initiatedByDisplayName).set(FirebaseAuth.instance.currentUser?.displayName);
    return RemoteLoverInitiatedConnection(service: this, stateNode: stateNode, code: code);
  }

  Future<RemoteLoverConnection> joinConnection({required String code}) async {
    final connectionRoot = FirebaseDatabase.instance.ref('${Node.root}/$code');
    final stateNode = StateNode(connectionRoot: connectionRoot);

    final state = await stateNode.read();
    switch (state) {
      case ConnectionState.notExists:
      case ConnectionState.ended:
        return Future.error(RemoteLoverError.connectionNotFound);
      case ConnectionState.joining:
        return Future.error(RemoteLoverError.connectionIsBeingJoinedByAnother);
      case ConnectionState.connected:
        return Future.error(RemoteLoverError.connectionAlreadyOccupied);
      case ConnectionState.initiated:
        await stateNode.setToJoining();
        connectionRoot.child(Node.joinedAt).set(DateTime.now().toString());
        connectionRoot.child(Node.joinedByUid).set(FirebaseAuth.instance.currentUser?.uid);
        connectionRoot.child(Node.joinedByDisplayName).set(FirebaseAuth.instance.currentUser?.displayName);
        return stateNode.stream
            .firstWhere((state) => state == ConnectionState.connected || state == ConnectionState.initiated)
            .then((state) async {
          if (state == ConnectionState.initiated) {
            return Future.error(RemoteLoverError.connectionRejected);
          } else {
            final toyName = (await stateNode.parent.child(Node.toyName).get()).value as String;
            _activeConnection = RemoteLoverConnection(connectionRoot: connectionRoot, toyName: toyName);
            return Future.value(_activeConnection);
          }
        });
    }
  }

  void endConnection() {
    _activeConnection?.close();
    _activeConnection = null;
  }

  String _generateCode() {
    return (Random().nextInt(90000) + 10000).toString();
  }

  Future<RemoteLoverConnection> accept({required String code, required StateNode stateNode}) async {
    await stateNode.setToConnected();
    stateNode.parent.child(Node.connectionEstablishedAt).set(DateTime.now().toString());
    final toyName = (await stateNode.parent.child(Node.toyName).get()).value as String;
    _activeConnection = RemoteLoverConnection(connectionRoot: stateNode.parent, toyName: toyName);
    return _activeConnection!;
  }

  Future<void> reject({required StateNode stateNode}) async {
    await stateNode.setToInitiated();
    stateNode.parent.child(Node.joinedAt).remove();
    stateNode.parent.child(Node.joinedByUid).remove();
    stateNode.parent.child(Node.joinedByDisplayName).remove();
  }
}

class RemoteLoverInitiatedConnection {
  final RemoteLoverService service;
  final StateNode stateNode;
  final String code;
  RemoteLoverInitiatedConnection({required this.service, required this.stateNode, required this.code});

  Future<RemoteLoverJoinRequest> waitForJoinRequest() {
    return stateNode.stream.firstWhere((state) => state == ConnectionState.joining).then((event) {
      return RemoteLoverJoinRequest(
        service: service,
        stateNode: stateNode,
        code: code,
      );
    });
  }

  Future<void> end() async {
    await stateNode.setToEnded();
  }
}

/// Result of initiating a connection
/// Using this first (initiating) party can accept or reject incoming join requests
class RemoteLoverJoinRequest {
  final RemoteLoverService service;
  final StateNode stateNode;
  final String code;
  RemoteLoverJoinRequest({required this.service, required this.stateNode, required this.code});

  Future<RemoteLoverConnection> accept() async {
    return service.accept(stateNode: stateNode, code: code);
  }

  Future<void> reject() async {
    await service.reject(stateNode: stateNode);
  }
}

/// Encapsulate an established connection between the two parties
class RemoteLoverConnection {
  final StateNode _stateNode;
  final RemoteLoverCommands _remoteLoverCommands;
  final String _toyName;

  StateNode get state => _stateNode;
  RemoteLoverCommands get commands => _remoteLoverCommands;
  String get toyName => _toyName;

  RemoteLoverConnection({required DatabaseReference connectionRoot, required String toyName})
      : _stateNode = StateNode(connectionRoot: connectionRoot),
        _remoteLoverCommands = RemoteLoverCommands(connectionRoot: connectionRoot),
        _toyName = toyName;

  void close() {
    _stateNode.setToEnded();
  }
}
