import 'package:json_annotation/json_annotation.dart';

import 'image.dart';
import 'spotify_object.dart';
import 'track.dart';

part 'artist.g.dart';

@JsonSerializable()
class SpotifyArtist implements SpotifyObject {
  /// [href] is not available in artist of track
  final String? href;

  /// [id] is not available in artist of track
  final String? id;

  /// [images] is not present in "SimplifiedArtistObject" (e.g. for artists of an album)
  final List<SpotifyImage>? images;
  final String name;

  /// [uri] is not available in artist of track
  final String? uri;

  SpotifyArtist({required this.href, required this.id, required this.images, required this.name, required this.uri});

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) => _$SpotifyArtistFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyArtistToJson(this);

  @override
  String? get imageUrl => images?.lastOrNull?.url;

  @override
  String? get subtitle => null;

  @override
  String get title => name;
}

@JsonSerializable()
class TopTracksOfArtist {
  final List<SpotifyTrack> tracks;

  TopTracksOfArtist({required this.tracks});

  factory TopTracksOfArtist.fromJson(Map<String, dynamic> json) => _$TopTracksOfArtistFromJson(json);

  Map<String, dynamic> toJson() => _$TopTracksOfArtistToJson(this);
}
