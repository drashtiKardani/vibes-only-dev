import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/service/analytics.dart';
import 'package:flutter_mobile_app_presentation/src/widget/progress_bar_premium_badge_overlay.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final bool play;
  final int index;
  final bool? premium;
  final int videoId;
  final String videoTitle;

  const VideoWidget(
      {super.key,
      required this.index,
      required this.controller,
      required this.play,
      this.premium,
      required this.videoId,
      required this.videoTitle});

  @override
  State createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      debugPrint('playing video (init) ${widget.index}');
      logVideoView();
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
        debugPrint('playing video ${widget.index}');
        logVideoView();
      } else {
        _controller.pause();
        debugPrint('pausing video ${widget.index}');
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void logVideoView() {
    Analytics.logEvent(
      name: 'video_view',
      parameters: {
        'video_view__id': widget.videoId.toString(),
        'video_view__title': widget.videoTitle,
      },
      context: context,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 96, bottom: 32),
                child: videoProgressBar(),
              )
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  ValueListenableBuilder<VideoPlayerValue> videoProgressBar() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, videoPlayer, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              padding: const EdgeInsets.only(bottom: 2.5),
              onPressed: () => _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play(),
              icon: Icon(
                _controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _controller.value.duration.toVideoTimeString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  PremiumBadgeOverlay(
                    progressBar: ProgressBar(
                      thumbRadius: 7.5,
                      baseBarColor: Colors.white,
                      barHeight: 2,
                      timeLabelLocation: TimeLabelLocation.none,
                      progress: videoPlayer.position,
                      total: _controller.value.duration,
                      onSeek: (duration) {
                        _controller.seekTo(duration);
                      },
                    ),
                    premium: widget.premium ?? false,
                    totalDuration: _controller.value.duration,
                    verticalCorrection: 6.5,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

extension CustomFormat on Duration {
  String toVideoTimeString() {
    return '${_twoDigits(inMinutes)}:${_twoDigits(inSeconds)}';
  }

  String _twoDigits(int minutesOrSeconds) {
    return minutesOrSeconds.remainder(60).toString().padLeft(2, '0');
  }
}
