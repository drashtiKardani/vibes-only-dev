import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
// import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/tracks_of_artist_screen.dart';

import 'model/album.dart';
import 'model/artist.dart';
import 'model/playlist.dart';
import 'model/spotify_object.dart';
import 'model/track.dart';
import 'tracks_of_album_screen.dart';
import 'tracks_of_playlist_screen.dart';

class ListOfSpotifyObjects extends StatelessWidget {
  const ListOfSpotifyObjects({super.key, required this.items, required this.onTap, this.albumCoverOverride});

  final List<SpotifyObject>? items;
  final void Function(int index) onTap;

  /// If provided, will be used if [items] don't have a album cover themselves.
  /// This happens in track list of an album.
  final String? albumCoverOverride;

  factory ListOfSpotifyObjects.playlists(
      {required List<SpotifyPlaylist>? playlists, required BuildContext context, required String accessToken}) {
    return ListOfSpotifyObjects(
        items: playlists,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TracksOfPlaylistScreen(playlistId: playlists![index].id, accessToken: accessToken)),
          );
        });
  }

  /// [albumCoverOverride] is necessary when tracks don't have a cover.
  factory ListOfSpotifyObjects.tracks(
      {required List<SpotifyTrack>? tracks, required BuildContext context, String? albumCoverOverride}) {
    return ListOfSpotifyObjects(
        items: tracks,
        albumCoverOverride: albumCoverOverride,
        onTap: (index) {
          // SpotifySdk.play(spotifyUri: tracks![index].uri);
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const SpotifyPlayerScreen()));
        });
  }

  factory ListOfSpotifyObjects.albums(
      {required List<SpotifyAlbum>? albums, required BuildContext context, required String accessToken}) {
    return ListOfSpotifyObjects(
        items: albums,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TracksOfAlbumScreen(album: albums![index], accessToken: accessToken)),
          );
        });
  }

  factory ListOfSpotifyObjects.artists(
      {required List<SpotifyArtist>? artists, required BuildContext context, required String accessToken}) {
    return ListOfSpotifyObjects(
        items: artists,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TracksOfArtistScreen(artist: artists![index], accessToken: accessToken)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (items?.isNotEmpty != true) {
      return const Center(child: Text('NO RESULTS FOUND'));
    }
    return ListView.separated(
      itemBuilder: (ctx, idx) {
        final item = items![idx];
        return ListTile(
          onTap: () => onTap(idx),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? albumCoverOverride ?? '',
              width: 50,
              height: 50,
            ),
          ),
          title: Text(item.title),
          subtitle: item.subtitle == null ? null : Text(item.subtitle!),
        );
      },
      separatorBuilder: (ctx, idx) => Container(
        color: AppColors.grey25,
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
      ),
      itemCount: items!.length,
    );
  }
}
