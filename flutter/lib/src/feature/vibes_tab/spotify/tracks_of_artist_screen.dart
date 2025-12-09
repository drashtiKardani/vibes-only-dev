import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/list_of_spotify_objects.dart';

import 'model/artist.dart';
import 'spotify_web_sdk.dart';

class TracksOfArtistScreen extends StatelessWidget {
  final String accessToken;
  final SpotifyArtist artist;

  const TracksOfArtistScreen({super.key, required this.artist, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artist.title),
      ),
      body: FutureBuilder(
        future: SpotifyWebSdk(accessToken: accessToken).getTopTracksOfArtist(artist.id!),
        builder: (BuildContext context, AsyncSnapshot<TopTracksOfArtist> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final tracks = snapshot.data!.tracks;
            return ListOfSpotifyObjects.tracks(
              tracks: tracks,
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
