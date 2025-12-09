import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class SpotifyImage {
  final String url;
  final int? height;
  final int? width;

  SpotifyImage({required this.url, required this.height, required this.width});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) => _$SpotifyImageFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyImageToJson(this);
}
