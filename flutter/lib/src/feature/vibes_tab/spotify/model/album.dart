import 'package:json_annotation/json_annotation.dart';

import 'artist.dart';
import 'image.dart';
import 'spotify_object.dart';
import 'track.dart';

part 'album.g.dart';

@JsonSerializable()
class SpotifyAlbum implements SpotifyObject {
  /// [href] is not available in album of track
  final String? href;

  /// [id] is not available in album of track
  final String? id;
  final List<SpotifyImage> images;
  final String name;

  /// [uri] is not available in album of track
  final String? uri;

  /// [artists] is not available in album of track
  final List<SpotifyArtist>? artists;

  SpotifyAlbum(
      {required this.href,
      required this.id,
      required this.images,
      required this.name,
      required this.uri,
      required this.artists});

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) => _$SpotifyAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyAlbumToJson(this);

  @override
  String? get imageUrl => images.lastOrNull?.url;

  @override
  String? get subtitle => artists?.firstOrNull?.name;

  @override
  String get title => name;
}

@JsonSerializable()
class TracksOfAlbum {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyTrack> items;

  TracksOfAlbum(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory TracksOfAlbum.fromJson(Map<String, dynamic> json) => _$TracksOfAlbumFromJson(json);

  Map<String, dynamic> toJson() => _$TracksOfAlbumToJson(this);
}
