import 'package:mobx/mobx.dart';

part 'player_store.g.dart';

// ignore: library_private_types_in_public_api
class PlayerStore = _PlayerStore with _$PlayerStore;

abstract class _PlayerStore with Store {
  @observable
  var playing = false;

  @observable
  double screenScrollOffset = 0;

  @computed
  bool get transcriptViewerIsFullSize => screenScrollOffset >= mainPlayerMaxHeight;

  @computed
  bool get transcriptViewerIsHalfSize => screenScrollOffset >= mainPlayerMaxHeight / 2;

  @computed
  bool get transcriptViewerIsClosed => screenScrollOffset <= 10;

  double mainPlayerMaxHeight = 0;
}
