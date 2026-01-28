import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'model.dart';

typedef OnItemClicked = void Function(BuildContext, SectionItem);

Widget chips(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
) {
  return CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () => onItemClicked?.call(context, item),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        item.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    ),
  );
}

Widget avatar(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
) {
  return _OnPressed(
    item: item,
    onItemClicked: onItemClicked,
    child: SizedBox(
      width: 100,
      height: 130,
      child: Column(
        children: [
          Hero(
            tag: item.heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: item.thumbnail,
                width: 100,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              item.title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget card(
  BuildContext context,
  int index,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  bool? shouldShowStoryReadIndicator,
}) {
  return _CardItem(
    item: item,
    index: index,
    onItemClicked: onItemClicked,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

Widget swiper(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  bool? shouldShowStoryReadIndicator,
}) {
  return _SwiperItem(
    item: item,
    onItemClicked: onItemClicked,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

Widget promotion(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  bool? shouldShowStoryReadIndicator,
}) {
  return _PromotionItem(
    item: item,
    onItemClicked: onItemClicked,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

Widget showcaseSmall(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge,
) {
  return _ShowcaseHorizontalItem(
    item: item,
    height: 60,
    onItemClicked: onItemClicked,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
  );
}

Widget showcaseMedium(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  int titleMaxLine = 1,
  bool? shouldShowStoryReadIndicator,
}) {
  return _ShowcaseItem(
    item: item,
    width: 140,
    imageHeight: 140,
    onItemClicked: onItemClicked,
    titleMaxLine: titleMaxLine,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

Widget showcaseCustom(
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  int titleMaxLine = 1,
  bool? shouldShowStoryReadIndicator,
  required double width,
  required double imageHeight,
  Widget? bottomRight,
  double? imageBorderRadius,
}) {
  return _ShowcaseItem(
    item: item,
    width: width,
    imageHeight: imageHeight,
    onItemClicked: onItemClicked,
    titleMaxLine: titleMaxLine,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
    bottomRight: bottomRight,
    imageBorderRadius: imageBorderRadius,
  );
}

Widget showcaseExpanded(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  bool? shouldShowStoryReadIndicator,
}) {
  return _ShowcaseItem(
    item: item,
    width: 300,
    imageHeight: 140,
    descMaxLine: 3,
    onItemClicked: onItemClicked,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

Widget showcaseTall(
  BuildContext context,
  SectionItem item,
  OnItemClicked? onItemClicked,
  bool shouldShowPremiumBadge, {
  bool? shouldShowStoryReadIndicator,
}) {
  return _ShowcaseItem(
    item: item,
    width: 150,
    imageHeight: 180,
    onItemClicked: onItemClicked,
    titleMaxLine: 2,
    descMaxLine: 2,
    shouldShowPremiumBadge: shouldShowPremiumBadge,
    shouldShowStoryReadIndicator: shouldShowStoryReadIndicator,
  );
}

class _OnPressed extends StatelessWidget {
  const _OnPressed({
    required this.child,
    required this.item,
    required this.onItemClicked,
  });

  final Widget child;
  final SectionItem item;
  final OnItemClicked? onItemClicked;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onItemClicked?.call(context, item),
      child: child,
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final bool? show;
  final Widget child;
  static const double _defaultSize = 60;
  final double size;

  const _PremiumBadge({
    required this.show,
    required this.child,
    this.size = _defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (show == true) ...[
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
          SvgPicture.asset(
            'assets/images/icon_premium.svg',
            package: 'vibes_common',
            width: 40 * size / _defaultSize,
          ),
        ],
      ],
    );
  }
}

class _StoryReadIndicator extends StatelessWidget {
  const _StoryReadIndicator({required this.child, required this.shouldShow});

  final Widget child;
  final bool shouldShow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (shouldShow)
          Positioned(
            top: 4,
            right: 4,
            child: SvgPicture.asset(
              'assets/images/icon_story_read.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
      ],
    );
  }
}

class _ShowcaseItem extends StatelessWidget {
  const _ShowcaseItem({
    required this.item,
    required this.width,
    required this.imageHeight,
    this.titleMaxLine = 1,
    this.descMaxLine = 1,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicator,
    this.bottomRight,
    double? imageBorderRadius,
  }) : imageBorderRadius = imageBorderRadius ?? 10.0;

  final SectionItem item;
  final double width;
  final double imageHeight;
  final int titleMaxLine;
  final int descMaxLine;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool? shouldShowStoryReadIndicator;
  final Widget? bottomRight;
  final double imageBorderRadius;

  @override
  Widget build(BuildContext context) {
    return _OnPressed(
      item: item,
      onItemClicked: onItemClicked,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(imageBorderRadius),
              child: Hero(
                tag: item.heroTag,
                child: _PremiumBadge(
                  show: shouldShowPremiumBadge && (item.premium ?? false),
                  child: _StoryReadIndicator(
                    shouldShow: shouldShowStoryReadIndicator ?? false,
                    child: CachedNetworkImage(
                      imageUrl: item.thumbnail,
                      width: width,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      item.title,
                      maxLines: titleMaxLine,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                if (bottomRight != null) bottomRight!,
              ],
            ),
            Text(
              item.description,
              maxLines: descMaxLine,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseHorizontalItem extends StatelessWidget {
  const _ShowcaseHorizontalItem({
    required this.item,
    required this.height,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
  }) : imageHeight = height;

  final SectionItem item;
  final double height;
  final double imageHeight;
  final int titleMaxLine = 1;
  final int descMaxLine = 1;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;

  @override
  Widget build(BuildContext context) {
    return _OnPressed(
      item: item,
      onItemClicked: onItemClicked,
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: item.heroTag,
                child: _PremiumBadge(
                  size: 30,
                  show: shouldShowPremiumBadge && (item.premium ?? false),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    width: imageHeight * 2,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: titleMaxLine,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    item.description,
                    maxLines: descMaxLine,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionItem extends StatelessWidget {
  const _PromotionItem({
    required this.item,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicator,
  });

  final SectionItem item;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool? shouldShowStoryReadIndicator;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _OnPressed(
        item: item,
        onItemClicked: onItemClicked,
        child: SizedBox(
          width: size.width * 0.75,
          child: Stack(
            children: [
              Hero(
                tag: item.heroTag,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: item.thumbnail,
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: _PremiumBadge(
                      show: shouldShowPremiumBadge && (item.premium ?? false),
                      child: _StoryReadIndicator(
                        shouldShow: shouldShowStoryReadIndicator ?? false,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                        child: Column(
                          spacing: 6,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            Text(
                              item.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  const _CardItem({
    required this.item,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicator,
    required this.index,
  });

  final int index;
  final SectionItem item;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool? shouldShowStoryReadIndicator;

  @override
  Widget build(BuildContext context) {
    String tags =
        "#${item.tags.getRange(0, min(item.tags.length, 2)).join('  #')}";

    double sizeWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: sizeWidth * 0.78,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _OnPressed(
                item: item,
                onItemClicked: onItemClicked,
                child: Row(
                  children: [
                    Hero(
                      tag: item.heroTag,
                      child: _PremiumBadge(
                        show: shouldShowPremiumBadge && (item.premium ?? false),
                        child: _StoryReadIndicator(
                          shouldShow: shouldShowStoryReadIndicator ?? false,
                          child: CachedNetworkImage(
                            width: sizeWidth * 0.3,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: item.thumbnail,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: item.backgroundColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.displaySmall,
                              maxLines: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item.description,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.8),
                                    ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              tags,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _GradientNumberText(index: index),
        ],
      ),
    );
  }
}

class _GradientNumberText extends StatelessWidget {
  final int index;

  const _GradientNumberText({required this.index});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onSurface,
              const Color(0xff999999),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: Text(
          '${index + 1}',
          overflow: TextOverflow.ellipsis,
          strutStyle: const StrutStyle(
            fontSize: 70,
            forceStrutHeight: true,
            height: 0,
          ),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 70,
            height: 0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SwiperItem extends StatelessWidget {
  final SectionItem item;
  final OnItemClicked? onItemClicked;
  final bool shouldShowPremiumBadge;
  final bool? shouldShowStoryReadIndicator;

  const _SwiperItem({
    required this.item,
    this.onItemClicked,
    required this.shouldShowPremiumBadge,
    this.shouldShowStoryReadIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Hero(
            tag: item.heroTag,
            child: _PremiumBadge(
              show: shouldShowPremiumBadge && (item.premium ?? false),
              child: _StoryReadIndicator(
                shouldShow: shouldShowStoryReadIndicator ?? false,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(),
                child: Column(
                  spacing: 6,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 6,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              Text(
                                item.tags.join(' | '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        _OnPressed(
                          item: item,
                          onItemClicked: onItemClicked,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              'Listen now',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
