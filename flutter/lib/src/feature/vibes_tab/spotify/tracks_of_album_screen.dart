import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/list_of_spotify_objects.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/album.dart';

import 'spotify_web_sdk.dart';

class TracksOfAlbumScreen extends StatelessWidget {
  final String accessToken;
  final SpotifyAlbum album;

  const TracksOfAlbumScreen({super.key, required this.album, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
      ),
      body: FutureBuilder(
        future: SpotifyWebSdk(accessToken: accessToken).getTracksOfAlbum(album.id!),
        builder: (BuildContext context, AsyncSnapshot<TracksOfAlbum> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final tracks = snapshot.data!.items;
            return ListOfSpotifyObjects.tracks(
              tracks: tracks,
              context: context,
              albumCoverOverride: album.imageUrl,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
