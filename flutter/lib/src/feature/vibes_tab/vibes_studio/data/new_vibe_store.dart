import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_timeline.dart';

part 'new_vibe_store.g.dart';

// ignore: library_private_types_in_public_api
@JsonSerializable()
class NewVibeStore extends _NewVibeStore with _$NewVibeStore {
  NewVibeStore(super.name,
      {required super.toyBluetoothName,
      super.timeline1,
      super.timeline2,
      super.timeline3});

  factory NewVibeStore.fromJson(Map<String, dynamic> json) =>
      _$NewVibeStoreFromJson(json);

  Map<String, dynamic> toJson() => _$NewVibeStoreToJson(this);
}

abstract class _NewVibeStore with Store {
  _NewVibeStore(this.name,
      {required this.toyBluetoothName,
      VibeTimeline? timeline1,
      VibeTimeline? timeline2,
      VibeTimeline? timeline3}) {
    this.timeline1 = timeline1 ?? VibeTimeline();
    this.timeline2 = timeline2 ?? VibeTimeline();
    this.timeline3 = timeline3 ?? VibeTimeline();
  }

  @observable
  String name;

  final String toyBluetoothName;

  /// timeline associated with motor#1.
  late final VibeTimeline timeline1;

  /// timeline associated with motor#2.
  late final VibeTimeline timeline2;

  /// timeline associated with motor#3.
  late final VibeTimeline timeline3;
}
