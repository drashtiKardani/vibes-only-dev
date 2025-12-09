import 'package:flutter/material.dart';

class SpotifyPlayerScreen extends StatelessWidget {
  const SpotifyPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      // body: StreamBuilder(
      //     stream: SpotifySdk.subscribePlayerState(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasError) {
      //         return Center(child: Text(snapshot.error.toString()));
      //       }
      //       if (snapshot.hasData) {
      //         final playerState = snapshot.data!;
      //         final imageUrl = playerState.track?.imageUri;
      //         return Stack(
      //           children: [
      //             if (imageUrl != null)
      //               FastFutureBuilder(
      //                 future: SpotifySdk.getImage(imageUri: imageUrl),
      //                 successBuilder: (bytes) {
      //                   return Image.memory(
      //                     bytes!,
      //                     fit: BoxFit.cover,
      //                     width: double.infinity,
      //                     height: double.infinity,
      //                   );
      //                 },
      //               ),
      //             Container(
      //               decoration: const BoxDecoration(
      //                 gradient: LinearGradient(
      //                   colors: [Colors.transparent, Colors.black],
      //                   begin: Alignment.topCenter,
      //                   end: Alignment.bottomCenter,
      //                 ),
      //               ),
      //             ),
      //             Container(
      //               decoration: const BoxDecoration(
      //                 gradient: LinearGradient(
      //                   colors: [Colors.black, Colors.transparent],
      //                   begin: Alignment.topCenter,
      //                   end: Alignment.bottomCenter,
      //                   stops: [0.0, 0.2635],
      //                 ),
      //               ),
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.symmetric(horizontal: 20),
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   // SpotifyToyControlButtons(isPlaying: !playerState.isPaused),
      //                   Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Text(
      //                       playerState.track?.name ?? '',
      //                       maxLines: 2,
      //                       style: Theme.of(context).textTheme.displaySmall,
      //                     ),
      //                   ),
      //                   Align(
      //                     alignment: Alignment.centerLeft,
      //                     child: Text(
      //                       playerState.track?.artist.name ?? '',
      //                       maxLines: 1,
      //                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      //                     ),
      //                   ),
      //                   const SizedBox(
      //                     height: 25,
      //                   ),
      //                   PeriodicBuilder(
      //                       period: const Duration(seconds: 1),
      //                       calculation: () => SpotifySdk.getPlayerState().then((state) => state?.playbackPosition),
      //                       builder: (positionInMillis) {
      //                         return ProgressBar(
      //                           thumbRadius: 0,
      //                           baseBarColor: Colors.white,
      //                           barHeight: 2,
      //                           timeLabelPadding: 10,
      //                           timeLabelTextStyle: const TextStyle(fontSize: 12),
      //                           progress: Duration(milliseconds: positionInMillis ?? 0),
      //                           total: Duration(milliseconds: playerState.track?.duration ?? 0),
      //                           onSeek: playerState.playbackRestrictions.canSeek
      //                               ? (duration) => SpotifySdk.seekTo(positionedMilliseconds: duration.inMilliseconds)
      //                               : null,
      //                         );
      //                       }),
      //                   PlaybackControlRowUI(
      //                     isPlaying: playerState.playbackSpeed > 0,
      //                     handlePrevious: playerState.playbackRestrictions.canSkipPrevious
      //                         ? (context) => SpotifySdk.skipPrevious()
      //                         : null,
      //                     handleRewind: playerState.playbackRestrictions.canSeek ? () {} : null,
      //                     handlePlay: null,
      //                     //     () {
      //                     //   if (playerState.playbackSpeed == 0) {
      //                     //     SpotifySdk.resume();
      //                     //   } else {
      //                     //     SpotifySdk.pause();
      //                     //   }
      //                     // },
      //                     handleForward: playerState.playbackRestrictions.canSeek ? () {} : null,
      //                     handleNext: playerState.playbackRestrictions.canSkipNext
      //                         ? (BuildContext context) => SpotifySdk.skipNext()
      //                         : null,
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         );
      //       } else {
      //         return const Center(child: CircularProgressIndicator());
      //       }
      //     }),
    );
  }
}
