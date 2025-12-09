import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/list_of_spotify_objects.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/track.dart';

import 'spotify_web_sdk.dart';

class TracksOfPlaylistScreen extends StatelessWidget {
  final String accessToken;
  final String playlistId;

  const TracksOfPlaylistScreen({super.key, required this.playlistId, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify'),
      ),
      body: FutureBuilder(
        future: SpotifyWebSdk(accessToken: accessToken).getTracksOfPlaylist(playlistId),
        builder: (BuildContext context, AsyncSnapshot<TracksOfPlaylistResponse> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final tracks = snapshot.data!.items;
            return ListOfSpotifyObjects.tracks(
              tracks: tracks.map((e) => e.track).toList(),
              context: context,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
