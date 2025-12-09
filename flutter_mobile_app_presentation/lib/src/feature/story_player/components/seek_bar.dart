import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:rxdart/rxdart.dart';

import '../../../audio/audio_handler.dart';
import '../../../widget/progress_bar_premium_badge_overlay.dart';
import '../player_screen.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key, required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaState>(
      stream: _mediaStateStream,
      builder: (context, snapshot) {
        final MediaState? mediaState = snapshot.data;

        return PremiumBadgeOverlay(
          progressBar: ProgressBar(
            thumbRadius: 4,
            thumbColor: context.colorScheme.onSurface,
            thumbGlowRadius: 20,
            thumbGlowColor:
                context.colorScheme.onSurface.withValues(alpha: 0.1),
            baseBarColor: context.colorScheme.onSurface.withValues(alpha: 0.3),
            bufferedBarColor:
                context.colorScheme.onSurface.withValues(alpha: 0.3),
            progressBarColor: context.colorScheme.onSurface,
            barHeight: 2,
            timeLabelPadding: 10,
            timeLabelTextStyle: const TextStyle(fontSize: 12),
            progress: mediaState?.position ?? Duration.zero,
            buffered: mediaState?.buffer ?? Duration.zero,
            total: mediaState?.mediaItem?.duration ?? Duration.zero,
            onSeek: VibesAudioHandler.instance.seek,
          ),
          premium: isPremium,
          totalDuration: mediaState?.mediaItem?.duration,
        );
      },
    );
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream {
    return Rx.combineLatest3<MediaItem?, Duration, PlaybackState, MediaState>(
      VibesAudioHandler.instance.mediaItem,
      AudioService.position,
      VibesAudioHandler.instance.playbackState,
      (mediaItem, position, state) {
        return MediaState(mediaItem, position, state.bufferedPosition);
      },
    );
  }
}
