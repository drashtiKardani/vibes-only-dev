import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_video_share_page/common/store_buttons.dart';
import 'package:flutter_video_share_page/common/vibes_share_page_scaffold.dart';
import 'package:flutter_video_share_page/data_model/short_video.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class VideoPage extends StatefulWidget {
  final String id;

  const VideoPage({Key? key, String? id})
      : id = id ?? '123',
        super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  String? title;
  String? caption;

  @override
  void initState() {
    super.initState();
    http
        .get(Uri.parse(
            'https://app.vibesonly.com/api/v1/videos/videos/${widget.id}/share_page/'))
        .then((response) => ShortVideo.fromJson(jsonDecode(response.body)))
        .then((shortVideo) {
      title = shortVideo.title;
      caption = shortVideo.caption;
      _controller = VideoPlayerController.networkUrl(Uri.parse(shortVideo.url))
        ..initialize().then(
          (_) {
            _controller?.setLooping(true);
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
            // Future.delayed(
            //     const Duration(seconds: 1),
            //     () => setState(() {
            //           _controller?.play();
            //         }));
          },
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return VibesSharePageScaffold(builder: (context, displayMode) {
      return Column(
        children: [
          SizedBox(
            width: 300,
            height: 550,
            child: _controller != null && _controller!.value.isInitialized
                ? Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      if (_controller != null &&
                          _controller!.value.isPlaying == false)
                        Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            size: 200,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller?.value.isPlaying ?? false
                                ? _controller?.pause()
                                : _controller?.play();
                          });
                        },
                      )
                    ],
                  )
                : Container(),
          ),
          const SizedBox(height: 10),
          const StoreButtonsRow(),
          const SizedBox(height: 16),
          if (title != null)
            SizedBox(
              width: 300,
              child: Text(title!,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          const SizedBox(height: 5),
          if (caption != null)
            SizedBox(
              width: 300,
              child: Text(caption!,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.white)),
            ),
          const SizedBox(height: 30),
          const SizedBox(
            width: 300,
            child: Text('Download the app to watch\nthe full version',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      );
    });
  }
}
