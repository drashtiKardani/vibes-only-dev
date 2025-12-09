import 'package:json_annotation/json_annotation.dart';
import 'package:vibes_common/vibes.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true)
class CardGameDetails {
  @JsonKey(name: 'play_type')
  final PlayType playType;
  @JsonKey(name: 'prompt_type')
  final PromptType promptType;
  @JsonKey(name: 'game_card')
  final List<GameCard> gameCards;

  const CardGameDetails({
    required this.playType,
    required this.promptType,
    required this.gameCards,
  });

  factory CardGameDetails.fromJson(Map<String, dynamic> json) =>
      _$CardGameDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CardGameDetailsToJson(this);
}

enum PlayType {
  choose,
  @JsonValue('surprise_me')
  surpriseMe
}

/// A wrapper class to distinguish between null values and absent values in copyWith methods
class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}
