import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/converter_to_section.dart';
import 'package:flutter_mobile_app_presentation/src/theme/theme.dart';
import 'package:flutter_mobile_app_presentation/src/theme/vibes_icons_v2.dart';
import 'package:vibes_common/vibes.dart';

import '../../cubit/channel_videos/channel_videos_cubit.dart';
import '../../cubit/favorites/favorites_cubit.dart';
import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../section_item_click_handler.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen(this.channel, {super.key});

  final Channel channel;

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  late ChannelVideosCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChannelVideosCubit(widget.channel.id.toString());
    _cubit.getChannelVideos();
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 140.0;
    const toolBarHeight = 60.0;
    const bottomPadding = 27.0;
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: headerHeight + toolBarHeight + bottomPadding,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(
                        top: toolBarHeight, bottom: bottomPadding),
                    child: Row(
                      children: [
                        if (widget.channel.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: widget.channel.image!,
                              width: headerHeight,
                              height: headerHeight,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.channel.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                              child: Text(
                                widget.channel.description ??
                                    widget.channel.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(top: 7),
                sliver: SliverToBoxAdapter(
                  child:
                      Text('Videos', style: TextStyle(color: AppColors.grey95)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 18),
                sliver: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
                    builder: (context, subscription) {
                  return BlocBuilder<ChannelVideosCubit, ChannelVideosState>(
                    bloc: _cubit,
                    builder: (context, state) {
                      widget.channel.videoList
                          .sort(compareByDescendingPublishDate);
                      final gridView = SectionGridView(
                        section: widget.channel.asSection(),
                        numColumns: 2,
                        childAspectRatio: 160 / 341,
                        childImageAspectRatio: 160 / 285,
                        bottomRightForItem: (item) =>
                            BlocBuilder<FavoritesCubit, FavoritesState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed: () =>
                                  BlocProvider.of<FavoritesCubit>(context)
                                      .toggleFavoriteVideo(
                                          item.id, item.title, item.thumbnail),
                              color: Colors.white,
                              icon: Icon(
                                state.containsTitle(item.title)
                                    ? VibesV2.favorite
                                    : VibesV2.favoriteStroke,
                                color: AppColors.vibesPink,
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                        onItemClicked: onSectionItemClickHandler,
                        shouldShowPremiumBadge: subscription.isNotActive(),
                      );
                      return state.maybeMap(videos: (state) {
                        addNewlyFetchedVideos(state.videos, gridView);
                        gridView.section.videos
                            ?.sort(compareByDescendingPublishDate);
                        return gridView;
                      }, orElse: (ChannelVideosState channelVideosState) {
                        return gridView;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int compareByDescendingPublishDate(Video a, Video b) {
    return (b.publishDate ?? DateTime(1970, 1, 1))
        .compareTo(a.publishDate ?? DateTime(1970, 1, 1));
  }

  void addNewlyFetchedVideos(List<Video> videos, SectionGridView gridView) {
    for (var newElement in videos) {
      if (gridView.section.videos != null &&
          !gridView.section.videos!
              .any((element) => element.id == newElement.id)) {
        gridView.section.videos!.add(newElement);
      }
    }
  }
}
