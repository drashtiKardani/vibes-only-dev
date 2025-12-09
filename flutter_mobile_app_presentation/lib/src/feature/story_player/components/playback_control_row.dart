import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/src/extension/int_as_duration.dart';
import 'package:flutter_mobile_app_presentation/src/feature/story_player/player_screen.dart';
import 'package:flutter_mobile_app_presentation/src/feature/story_player/player_store.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_common/vibes.dart';

/// A uniform UI for playback buttons of a general audio player (play, rewind, etc.).
/// It can for example be used in VibesOnly story player, or a music player (e.g. Spotify player).
class PlaybackControlRowUI extends StatelessWidget {
  const PlaybackControlRowUI({
    super.key,
    required this.isPlaying,
    required this.handlePrevious,
    required this.handleRewind,
    required this.handlePlay,
    required this.handleForward,
    required this.handleNext,
  });

  final void Function(BuildContext context)? handlePrevious;

  final void Function()? handleRewind;

  final void Function()? handlePlay;

  final void Function()? handleForward;

  final void Function(BuildContext context)? handleNext;

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    String package = 'flutter_mobile_app_presentation';

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed:
                handlePrevious == null ? null : () => handlePrevious!(context),
            child: Assets.svgs.previous.svg(package: package),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handleRewind,
            child: Assets.svgs.backward15Sec.svg(package: package),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handlePlay,
            child: isPlaying
                ? Assets.svgs.pause.svg(
                    package: package,
                    height: 100,
                    width: 100,
                  )
                : Assets.svgs.play.svg(
                    package: package,
                    height: 100,
                    width: 100,
                  ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handleForward,
            child: Assets.svgs.forward15Sec.svg(package: package),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: handleNext == null ? null : () => handleNext!(context),
            child: Assets.svgs.next.svg(package: package),
          ),
        ],
      ),
    );
  }
}

class PlaybackControlRow extends StatefulWidget {
  const PlaybackControlRow({super.key, required this.store, this.sectionItem});

  final PlayerStore store;
  final SectionItem? sectionItem;

  @override
  State<PlaybackControlRow> createState() => _PlaybackControlRowState();
}

class _PlaybackControlRowState extends State<PlaybackControlRow> {
  late final ReactionDisposer cleanup;
  final isPlaying = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    cleanup = reaction(
      (_) => widget.store.playing,
      (playing) => isPlaying.value = playing,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return PlaybackControlRowUI(
        handleForward: _handleForward,
        handlePrevious: _handlePrevious,
        handleRewind: _handleRewind,
        handlePlay: _handlePlay,
        handleNext: _handleNext,
        isPlaying: widget.store.playing,
      );
    });
  }

  void _handlePlay() {
    if (widget.store.playing) {
      VibesAudioHandler.instance.pause();
    } else {
      VibesAudioHandler.instance.play();
    }
    widget.store.playing = !widget.store.playing;
  }

  void _handleRewind() {
    VibesAudioHandler.instance
        .seek(VibesAudioHandler.instance.currentPosition() - 15.seconds());
  }

  void _handlePrevious(BuildContext context) {
    _skipTo(context, offsetIndex: -1);
  }

  void _handleForward() {
    VibesAudioHandler.instance
        .seek(VibesAudioHandler.instance.currentPosition() + 15.seconds());
  }

  void _handleNext(BuildContext context) {
    _skipTo(context, offsetIndex: 1);
  }

  void _skipTo(BuildContext context, {required int offsetIndex}) {
    if (widget.sectionItem?.parentSection == null) {
      debugPrint('Next item is not available.');
      return;
    }

    final Section parentSection = widget.sectionItem!.parentSection!;
    final int currentItemIndex = parentSection.containingStories
        .indexWhere((e) => e.id.toString() == widget.sectionItem!.id);
    final int nextItemIndex = (currentItemIndex + offsetIndex) %
        parentSection.containingStories.length;
    final Story nextItem = parentSection.containingStories[nextItemIndex];
    final SectionItem nextSectionItem = nextItem.toSectionItem(
      parentSection.title,
      parentSection.style,
      parentSection: parentSection,
    );
    final MediaItem nextMediaItem = MediaItem(
      id: nextItem.audio ?? '',
      title: nextItem.title,
      artUri: Uri.parse(nextSectionItem.thumbnail),
    );

    VibesAudioHandler.instance.playMediaItem(nextMediaItem);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PlayerScreen(
            item: nextMediaItem,
            sectionItem: nextSectionItem,
            toyCommands: StoryBeatDecoder.decode(nextItem.beat),
          );
        },
      ),
    );
  }
}
