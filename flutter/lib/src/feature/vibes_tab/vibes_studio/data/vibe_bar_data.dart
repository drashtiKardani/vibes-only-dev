import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'vibe_bar_data.g.dart';

// ignore: library_private_types_in_public_api
@JsonSerializable()
class VibeBarData extends _VibeBarData with _$VibeBarData {
  VibeBarData({required super.intensity, required super.duration, required super.patternIndex});

  factory VibeBarData.fromJson(Map<String, dynamic> json) => _$VibeBarDataFromJson(json);

  Map<String, dynamic> toJson() => _$VibeBarDataToJson(this);
}

abstract class _VibeBarData with Store {
  /// Height of the bar, in range of 0~99.
  @observable
  int intensity;

  /// Width of the bar, in seconds.
  @observable
  double duration;

  /// Pattern of this vibe. In range of available pattern indexes.
  @observable
  int patternIndex;

  /// Whether user has selected this bar by tapping on it.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @observable
  bool selected = false;

  _VibeBarData({required this.intensity, required this.duration, required this.patternIndex});
}
