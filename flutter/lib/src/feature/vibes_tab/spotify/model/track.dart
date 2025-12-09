import 'package:json_annotation/json_annotation.dart';

import 'album.dart';
import 'artist.dart';
import 'spotify_object.dart';

part 'track.g.dart';

@JsonSerializable()
class TracksOfPlaylistResponse {
  final String? next;
  final int total;
  final List<SpotifyPlaylistTrack> items;

  TracksOfPlaylistResponse({required this.next, required this.total, required this.items});

  factory TracksOfPlaylistResponse.fromJson(Map<String, dynamic> json) => _$TracksOfPlaylistResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TracksOfPlaylistResponseToJson(this);
}

@JsonSerializable()
class SpotifyPlaylistTrack {
  final SpotifyTrack track;

  SpotifyPlaylistTrack({required this.track});

  factory SpotifyPlaylistTrack.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistTrackFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyPlaylistTrackToJson(this);
}

@JsonSerializable()
class SpotifyTrack implements SpotifyObject {
  final String id;
  final String uri;
  final String name;
  final List<SpotifyArtist> artists;

  /// [album] is null in the response of "album tracks" request.
  final SpotifyAlbum? album;

  SpotifyTrack({required this.id, required this.uri, required this.name, required this.artists, required this.album});

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) => _$SpotifyTrackFromJson(json);

  Map<String, dynamic> toJson() => _$SpotifyTrackToJson(this);

  @override
  String? get imageUrl => album?.images.lastOrNull?.url;

  @override
  String? get subtitle => artists.firstOrNull?.name;

  @override
  String get title => name;
}
