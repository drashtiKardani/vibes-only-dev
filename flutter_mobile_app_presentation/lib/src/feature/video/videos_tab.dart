import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/all_creators_screen.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/converter_to_section.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/videos_tab_store.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/all_channels_screen.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:vibes_common/vibes.dart';

import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../../cubit/video/video_cubit.dart';
import '../advice/advice_screen.dart';
import '../discovery/loading_shimmer.dart';
import '../section_item_click_handler.dart';

class VideosTab extends StatefulWidget {
  const VideosTab({super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab>
    with AutomaticKeepAliveClientMixin {
  late final VideoCubit _cubit;
  final videosTabStore = VideosTabStore();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<VideoCubit>(context)..getChannelVideos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: RefreshIndicator(
        backgroundColor: context.colorScheme.surface,
        edgeOffset: 0,
        onRefresh: () async {
          _cubit.getChannelVideos();
          videosTabStore.refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                buildTrendVideoSection(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      const Text('Channels',
                          style: TextStyle(color: AppColors.grey95)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                                value: _cubit,
                                child: const AllChannelsScreen()),
                          ),
                        ),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.vibesPink),
                        child: const Text('All Channels'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
                      builder: (context, subscription) {
                    return BlocBuilder<VideoCubit, VideoState>(
                        builder: (_, state) {
                      return state.maybeMap(channels: (state) {
                        return ShowcaseSection(
                          section: state.channels.asSection(),
                          hideTitle: true,
                          onItemClicked: onSectionItemClickHandler,
                          shouldShowPremiumBadge: subscription.isNotActive(),
                        );
                      }, orElse: (VideoState videoState) {
                        return const SizedBox(
                          height: 180,
                          child: DiscoveryLoadingShimmer(),
                        );
                      });
                    });
                  }),
                ),
                const Text('Our Favorites',
                    style: TextStyle(color: AppColors.grey95)),
                buildOurFavoritesSection(),
                Row(
                  children: [
                    const Text('Featured Creators',
                        style: TextStyle(color: AppColors.grey95)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (videosTabStore.videoCreators == null) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllCreatorsScreen(
                                  videoCreators:
                                      videosTabStore.videoCreators!)),
                        );
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.vibesPink),
                      child: const Text('All Creators'),
                    ),
                  ],
                ),
                Observer(builder: (context) {
                  if (videosTabStore.isLoading) {
                    return const SizedBox(
                      height: 180,
                      child: DiscoveryLoadingShimmer(),
                    );
                  }
                  if (videosTabStore.error != null) {
                    return Text('Error ${videosTabStore.error}');
                  }
                  return ShowcaseSection(
                    hideTitle: true,
                    section: videosTabStore.videoCreators!.asSection(),
                    shouldShowPremiumBadge: false,
                    onItemClicked: onSectionItemClickHandler,
                  );
                }),
              ]),
            ),
            // add extra padding to not overlap bottom bar
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: Colors.transparent,
                height: 100,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTrendVideoSection() {
    return Observer(builder: (context) {
      if (videosTabStore.videos?.isNotEmpty == true) {
        final trending =
            videosTabStore.videos?.where((v) => v.isTrend ?? false).toList();
        final displayedVideoAsTrending = trending?.isNotEmpty == true
            ? trending!.pickRandom()
            : videosTabStore.videos!.pickRandom();
        return Padding(
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdviceScreen(
                      null, displayedVideoAsTrending.id.toString())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trend Video',
                    style: TextStyle(color: AppColors.grey95)),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 335 / 211,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: displayedVideoAsTrending.trendImage ??
                          displayedVideoAsTrending.thumbnail ??
                          '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(displayedVideoAsTrending.title),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget buildOurFavoritesSection() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 16),
      child: Observer(builder: (context) {
        if (videosTabStore.isLoading) {
          return const SizedBox(
            height: 180,
            child: DiscoveryLoadingShimmer(),
          );
        }
        if (videosTabStore.error != null) {
          return Text('Error ${videosTabStore.error}');
        }
        final favoriteVideos =
            videosTabStore.videos!.where((v) => v.isFavorite ?? false);
        final displayedVideos = (favoriteVideos.isNotEmpty
                ? favoriteVideos
                : videosTabStore.videos!)
            .take(4)
            .toList()
          ..shuffle();

        return LayoutBuilder(builder: (context, constraints) {
          const gap = 15.0;
          const imgAspectRatio = 160 / 285;
          final itemWidth = (constraints.maxWidth - gap) / 2;

          Widget videoCard(Video video) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdviceScreen(null, video.id.toString())),
              ),
              child: SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: video.thumbnail ?? '',
                        width: itemWidth,
                        height: itemWidth / imgAspectRatio,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(video.title),
                  ],
                ),
              ),
            );
          }

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: displayedVideos.map(videoCard).toList(),
          );
        });
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

extension<T> on List<T> {
  T pickRandom() {
    return this[Random().nextInt(length)];
  }
}
