import 'package:flutter/material.dart';
import 'package:vibes_common/src/model/models.dart';

import 'mapper.dart';
import 'model.dart';
import 'properties.dart';
import 'section_items.dart';

export 'mapper.dart';

class SectionListItem extends StatelessWidget {
  const SectionListItem({
    super.key,
    required this.sectionItem,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
  });
  final SectionItem sectionItem;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;

  @override
  Widget build(BuildContext context) {
    return showcaseSmall(
      context,
      sectionItem,
      onItemClicked,
      shouldShowPremiumBadge,
    );
  }
}

typedef OnSectionTitleClicked = void Function(BuildContext, Section);

class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({
    super.key,
    required this.section,
    this.shouldFlicker = false,
    this.onSectionTitleClicked,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicatorFor,
    this.hideTitle = false,
  });

  final Section section;
  final bool shouldFlicker;
  final OnSectionTitleClicked? onSectionTitleClicked;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool Function(SectionItem)? shouldShowStoryReadIndicatorFor;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => onSectionTitleClicked?.call(context, section),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    section.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        SectionHorizontalListView(
          section: section,
          onItemClicked: onItemClicked,
          shouldShowPremiumBadge: shouldShowPremiumBadge,
          shouldShowStoryReadIndicatorFor: shouldShowStoryReadIndicatorFor,
          pageController: PageController(),
        ),
      ],
    );
  }
}

class SectionHorizontalListView extends StatelessWidget {
  const SectionHorizontalListView({
    super.key,
    required this.section,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicatorFor,
    this.pageController,
  });

  final Section section;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool Function(SectionItem)? shouldShowStoryReadIndicatorFor;
  final PageController? pageController;

  Style get style => section.style;

  List<SectionItem> get items => _mapItemsToSection(section);

