import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/favorites/favorites_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/converter_to_section.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

import '../../../theme.dart';
import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../section_item_click_handler.dart';

class VideoCreatorScreen extends StatefulWidget {
  const VideoCreatorScreen(
      {super.key,
      required this.id,
      required this.name,
      required this.bio,
      required this.image});

  final String id;
  final String name;
  final String bio;
  final String image;

  @override
  State<VideoCreatorScreen> createState() => _VideoCreatorScreenState();
}

class _VideoCreatorScreenState extends State<VideoCreatorScreen> {
  AllVideo? creatorVideos;

  @override
  void initState() {
    super.initState();
    GetIt.I<VibeApiNew>()
        .getVideos(limit: 100, offset: 0, creatorId: widget.id)
        .then((videos) {
      setState(() => creatorVideos = videos);
    });
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: widget.image,
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
                              widget.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                              child: Text(
                                widget.bio,
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
                  if (creatorVideos != null) {
                    return SectionGridView(
                      section: creatorVideos!.results.asSection(),
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
                  } else {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
