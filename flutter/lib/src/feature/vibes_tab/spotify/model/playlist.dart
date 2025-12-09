import 'package:json_annotation/json_annotation.dart';

import 'image.dart';
import 'spotify_object.dart';

part 'playlist.g.dart';

@JsonSerializable()
class PlaylistsOfMeResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyPlaylist> items;

  PlaylistsOfMeResponse(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory PlaylistsOfMeResponse.fromJson(Map<String, dynamic> json) => _$PlaylistsOfMeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistsOfMeResponseToJson(this);
}

@JsonSerializable()
class SpotifyPlaylist implements SpotifyObject {
  final String href;
  final String id;
  final List<SpotifyImage> images;
  final String name;
  final String uri;

  SpotifyPlaylist({required this.href, required this.id, required this.images, required this.name, required this.uri});

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyPlaylistToJson(this);

  @override
  String? get imageUrl => images.lastOrNull?.url;

  @override
  String? get subtitle => null;

  @override
  String get title => name;
}
