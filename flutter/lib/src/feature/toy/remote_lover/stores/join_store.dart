import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/errors.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';

import '../../../../service/logger.dart';

part 'join_store.g.dart';

/// Represents the joining partner, when tries to join a [RemoteLoverConnection]
/// This party would remotely control the other party's toy
// ignore: library_private_types_in_public_api
class JoinStore = _JoinStore with _$JoinStore;

abstract class _JoinStore with Store {
  @observable
  JoinState state = JoinState.idle;

  @observable
  RemoteLoverError? error;

  @action
  Future<void> join({required String code}) async {
    state = JoinState.joining;
    try {
      await GetIt.I<RemoteLoverService>().joinConnection(code: code).then((connection) => state = JoinState.connected);
    } catch (error) {
      if (error is RemoteLoverError) {
        this.error = error;
      } else {
        Logger.remoteLover.e(error.toString());
      }
      state = JoinState.idle;
    }
  }
}

enum JoinState {
  idle,
  joining,
  connected,
}
