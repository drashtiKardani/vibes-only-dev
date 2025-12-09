import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/errors.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/utility.dart';

import '../../../../service/logger.dart';

part 'initiate_store.g.dart';

/// Represents the initiating partner, when tries to join a [RemoteLoverConnection]
/// This party has the toy in hand, the toy which will be controlled by the other (remote) party
// ignore: library_private_types_in_public_api
class InitiateStore = _InitiateStore with _$InitiateStore;

abstract class _InitiateStore with Store, CastingUtility {
  @observable
  InitiateState state = InitiateState.idle;

  @observable
  RemoteLoverError? error;

  RemoteLoverInitiatedConnection? initiatedConnection;
  RemoteLoverJoinRequest? request;

  @action
  Future<void> initiate({required String? toyName}) async {
    await initiatedConnection?.end(); // End any previously initiated connection, e.g. when re-initiating after 10min

    initiatedConnection = await GetIt.I<RemoteLoverService>().initiateConnection(toyName: toyName);
    state = InitiateState.initiated;

    _waitForJoinRequest();
  }

  void _waitForJoinRequest() {
    initiatedConnection!.waitForJoinRequest().then((request) {
      this.request = request;
      state = InitiateState.joining;
    });
  }

  @action
  void setAcceptStatus(bool accepted) {
    state = accepted ? InitiateState.connected : InitiateState.initiated;
    if (!accepted) {
      _waitForJoinRequest();
    }
  }

  String get code {
    if (initiatedConnection == null) {
      Logger.remoteLover.e('Connection is not initiated');
      return '';
    } else {
      return initiatedConnection!.code;
    }
  }

  /// Call when you are done using this class (e.g. in [State.dispose])
  /// Otherwise you may leak database subscription
  void dispose() {
    if (state != InitiateState.connected) {
      initiatedConnection?.end();
    }
  }
}

enum InitiateState {
  idle,
  initiated,
  joining,
  connected,
}
