import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';

part 'accept_store.g.dart';

// ignore: library_private_types_in_public_api
class AcceptStore = _AcceptStore with _$AcceptStore;

abstract class _AcceptStore with Store {
  @observable
  AcceptState state = AcceptState.idle;

  final RemoteLoverJoinRequest request;
  RemoteLoverConnection? connection;

  _AcceptStore({required this.request});

  Future<void> accept() async {
    state = AcceptState.accepting;
    connection = await request.accept();
    state = AcceptState.accepted;
  }

  Future<void> reject() async {
    await request.reject();
  }
}

enum AcceptState {
  idle,
  accepting,
  accepted,
}
