import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../player_store.dart';

class TranscriptViewerHeader extends SliverPersistentHeaderDelegate {
  const TranscriptViewerHeader(
      {required this.store,
      required this.onArrowPressed,
      required this.onFullscreenPressed});

  final PlayerStore store;
  final VoidCallback onArrowPressed;
  final VoidCallback onFullscreenPressed;

  static const double headerHeight = 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        color: context.colorScheme.surface.withValues(alpha: 0.8),
      ),
      child: Observer(builder: (_) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  'Lyrics',
                  style:
                      context.textTheme.headlineMedium?.copyWith(fontSize: 16),
                ),
              ),
            ),
            Align(
              alignment: store.transcriptViewerIsFullSize
                  ? Alignment.topRight
                  : Alignment.topCenter,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onArrowPressed,
                child: Icon(
                  size: 30,
                  store.transcriptViewerIsClosed
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ),
            if (!store.transcriptViewerIsFullSize)
              Align(
                alignment: Alignment.topRight,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onFullscreenPressed,
                  child: Icon(
                    Icons.crop_free_rounded,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  @override
  double get maxExtent => headerHeight;

  @override
  double get minExtent => headerHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
