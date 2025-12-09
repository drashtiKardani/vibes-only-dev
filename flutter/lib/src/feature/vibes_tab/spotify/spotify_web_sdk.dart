import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/album.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/artist.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/playlist.dart';

import 'model/search_response.dart';
import 'model/track.dart';

class SpotifyWebSdk {
  final String accessToken;

  SpotifyWebSdk({required this.accessToken});

  Future<PlaylistsOfMeResponse> getPlaylistsOfMe() {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return PlaylistsOfMeResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  Future<TracksOfPlaylistResponse> getTracksOfPlaylist(String playlistId) {
    return http.get(
      Uri.parse(
        Uri.encodeFull('https://api.spotify.com/v1/playlists/$playlistId/tracks'
            '?fields=total,next,items(track(id,name,uri,artists.name,album(name,images)))'),
      ),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return TracksOfPlaylistResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  Future<TracksOfAlbum> getTracksOfAlbum(String albumId) {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return TracksOfAlbum.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  /// Note that here "market" parameter is necessary. Otherwise status code will be 400.
  Future<TopTracksOfArtist> getTopTracksOfArtist(String artistId) {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return TopTracksOfArtist.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  Future<ArtistsOfSearchResponse> getTopArtists() {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/artists'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return ArtistsOfSearchResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  Future<TracksOfSearchResponse> getTopTracks() {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/tracks'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return TracksOfSearchResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  // Function to make API calls and fetch data based on the type
  Future<SearchResponse> search({required String query}) {
    return http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=album,artist,playlist,track'),
      headers: {'Authorization': 'Bearer $accessToken'},
    ).then((response) {
      print(response.statusCode);
      return SearchResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }
}
