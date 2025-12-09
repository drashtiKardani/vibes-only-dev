import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_video_share_page/common/dashed_line_painter.dart';
import 'package:flutter_video_share_page/common/store_buttons.dart';
import 'package:flutter_video_share_page/common/vibes_share_page_scaffold.dart';
import 'package:flutter_video_share_page/data_model/category.dart';
import 'package:flutter_video_share_page/data_model/story.dart';
import 'package:flutter_video_share_page/theme.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key, this.id}) : super(key: key);

  final String? id;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late final Future<Story> futureStory;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureStory = http
        .get(Uri.parse(
            'https://app.vibesonly.com/api/v1/stories/stories/${widget.id}/'))
        .then(
      (response) {
        final story = Story.fromJson(jsonDecode(response.body));
        player.setUrl(story.audioPreview);
        return story;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return VibesSharePageScaffold(builder: (context, displayMode) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: displayMode == DisplayMode.web ? 80 : 30),
        child: Column(
          children: [
            FutureBuilder<Story>(
                future: futureStory,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Story not found!');
                  } else if (snapshot.hasData) {
                    if (displayMode == DisplayMode.web) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 480,
                            child: buildTextualInfo(
                                displayMode, snapshot.data!, context),
                          ),
                          const SizedBox(width: 56),
                          Flexible(
                            flex: 600,
                            child: buildStoryImage(
                                displayMode, snapshot.data!.imageFull ?? ''),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          buildStoryImage(
                              displayMode, snapshot.data!.imageFull ?? ''),
                          const SizedBox(height: 20),
                          buildTextualInfo(
                              displayMode, snapshot.data!, context),
                        ],
                      );
                    }
                  } else {
                    return const CircularProgressIndicator(strokeWidth: 1);
                  }
                }),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Column buildTextualInfo(
      DisplayMode displayMode, Story story, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StoreButtonsRow(),
        const SizedBox(height: 16),
        Text(story.title, style: Theme.of(context).textTheme.titleLarge),
        if (story.audioLengthSeconds != null)
          Text('${story.audioLengthSeconds! ~/ 60} minutes',
              style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 16),
        Text(story.description),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: story.categories
              .map((e) => buildCategoryChip(e, context))
              .toList(),
        ),
        SizedBox(height: displayMode == DisplayMode.web ? 60 : 30),
        SizedBox(
            width: double.infinity,
            child: CustomPaint(painter: DashedLinePainter())),
        SizedBox(height: displayMode == DisplayMode.web ? 60 : 25),
        Text(
          'Download the app to experience the full version.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: displayMode == DisplayMode.web ? 30 : 20),
      ],
    );
  }

  Widget buildCategoryChip(Category e, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: vibesPink),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(e.title, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget buildStoryImage(DisplayMode displayMode, String imageUrl) {
    return GestureDetector(
      onTap: () {
        player.playing ? player.pause() : player.play();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 8.0 / 6.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  displayMode == DisplayMode.web ? 30 : 15),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.network(imageUrl),
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(builder: (context, constraints) {
              return StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    if (snapshot.data?.processingState ==
                        ProcessingState.completed) {
                      player.seek(Duration.zero);
                      player.stop();
                    }
                    if (snapshot.data?.playing == false) {
                      return Icon(
                        Icons.play_circle_outline_rounded,
                        size: constraints.maxWidth / 3,
                        color: Colors.white.withValues(alpha: 0.5),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  });
            }),
          ),
        ],
      ),
    );
  }
}
