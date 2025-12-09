import 'package:json_annotation/json_annotation.dart';

import 'album.dart';
import 'artist.dart';
import 'playlist.dart';
import 'track.dart';

part 'search_response.g.dart';

@JsonSerializable()
class SearchResponse {
  final TracksOfSearchResponse tracks;
  final ArtistsOfSearchResponse artists;
  final AlbumsOfSearchResponse albums;
  final PlaylistsOfSearchResponse playlists;

  SearchResponse({required this.tracks, required this.artists, required this.albums, required this.playlists});

  factory SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}

@JsonSerializable()
class TracksOfSearchResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyTrack> items;

  TracksOfSearchResponse(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory TracksOfSearchResponse.fromJson(Map<String, dynamic> json) => _$TracksOfSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TracksOfSearchResponseToJson(this);
}

@JsonSerializable()
class ArtistsOfSearchResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyArtist> items;

  ArtistsOfSearchResponse(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory ArtistsOfSearchResponse.fromJson(Map<String, dynamic> json) => _$ArtistsOfSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistsOfSearchResponseToJson(this);
}

@JsonSerializable()
class AlbumsOfSearchResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyAlbum> items;

  AlbumsOfSearchResponse(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory AlbumsOfSearchResponse.fromJson(Map<String, dynamic> json) => _$AlbumsOfSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumsOfSearchResponseToJson(this);
}

@JsonSerializable()
class PlaylistsOfSearchResponse {
  final String href;
  final int limit;
  final String? next;
  final int offset;
  final String? previous;
  final int total;
  final List<SpotifyPlaylist> items;

  PlaylistsOfSearchResponse(
      {required this.href,
      required this.limit,
      required this.next,
      required this.offset,
      required this.previous,
      required this.total,
      required this.items});

  factory PlaylistsOfSearchResponse.fromJson(Map<String, dynamic> json) => _$PlaylistsOfSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistsOfSearchResponseToJson(this);
}
