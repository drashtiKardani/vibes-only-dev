import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/audio/media_item_extras.dart';
import 'package:flutter_mobile_app_presentation/src/feature/story_player/components/toy_control_buttons_provider.dart';
import 'package:flutter_mobile_app_presentation/src/theme/context_extension.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_common/vibes.dart';

import '../../audio/audio_handler.dart';
import '../../cubit/toy/toy_cubit.dart';
import '../../data/local_storage/sync_shared_preferences.dart';
import 'components/playback_control_row.dart';
import 'components/seek_bar.dart';
import 'components/transcript_viewer.dart';
import 'components/transcript_viewer_header.dart';
import 'dialogs.dart';
import 'player_store.dart';
import 'story_transcript.dart';
import 'toy_command_model.dart';
import 'toy_command_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.item,
    this.sectionItem,
    this.toyCommands,
  });

  final MediaItem item;
  final SectionItem? sectionItem;
  final List<AllToyCommands>? toyCommands;

  @override
  State createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  final PlayerStore store = PlayerStore();

  late StreamSubscription<PlaybackState> _listener;

  String get coverUrl => widget.item.artUri.toString();

  String get title => widget.item.title;

  late ToyCubit _toyCubit;
  late ToyCommandService _toyCommandService;

  bool get storyContainsVibes => _toyCommandService.currentStoryContainsVibes;

  late final StoryTranscript storyTranscript;

  late final ScrollController scrollController;
  late final AnimationController bottomPlaybackControlanimationController;
  late final AnimationController transcriptBottomClipperAnimationController;
  late final List<ReactionDisposer> reactionDisposers;

  void onScrollListener() {
    debugPrint(scrollController.offset.toString());
    store.screenScrollOffset = scrollController.offset;
  }

  @override
  void dispose() {
    _listener.cancel();
    scrollController.removeListener(onScrollListener);
    scrollController.dispose();
    bottomPlaybackControlanimationController.dispose();
    transcriptBottomClipperAnimationController.dispose();
    for (var disposer in reactionDisposers) {
      disposer.call();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(onScrollListener);
    bottomPlaybackControlanimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 100,
    );
    transcriptBottomClipperAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0,
      upperBound: 10,
    );
    reactionDisposers = [
      reaction<bool>((_) => store.transcriptViewerIsFullSize, (fullSize) {
        fullSize
            ? bottomPlaybackControlanimationController.forward()
            : bottomPlaybackControlanimationController.reverse();
      }),
      reaction<bool>((_) => store.transcriptViewerIsHalfSize, (halfSize) {
        halfSize
            ? transcriptBottomClipperAnimationController.forward()
            : transcriptBottomClipperAnimationController.reverse();
      }),
    ];

    var item = VibesAudioHandler.instance.playbackState.value;
    store.playing = item.playing;
    _listener = VibesAudioHandler.instance.playbackState.listen((state) {
      if (store.playing != state.playing) {
        store.playing = state.playing;
      }
    });

    storyTranscript = widget.item.storyTranscript;

    _toyCubit = BlocProvider.of<ToyCubit>(context);
    _toyCommandService = BlocProvider.of<ToyCommandService>(context);

    if (widget.toyCommands != null) {
      // We are here from story_detail_screen. We need to setup ToyCommandService
      _toyCommandService.executeSynchronizedWithAudio(
        widget.toyCommands!,
        _toyCubit,
      );
    } else {
      // We are here from vibes_main_screen (mini player). ToyCommandService is already setup.
    }

    if (!_toyCubit.adminPanelSimulationMode &&
        widget.toyCommands != null &&
        widget.toyCommands!.isNotEmpty &&
        _toyCubit.state.connectedDevice == null &&
        SyncSharedPreferences.doNotAskToConnectToy.value == false) {
      Future(() => GetIt.I<ConnectToyDialogProvider>().display(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: coverUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, context.colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Observer(
            builder: (context) {
              return Container(
                color: Colors.black.withValues(
                  alpha: store.screenScrollOffset <= 0
                      ? 0
                      : min(
                          1.0,
                          store.screenScrollOffset / store.mainPlayerMaxHeight,
                        ),
                ),
              );
            },
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                debugPrint(constraints.toString());
                store.mainPlayerMaxHeight =
                    constraints.maxHeight -
                    kToolbarHeight -
                    TranscriptViewerHeader.headerHeight;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Observer(
                        builder: (_) {
                          return AnimatedBuilder(
                            animation:
                                transcriptBottomClipperAnimationController,
                            builder: (context, childWidget) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      transcriptBottomClipperAnimationController
                                          .value,
                                ),
                                child: ClipRRect(
                                  /// So that the scrolling list doesn't spoil the rounded corners of the header
                                  borderRadius: BorderRadius.vertical(
                                    top: const Radius.circular(10),
                                    bottom: Radius.circular(
                                      transcriptBottomClipperAnimationController
                                          .value,
                                    ),
                                  ),
                                  child: CustomScrollView(
                                    controller: scrollController,
                                    slivers: [
                                      SliverAppBar(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        leading: _backButton(),
                                      ),
                                      SliverToBoxAdapter(
                                        child: _buildPlayerController(
                                          constraints,
                                        ),
                                      ),
                                      if (!Platform.isAndroid) ...[
                                        // Lyrics is disabled on Android
                                        SliverPersistentHeader(
                                          delegate: TranscriptViewerHeader(
                                            store: store,
                                            onArrowPressed: () {
                                              scrollController.animateTo(
                                                store.transcriptViewerIsClosed
                                                    ? store.mainPlayerMaxHeight /
                                                          2
                                                    : 0.0,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.bounceInOut,
                                              );
                                            },
                                            onFullscreenPressed: () {
                                              scrollController.animateTo(
                                                store.mainPlayerMaxHeight +
                                                    kToolbarHeight,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.bounceInOut,
                                              );
                                            },
                                          ),
                                          pinned: true,
                                          floating: true,
                                        ),
                                        TranscriptViewer(
                                          storyTranscript: storyTranscript,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: bottomPlaybackControlanimationController,
                      builder: (context, child) {
                        return SizedBox(
                          height:
                              bottomPlaybackControlanimationController.value,
                          child: FittedBox(
                            fit: BoxFit.none,
                            alignment: Alignment.topCenter,
                            child: PlaybackControlRow(store: store),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerController(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: constraints.copyWith(maxHeight: store.mainPlayerMaxHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GetIt.I<ToyControlButtonsProvider>().provideUtilizing(store),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 2,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            if (widget.item.artist != null)
              Text(
                widget.item.artist!,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 25),
            SeekBar(isPremium: widget.item.isPremium),
            PlaybackControlRow(store: store, sectionItem: widget.sectionItem),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return Transform.scale(
      scale: 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: context.colorScheme.onSurface,
          ),
          iconSize: 30,
        ),
      ),
    );
  }
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final Duration buffer;

  const MediaState(this.mediaItem, this.position, this.buffer);
}