  List<SectionItem> _mapItemsToSection(Section section) {
    if (section.containingStories.isNotEmpty) {
      return section.containingStories.map((e) {
        return e.toSectionItem(section.title, style, parentSection: section);
      }).toList();
    } else if (section.categories.isNotEmpty) {
      return section.categories
          .map((e) => e.toSectionItem(section.title))
          .toList();
    } else if (section.characters.isNotEmpty) {
      return section.characters.map((e) {
        return SectionItem(
          id: e.id.toString(),
          title: e.firstName ?? '',
          description: '',
          thumbnail: e.profileImage,
          type: SectionType.character,
          heroTag: section.title + e.id.toString(),
        );
      }).toList();
    } else if (section.videos != null && section.videos!.isNotEmpty) {
      return section.videos!.map((e) {
        return e.toSectionItem(section.title, style, section.id.toString());
      }).toList();
    } else if (section.channels.isNotEmpty) {
      return section.channels.map((e) {
        return SectionItem(
          id: e.id.toString(),
          title: e.title,
          description: e.description ?? '',
          thumbnail: e.image ?? '',
          type: SectionType.channel,
          heroTag: section.title,
        );
      }).toList();
    } else if (section.videoCreators.isNotEmpty) {
      return section.videoCreators.map((e) {
        return SectionItem(
          id: e.id.toString(),
          title: e.name,
          description: e.bio,
          thumbnail: e.photo,
          type: SectionType.videoCreator,
          heroTag: e.name,
        );
      }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = this.pageController ?? PageController();

    int grid = style.grids;
    if (grid > 1) {
      //TODO: currently not supporting grid view
      return const SizedBox.shrink();
    } else if (grid == 1) {
      if (section.contentType == 'NEW_STORIES') {
        return AnimatedBuilder(
          animation: pageController,
          builder: (context, _) {
            final int currentIndex = pageController.pageOffset.floor();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: items.length,
                    controller: pageController,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _findShowcaseItemBuilder(
                        context,
                        index,
                        items[index],
                        onItemClicked,
                        shouldShowPremiumBadge,
                        titleMaxLine: section.contentType == 'video' ? 2 : 1,
                        shouldShowStoryReadIndicator:
                            shouldShowStoryReadIndicatorFor != null &&
                                shouldShowStoryReadIndicatorFor!(
                                  items[index],
                                ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: InfiniteDotIndicator(
                      totalDots: items.length,
                      currentIndex: currentIndex,
                      activeColor: Theme.of(context).colorScheme.onSurface,
                      inactiveColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
      return SizedBox(
        width: double.infinity,
        height: section.contentType == 'video' ? 220 : style.height,
        child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(width: style.spacing);
          },
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _findShowcaseItemBuilder(
              context,
              index,
              items[index],
              onItemClicked,
              shouldShowPremiumBadge,
              titleMaxLine: section.contentType == 'video' ? 2 : 1,
              shouldShowStoryReadIndicator:
                  shouldShowStoryReadIndicatorFor != null &&
                      shouldShowStoryReadIndicatorFor!(
                        items[index],
                      ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: style.height,
      child: ListView.separated(
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => SizedBox(width: style.spacing),
        itemBuilder: (context, index) {
          return _findShowcaseItemBuilder(
            context,
            index,
            items[index],
            onItemClicked,
            shouldShowPremiumBadge,
          );
        },
      ),
    );
  }

  Widget _findShowcaseItemBuilder(
    BuildContext context,
    int index,
    SectionItem item,
    OnItemClicked? onItemClicked,
    bool shouldShowPremiumBadge, {
    int titleMaxLine = 1,
    bool? shouldShowStoryReadIndicator,
  }) {
    switch (style) {
      case Style.avatar:
        return avatar(context, item, onItemClicked);
      case Style.card:
        return card(
          context,
          index,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
      case Style.promotionFull:
        return promotion(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
      case Style.showcaseExpanded:
        return showcaseExpanded(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
      case Style.showcaseMedium:
        return showcaseMedium(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          titleMaxLine: titleMaxLine,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
      case Style.showcaseTall:
        return swiper(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
      // return showcaseTall(
      //   context,
      //   item,
      //   onItemClicked,
      //   shouldShowPremiumBadge,
      //   shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
      // );
      case Style.showcaseSmall:
        return showcaseSmall(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
        );
      case Style.wrappedChips:
        return chips(context, item, onItemClicked);
      case Style.swiper:
        return swiper(
          context,
          item,
          onItemClicked,
          shouldShowPremiumBadge,
          shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
        );
    }
  }
}

class SectionGridView extends SectionHorizontalListView {
  const SectionGridView({
    super.key,
    required super.section,
    super.onItemClicked,
    required super.shouldShowPremiumBadge,
    this.numColumns = 3,
    this.childAspectRatio = 95.0 / 225.0,
    this.childImageAspectRatio = 95 / 185,
    this.bottomRightForItem,
  });

  final int numColumns;
  final double childAspectRatio;
  final double childImageAspectRatio;
  final Widget Function(SectionItem)? bottomRightForItem;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const hGap = 15.0;
        final columnWidth = (constraints.asBoxConstraints().maxWidth -
                hGap * (numColumns - 1)) /
            numColumns;
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numColumns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: hGap,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return showcaseCustom(
                items[index],
                onItemClicked,
                shouldShowPremiumBadge,
                titleMaxLine: 2,
                width: columnWidth,
                imageHeight: columnWidth / childImageAspectRatio,
                bottomRight: bottomRightForItem?.call(items[index]),
                imageBorderRadius: 15,
              );
            },
            childCount: items.length,
          ),
        );
      },
    );
  }
}

extension on PageController {
  double get pageOffset => hasClients ? page ?? 0 : 0;
}

class InfiniteDotIndicator extends StatelessWidget {
  final int totalDots;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final Size activeSize;
  final Size size;
  final Duration duration;
  final Curve curve;

  const InfiniteDotIndicator({
    super.key,
    required this.totalDots,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
    this.activeSize = const Size(22, 6),
    this.size = const Size(6, 6),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
  });

  @override
  Widget build(BuildContext context) {
    const int maxVisibleDots = 5;

    List<int> getVisibleDotIndexes() {
      if (totalDots <= maxVisibleDots) {
        return List.generate(totalDots, (i) => i);
      }

      int startIndex;
      if (currentIndex < 2) {
        startIndex = 0;
      } else if (currentIndex >= totalDots - 2) {
        startIndex = totalDots - maxVisibleDots;
      } else {
        startIndex = currentIndex - 2;
      }

      return List.generate(maxVisibleDots, (i) => startIndex + i);
    }

    final visibleIndexes = getVisibleDotIndexes();

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      mainAxisAlignment: MainAxisAlignment.center,
      children: visibleIndexes.map((dotIndex) {
        final bool isActive = dotIndex == currentIndex;
        final Size dotSize = isActive ? activeSize : size;
        final Color dotColor = isActive ? activeColor : inactiveColor;

        return AnimatedContainer(
          duration: duration,
          curve: curve,
          width: dotSize.width,
          height: dotSize.height,
          decoration: BoxDecoration(
            color: dotColor,
            borderRadius: BorderRadius.circular(dotSize.height / 2),
          ),
        );
      }).toList(),
    );
  }
}
