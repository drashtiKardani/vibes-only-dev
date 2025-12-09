import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibes_common/vibes.dart';

import '../../audio/audio_handler.dart';
import '../../audio/media_item_extras.dart';
import '../../cubit/favorites/favorites_cubit.dart';
import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../../cubit/story/story_cubit.dart';
import '../../cubit/story/story_state.dart';
import '../../dialog/go_premium_dialog.dart';
import '../section_item_click_handler.dart';
import '../story_player/player_screen.dart';
import '../story_player/toy_command_model.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen(this.item, {super.key});

  final SectionItem item;

  @override
  State createState() => _StoryDetailScreenState();
}

class _Tuple {
  final PlaybackState playbackState;
  final MediaItem? mediaItem;

  _Tuple(this.playbackState, this.mediaItem);
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late StoryCubit _cubit;
  late StreamSubscription<_Tuple> _playerListener;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _cubit = StoryCubit();
    _cubit.getStoryDetail(widget.item.id);

    _playerListener =
        Rx.combineLatest2<PlaybackState, MediaItem?, _Tuple>(
          VibesAudioHandler.instance.playbackState,
          VibesAudioHandler.instance.mediaItem,
          (playbackState, mediaItem) => _Tuple(playbackState, mediaItem),
        ).listen((tuple) {
          if (tuple.playbackState.playing != isPlaying) {
            isPlaying =
                tuple.playbackState.playing &&
                tuple.mediaItem?.title == widget.item.title;
            if (mounted) {
              setState(() {});
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: Transform.scale(
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
        ),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              return Transform.scale(
                scale: 0.85,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  child: IconButton(
                    onPressed: () {
                      BlocProvider.of<FavoritesCubit>(
                        context,
                      ).toggleFavoriteStory(
                        widget.item.title,
                        widget.item.thumbnail,
                        [],
                        widget.item,
                      );
                    },
                    icon: Icon(
                      state.containsTitle(widget.item.title)
                          ? VibesV2.favorite
                          : VibesV2.favoriteStroke,
                    ),
                    iconSize: 30,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
        builder: (context, subscription) {
          return BlocBuilder<StoryCubit, StoryState>(
            bloc: _cubit,
            builder: (context, state) {
              return state.maybeWhen(
                detailRetrieved: (story) {
                  String? backgroundCover = story.imageCover;

                  return Stack(
                    children: [
                      if (backgroundCover != null)
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: backgroundCover,
                          imageBuilder: (context, imageProvider) {
                            return ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 80,
                                sigmaY: 80,
                              ),
                              child: Container(
                                height: size.height,
                                width: size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      _Detail(
                        title: story.title,
                        description: story.description,
                        heroTag: widget.item.heroTag,
                        categories: story.categories,
                        coverUrl: story.imageCover ?? '',
                        audioDuration: story.audioLengthSeconds ?? 0,
                        audioUrl: story.audio ?? '',
                        playing: isPlaying,
                        onPlayPressed: () {
                          if (!isPlaying) {
                            if (subscription.isNotActive() &&
                                (story.paid ?? false)) {
                              return showGoPremiumBottomSheet(context);
                            }
                            MediaItem item = MediaItem(
                              id: story.audio ?? '',
                              title: story.title,
                              artUri: Uri.parse(widget.item.thumbnail),
                              extras: {
                                MediaItemExtras.premiumKey: story.paid ?? false,
                                MediaItemExtras.storyIdKey: story.id,
                                MediaItemExtras.storyTranscriptKey:
                                    story.transcript ?? '',
                              },
                            );
                            VibesAudioHandler.instance.playMediaItem(item);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(
                                  item: item,
                                  sectionItem: widget.item,
                                  toyCommands: StoryBeatDecoder.decode(
                                    story.beat,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            VibesAudioHandler.instance.pause();
                          }
                        },
                        sections: const [],
                        sectionItem: widget.item,
                        premium: story.paid ?? false,
                      ),
                    ],
                  );
                },
                orElse: (state) {
                  return _Detail(
                    title: widget.item.title,
                    description: widget.item.description,
                    heroTag: widget.item.heroTag,
                    categories: const [],
                    sections: const [],
                    playing: isPlaying,
                    onPlayPressed: () {},
                    sectionItem: widget.item,
                    premium: widget.item.premium ?? false,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _playerListener.cancel();
    super.dispose();
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.title,
    required this.description,
    required this.heroTag,
    required this.categories,
    required this.sections,
    required this.playing,
    required this.onPlayPressed,
    this.coverUrl = '',
    this.audioDuration = 0,
    this.audioUrl = '',
    required this.sectionItem,
    required this.premium,
  });

  final String heroTag;
  final String title;
  final String description;
  final List<Category> categories;
  final String coverUrl;
  final List<Section>? sections;
  final int audioDuration;
  final String audioUrl;
  final bool playing;
  final VoidCallback onPlayPressed;
  final SectionItem sectionItem;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    Widget header;
    double headerHeight = context.mediaQuery.size.height * 0.45;

    if (coverUrl.isNotEmpty) {
      header = CachedNetworkImage(
        height: headerHeight,
        fit: BoxFit.cover,
        imageUrl: coverUrl,
      );
    } else {
      header = Shimmer.fromColors(
        period: const Duration(milliseconds: 2000),
        baseColor: Colors.grey.withValues(alpha: 0.15),
        highlightColor: Colors.grey.withValues(alpha: 0.1),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: headerHeight,
          color: Colors.black,
        ),
      );
    }
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
        top: context.mediaQuery.viewPadding.top + 130,
        bottom: context.mediaQuery.viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: headerHeight,
            width: context.mediaQuery.size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
                builder: (context, subscription) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Hero(tag: heroTag, child: header),
                      if (subscription.isNotActive() && premium) ...[
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/icon_premium.svg',
                          package: 'vibes_common',
                          width: 40,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 4,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            _toMMSS(audioDuration),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 12,
              color: context.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onPlayPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: context.colorScheme.surface.withValues(alpha: 0.50),
              ),
              child: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: playing
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    color: context.colorScheme.onSurface,
                  ),
                  Text(
                    'Play',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 12,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: categories
                .map((item) {
                  SectionItem sectionItem = item.toSectionItem('detail-$title');
                  return InkWell(
                    onTap: () {
                      onSectionItemClickHandler(context, sectionItem);
                    },
                    child: Text(
                      sectionItem.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 12,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  );
                })
                .toList()
                .separateBuilder(() {
                  return Container(
                    height: 18,
                    width: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

String _toMMSS(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final minutesString = '$minutes'.padLeft(2, '0');
  final secondsString = '$seconds'.padLeft(2, '0');
  if (minutesString == '00' && secondsString == '00') return '';
  return '$minutesString:$secondsString';
}

extension on List<Widget> {
  List<Widget> separateBuilder(Widget Function() builder) {
    return length <= 1
        ? this
        : sublist(1).fold([first], (r, element) => [...r, builder(), element]);
  }
}
