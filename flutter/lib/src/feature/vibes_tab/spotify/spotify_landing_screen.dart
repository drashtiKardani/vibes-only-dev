import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:vibes_only/src/feature/vibes_tab/spotify/spotify_playlists_screen.dart';

final _navigatorKey = GlobalKey();

class SpotifyLandingScreen extends StatelessWidget {
  const SpotifyLandingScreen({super.key, required this.accessToken});

  final String accessToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                settings: settings,
                builder: (BuildContext context) =>
                    SpotifyPlaylistsScreen(accessToken: accessToken),
              ),
            ),
          ),
          Miniplayer(
            minHeight: 70,
            maxHeight: 370,
            builder: (height, percentage) => Container(
              color: AppColors.grey20,
              // child: StreamBuilder(
              //   stream: SpotifySdk.subscribePlayerState(),
              //   builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
              //     if (snapshot.hasData) {
              //       final playerState = snapshot.data!;
              //       final imageUrl = playerState.track?.imageUri;
              //       return percentage < 0.4 ? buildMini(imageUrl, playerState) : buildBig(imageUrl, playerState);
              //     } else {
              //       return const SizedBox.shrink();
              //     }
              //   },
              // ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildBig(ImageUri? imageUrl, PlayerState playerState) {
  //   return Column(
  //     children: [
  //       const Gap(10),
  //       const Icon(CupertinoIcons.chevron_down, color: AppColors.greyD2, size: 20),
  //       const Gap(10),
  //       if (imageUrl != null)
  //         Expanded(
  //           child: FastFutureBuilder(
  //             future: SpotifySdk.getImage(imageUri: imageUrl),
  //             successBuilder: (bytes) {
  //               return ClipRRect(
  //                 borderRadius: BorderRadius.circular(10),
  //                 child: Image.memory(
  //                   bytes!,
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       const Gap(10),
  //       Stack(
  //         children: [
  //           Center(
  //             child: Column(
  //               children: [
  //                 Text(playerState.track?.name ?? '', overflow: TextOverflow.ellipsis),
  //                 Text(
  //                   playerState.track?.artist.name ?? '',
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(color: Colors.white.withValues(alpha:0.6)),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.only(left: 20),
  //             alignment: AlignmentDirectional.centerStart,
  //             child: IconButton(
  //               onPressed: () {
  //                 if (playerState.track != null) {
  //                   launchUrl(Uri.parse(playerState.track!.uri));
  //                 }
  //               },
  //               icon: const Icon(Icons.playlist_play),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const Gap(10),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 30.0),
  //         child: PeriodicBuilder(
  //             period: const Duration(seconds: 1),
  //             calculation: () => SpotifySdk.getPlayerState().then((state) => state?.playbackPosition),
  //             builder: (positionInMillis) {
  //               return ProgressBar(
  //                 thumbRadius: 0,
  //                 baseBarColor: Colors.white,
  //                 barHeight: 2,
  //                 timeLabelPadding: 10,
  //                 timeLabelTextStyle: const TextStyle(fontSize: 12),
  //                 progress: Duration(milliseconds: positionInMillis ?? 0),
  //                 total: Duration(milliseconds: playerState.track?.duration ?? 0),
  //                 onSeek: playerState.playbackRestrictions.canSeek
  //                     ? (duration) => SpotifySdk.seekTo(positionedMilliseconds: duration.inMilliseconds)
  //                     : null,
  //               );
  //             }),
  //       ),
  //       const Gap(10),
  //       buildControls(playerState),
  //       const Gap(20),
  //     ],
  //   );
  // }
  //
  // Row buildControls(PlayerState playerState) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       IconButton(
  //         onPressed: playerState.playbackRestrictions.canSkipPrevious ? () => SpotifySdk.skipPrevious() : null,
  //         icon: const Icon(VibesV2.previous),
  //       ),
  //       Material(
  //         color: AppColors.vibesPink,
  //         shape: const CircleBorder(),
  //         child: InkWell(
  //           borderRadius: BorderRadius.circular(20.0),
  //           child: Ink(
  //             width: 40,
  //             height: 40,
  //             child: Icon(
  //               playerState.playbackSpeed > 0 ? VibesV2.pause : VibesV2.play,
  //               color: Colors.white,
  //             ),
  //           ),
  //           onTap: () {
  //             if (playerState.playbackSpeed == 0) {
  //               SpotifySdk.resume();
  //             } else {
  //               SpotifySdk.pause();
  //             }
  //           },
  //         ),
  //       ),
  //       IconButton(
  //         onPressed: playerState.playbackRestrictions.canSkipNext ? () => SpotifySdk.skipNext() : null,
  //         icon: const Icon(VibesV2.next),
  //       ),
  //     ],
  //   );
  // }
  //
  // Row buildMini(ImageUri? imageUrl, PlayerState playerState) {
  //   return Row(
  //     children: [
  //       const Gap(20),
  //       if (imageUrl != null)
  //         FastFutureBuilder(
  //           future: SpotifySdk.getImage(imageUri: imageUrl),
  //           successBuilder: (bytes) {
  //             return ClipRRect(
  //               borderRadius: BorderRadius.circular(5),
  //               child: Image.memory(
  //                 bytes!,
  //                 width: 50,
  //                 height: 50,
  //               ),
  //             );
  //           },
  //         ),
  //       const Gap(10),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(playerState.track?.name ?? '', overflow: TextOverflow.ellipsis),
  //             Text(
  //               playerState.track?.artist.name ?? '',
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(color: Colors.white.withValues(alpha:0.6)),
  //             ),
  //           ],
  //         ),
  //       ),
  //       buildControls(playerState),
  //     ],
  //   );
  // }
}
