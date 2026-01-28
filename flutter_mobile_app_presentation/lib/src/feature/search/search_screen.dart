import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/theme/context_extension.dart';
import 'package:flutter_mobile_app_presentation/src/theme/vibes_icons_v3.dart';
import 'package:vibes_common/vibes.dart';

import '../../../flavors/flavor_config.dart';
import '../../../flavors/server_swapper.dart';
import '../../../gen/assets.gen.dart';
import '../../cubit/iap/in_app_purchase_cubit.dart';
import '../../cubit/iap/in_app_purchase_state.dart';
import '../../cubit/search/search_cubit.dart';
import '../../cubit/search/search_state.dart';
import '../../cubit/story_categories/category_cubit.dart';
import '../discovery/loading_shimmer.dart';
import '../section_item_click_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;
  late SearchCubit _cubit;
  late CategoryCubit _categoryCubit;
  void refreshOnServerSwap() => _categoryCubit.getCategories();

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<SearchCubit>(context);
    _controller = TextEditingController();
    _controller.addListener(() {
      _cubit.search(_controller.text);
    });

    _categoryCubit = CategoryCubit();
    _categoryCubit.getCategories();
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.addListener(refreshOnServerSwap);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.removeListener(refreshOnServerSwap);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Assets.images.background.image(
            filterQuality: FilterQuality.high,
            package: 'flutter_mobile_app_presentation',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.viewPadding.top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                'Categories',
                style: context.textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              _SearchBar(controller: _controller),
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      querySearchResult: (result) {
                        return _controller.text.isEmpty
                            ? SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                  bottom: kBottomNavigationBarHeight + 90,
                                ),
                                child: _tilesGrid(),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                    ),
                                itemCount: result.length,
                                itemBuilder: (context, index) {
                                  return _SearchItem(result[index]);
                                },
                              );
                      },
                      initial: () {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight + 90,
                          ),
                          child: _tilesGrid(),
                        );
                      },
                      orElse: (_) => const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        //   child: NestedScrollView(
        //     headerSliverBuilder:
        //         (BuildContext context, bool innerBoxIsScrolled) {
        //       return [_SearchBar(controller: _controller)];
        //     },
        //     body: BlocBuilder<SearchCubit, SearchState>(
        //         builder: (context, state) {
        //       return state.maybeWhen(
        //         querySearchResult: (result) {
        //           return CustomScrollView(
        //             slivers: [
        //               SliverList(
        //                 delegate: SliverChildBuilderDelegate((context, index) {
        //                   return Padding(
        //                     padding: const EdgeInsets.only(top: 12.0),
        //                     child: _SearchItem(result[index]),
        //                   );
        //                 }, childCount: result.length),
        //               ),
        //             ],
        //           );
        //         },
        //         initial: () {
        //           return CustomScrollView(
        //             slivers: [
        //               _title('Categories'),
        //               _tilesGrid(),
        //               _title('Explore'),
        //               _nonTileCategories(),
        //             ],
        //           );
        //         },
        //         orElse: (_) => CustomScrollView(slivers: [
        //           SliverList(
        //             delegate: SliverChildListDelegate([]),
        //           ),
        //         ]),
        //       );
        //     }),
        //   ),
        // ),
      ],
    );
  }

  Widget _tilesGrid() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      bloc: _categoryCubit,
      builder: (context, state) {
        return state.maybeMap(
          categories: (state) {
            List<Category> items = state.categories
                .where((element) => element.tileView ?? false)
                .toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 140,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return InkResponse(
                  child: _tile(items[index]),
                  onTap: () {
                    onSectionItemClickHandler(
                      context,
                      items[index].toSectionItem('Categories'),
                    );
                  },
                );
              },
            );
          },
          orElse: (state) {
            return const DiscoveryLoadingShimmer();
          },
        );
      },
    );
  }

  // List of categories which are not to be shown as tiles
  // Widget _nonTileCategories() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: BlocBuilder<CategoryCubit, CategoryState>(
  //       bloc: _categoryCubit,
  //       builder: (context, state) {
  //         return state.maybeMap(
  //           categories: (state) {
  //             List<Category> items = state.categories
  //                 .where((element) => !(element.tileView ?? false))
  //                 .toList();
  //             items.sort((a, b) {
  //               return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  //             });
  //             Section section = Section(
  //               title: 'Explore',
  //               style: Style.wrappedChips,
  //               categories: items,
  //               containingStories: [],
  //               characters: [],
  //               id: 1,
  //               isVisible: true,
  //               contentType: 's',
  //             );
  //             return BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
  //               builder: (context, subscription) {
  //                 return SectionHorizontalListView(
  //                   section: section,
  //                   onItemClicked: onSectionItemClickHandler,
  //                   shouldShowPremiumBadge: subscription.isNotActive(),
  //                 );
  //               },
  //             );
  //           },
  //           orElse: (state) {
  //             return const SizedBox.shrink();
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _tile(Category category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        category.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Row(
          spacing: 10,
          children: [
            if (value.text.length > 1)
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    controller.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: const Icon(VibesV3.arrowLeft),
                  iconSize: 30,
                ),
              ),
            Expanded(
              child: AnimatedContainer(
                duration: Durations.medium1,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                child: Row(
                  spacing: 14,
                  children: [
                    Icon(
                      VibesV3.searchLined,
                      color: context.colorScheme.onSurface,
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search categories',
                          hintStyle: TextStyle(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// @Deprecated('use ShowcaseListItem')
// TODO commenting the above line is a temporary solution for passing the analyzer
class _SearchItem extends StatelessWidget {
  const _SearchItem(this.result);

  final SearchResult result;

  SectionItem? get sectionItem {
    if (result.story != null) {
      var story = result.story!;
      return SectionItem(
        id: story.id.toString(),
        title: story.title,
        description: story.description,
        thumbnail: story.thumbnail(Style.showcaseMedium),
        type: SectionType.story,
        heroTag: 'search_story#${story.id}',
      );
    } else if (result.character != null) {
      var character = result.character!;
      return SectionItem(
        id: character.id.toString(),
        title: character.firstName ?? '',
        //TODO change
        description: 'Character',
        thumbnail: character.profileImage,
        type: SectionType.character,
        heroTag: 'search_character#${character.id}',
      );
    } else if (result.video != null) {
      var video = result.video!;
      return SectionItem(
        id: video.id.toString(),
        title: video.title,
        //TODO change
        description: 'Video',
        thumbnail: video.thumbnail ?? '',
        type: SectionType.video,
        heroTag: 'search_video#${video.id}',
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
      builder: (context, subscription) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: sectionItem != null
              ? showcaseSmall(
                  context,
                  sectionItem!,
                  onSectionItemClickHandler,
                  subscription.isNotActive(),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
