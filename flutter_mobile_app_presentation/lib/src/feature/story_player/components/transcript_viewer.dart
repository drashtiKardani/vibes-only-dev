import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

import '../../../audio/audio_handler.dart';
import '../story_transcript.dart';

class TranscriptViewer extends StatelessWidget {
  const TranscriptViewer({super.key, required this.storyTranscript});

  final StoryTranscript storyTranscript;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (c, index) {
          StoryTranscriptLine line = storyTranscript.lines.elementAt(index);
          return InkWell(
            onTap: () => VibesAudioHandler.instance.seek(line.start),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colorScheme.surface.withValues(alpha: 0.8),
              ),
              child: StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, snapshot) {
                  return Text(
                    line.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: line.isBeingReadAt(snapshot.data)
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: line.isBeingReadAt(snapshot.data)
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                    ),
                  );
                },
              ),
            ),
          );
        },
        childCount: storyTranscript.lines.length,
      ),
    );
  }
}
