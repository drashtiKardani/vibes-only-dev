import 'package:firebase_database/firebase_database.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/constants.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/utility.dart';

enum ConnectionState {
  /// This node does not exist
  notExists,

  /// First party has just initiated a connection, or has rejected a joining request
  initiated,

  /// Second party is requesting to join the initiated connection
  joining,

  /// First party has accepted the joining request; Parties are ready to send/receive messages
  connected,

  /// One of the two parties has ended the connection; Connection should be cleared up from database
  ended,
}

class StateNode {
  final DatabaseReference _parent;
  final DatabaseReference _ref;
  StateNode({required DatabaseReference connectionRoot})
      : _parent = connectionRoot,
        _ref = connectionRoot.child(Node.state);

  DatabaseReference get parent => _parent;

  Stream<ConnectionState> get stream => _ref.onValue.map(
        (event) {
          return _castToConnectionState(event.snapshot);
        },
      );

  Future<ConnectionState> read() async {
    return _castToConnectionState(await _ref.get());
  }

  Future<void> setToInitiated() async {
    await _ref.set(ConnectionState.initiated.name);
  }

  Future<void> setToJoining() async {
    await _ref.set(ConnectionState.joining.name);
  }

  Future<void> setToConnected() async {
    await _ref.set(ConnectionState.connected.name);
  }

  Future<void> setToEnded() async {
    await _ref.set(ConnectionState.ended.name);
  }

  ConnectionState _castToConnectionState(DataSnapshot snapshot) {
    return ConnectionState.values.firstWhere(
      (element) => element.name == CastingUtility.tryCast<String>(snapshot.value),
      orElse: () => ConnectionState.notExists,
    );
  }
}
