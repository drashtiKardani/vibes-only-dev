import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/list_of_spotify_objects.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/model/search_response.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/search_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/spotify_web_sdk.dart';

import 'model/playlist.dart';
import 'toy_control_buttons.dart';

class SpotifyPlaylistsScreen extends StatefulWidget {
  final String accessToken;

  const SpotifyPlaylistsScreen({super.key, required this.accessToken});

  @override
  State<SpotifyPlaylistsScreen> createState() => _SpotifyPlaylistsScreenState();
}

enum _Tab { library, playlists }

enum _LibraryType { artists, tracks }

class _SpotifyPlaylistsScreenState extends State<SpotifyPlaylistsScreen> {
  var selectedTab = _Tab.library;

  var selectedLibraryType = _LibraryType.artists;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop()),
        title: const Text('Music Vibes'),
        centerTitle: true,
        actions: const [SpotifyToyControlButtons(), Gap(10)],
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SearchScreen(accessToken: widget.accessToken)),
                            ),
                        icon: const Icon(Icons.search)),
                  ],
                ),
              ),
              Center(
                child: CustomSlidingSegmentedControl<_Tab>(
                  innerPadding: EdgeInsets.zero,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.grey20),
                  thumbDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.vibesPink),
                  customSegmentSettings: CustomSegmentSettings(radius: 20),
                  onValueChanged: (newValue) {
                    setState(() {
                      selectedTab = newValue;
                    });
                  },
                  children: {for (var tab in _Tab.values) tab: Text(tab.name.capitalize())},
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Gap(20),
              DropdownButton<_LibraryType>(
                value: selectedLibraryType,
                icon: const Icon(CupertinoIcons.chevron_down, color: Colors.white),
                iconSize: 20,
                dropdownColor: AppColors.grey20,
                underline: const SizedBox.shrink(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLibraryType = newValue;
                    });
                  }
                },
                items: _LibraryType.values.map<DropdownMenuItem<_LibraryType>>((value) {
                  return DropdownMenuItem<_LibraryType>(
                    value: value,
                    child: Text(
                      value.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Container(height: 1, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 20)),
          Expanded(
            child: buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget buildItemsList() {
    if (selectedTab == _Tab.playlists) {
      return FutureBuilder(
        future: SpotifyWebSdk(accessToken: widget.accessToken).getPlaylistsOfMe(),
        builder: (BuildContext context, AsyncSnapshot<PlaylistsOfMeResponse> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final playlists = snapshot.data!.items;
            return ListOfSpotifyObjects.playlists(
              playlists: playlists,
              context: context,
              accessToken: widget.accessToken,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      if (selectedLibraryType == _LibraryType.artists) {
        return FutureBuilder(
          future: SpotifyWebSdk(accessToken: widget.accessToken).getTopArtists(),
          builder: (BuildContext context, AsyncSnapshot<ArtistsOfSearchResponse> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              final artists = snapshot.data!.items;
              return ListOfSpotifyObjects.artists(
                artists: artists,
                context: context,
                accessToken: widget.accessToken,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      } else {
        return FutureBuilder(
          future: SpotifyWebSdk(accessToken: widget.accessToken).getTopTracks(),
          builder: (BuildContext context, AsyncSnapshot<TracksOfSearchResponse> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              final tracks = snapshot.data!.items;
              return ListOfSpotifyObjects.tracks(
                tracks: tracks,
                context: context,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
