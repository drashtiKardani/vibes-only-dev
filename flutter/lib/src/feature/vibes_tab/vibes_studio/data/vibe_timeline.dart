import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/config.dart';

import 'vibe_bar_data.dart';

part 'vibe_timeline.g.dart';

/// Manipulatable collection of positioned [VibeBarData]s.
// ignore: library_private_types_in_public_api
@JsonSerializable()
class VibeTimeline extends _VibeTimeline with _$VibeTimeline {
  VibeTimeline({super.data});

  factory VibeTimeline.fromJson(Map<String, dynamic> json) => _$VibeTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$VibeTimelineToJson(this);
}

abstract class _VibeTimeline with Store {
  _VibeTimeline({List<VibeBarData>? data}) {
    this.data = ObservableList.of(
      data ??
          [
            VibeBarData(intensity: 50, duration: VibeStudioConfig.initialDuration, patternIndex: 0),
            VibeBarData(intensity: 60, duration: VibeStudioConfig.initialDuration, patternIndex: 1),
            VibeBarData(intensity: 70, duration: VibeStudioConfig.initialDuration, patternIndex: 2),
          ],
    );
  }

  static List<VibeBarData> _dataListToJson(ObservableList<VibeBarData> data) => data.toList();

  @JsonKey(
    toJson: _dataListToJson,
  )
  late final ObservableList<VibeBarData> data;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @observable
  bool aBarIsBeingResized = false;

  @action
  void toggleSelectForResizing(VibeBarData vibe) {
    final currentSelectionStatus = vibe.selected;
    deselectAllBars();
    vibe.selected = !currentSelectionStatus;
  }

  @action
  void deselectAllBars() {
    for (var v in data) {
      v.selected = false;
    }
  }

  @action
  void addBar({required int patternIndex}) {
    data.add(
      VibeBarData(
        intensity: VibeStudioConfig.initialIntensity,
        duration: VibeStudioConfig.initialDuration,
        patternIndex: patternIndex,
      ),
    );
  }

  @action
  void removeBar(VibeBarData barData) {
    data.remove(barData);
  }

  @computed
  double get durationInSec => data.fold(0, (previousValue, element) => previousValue + element.duration);

  @computed
  String get durationString => '${(durationInSec ~/ 60).toString().padLeft(2, '0')}'
      ':${(durationInSec.toInt() % 60).toString().padLeft(2, '0')}';
}
