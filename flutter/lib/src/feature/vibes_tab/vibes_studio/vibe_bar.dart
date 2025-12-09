import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/config.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/data/vibe_timeline.dart';

import 'choose_pattern_screen.dart';
import 'data/vibe_bar_data.dart';

class VibeBar extends StatelessWidget {
  const VibeBar({super.key, required this.data, required this.store});

  final VibeBarData data;
  final VibeTimeline store;
  static const double selectedBorderWidth = 2.0;
  static const double resizerBorderWidth = selectedBorderWidth * 5;
  static const double deleteButtonWidth = 34.0;
  static const double deleteButtonMargin = 20.0;

  static double get outsideReservedSpace {
    return deleteButtonWidth + deleteButtonMargin;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidthForBar =
            constraints.maxWidth - outsideReservedSpace;

        void resizeIntensity(double dx) {
          final int newIntensity =
              data.intensity + (dx / availableWidthForBar * 100).toInt();
          if (newIntensity >= 0 && newIntensity <= 99) {
            data.intensity = newIntensity;
          }
        }

        void resizeDuration(double dx) {
          final double newDuration = dx / VibeStudioConfig.heightOfOneSecondBar;
          if (newDuration >= VibeStudioConfig.initialDuration) {
            // To resize in steps of 10s
            data.duration =
                newDuration - (newDuration % VibeStudioConfig.initialDuration);
          }
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => store.toggleSelectForResizing(data),
            child: Observer(
              builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height:
                          data.duration * VibeStudioConfig.heightOfOneSecondBar,
                      width: availableWidthForBar * data.intensity / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        border: data.selected
                            ? Border.all(
                                width: selectedBorderWidth,
                                color: Colors.white,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              )
                            : Border.all(
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                      ),
                      child: Stack(
                        children: [
                          if (data.selected) ...[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: resizerBorderWidth,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            VerticalResizer(
                              onDrag: resizeDuration,
                              store: store,
                              side: VerticalResizerSide.top,
                            ),
                            HorizontalResizer(
                              side: HorizontalResizerSide.right,
                              onDrag: resizeIntensity,
                              store: store,
                            ),
                            VerticalResizer(
                              onDrag: resizeDuration,
                              store: store,
                              side: VerticalResizerSide.bottom,
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: VibeStudioConfig.vibeBarTimeBoxDim,
                                  height: VibeStudioConfig.vibeBarTimeBoxDim,
                                  margin: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${(data.duration ~/ 60).toString().padLeft(2, '0')}'
                                    ':${(data.duration.toInt() % 60).toString().padLeft(2, '0')}',
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
                                          color: context.colorScheme.surface,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: data.selected
                                        ? () {
                                            Navigator.of(context)
                                                .push<int?>(
                                                  MaterialPageRoute(
                                                    builder: (_) {
                                                      return const ChoosePatternScreen();
                                                    },
                                                  ),
                                                )
                                                .then((
                                                  replacementPatternIndex,
                                                ) {
                                                  if (replacementPatternIndex ==
                                                      null) {
                                                    // Do nothing; user has closed it without choosing a pattern.
                                                  } else {
                                                    data.patternIndex =
                                                        replacementPatternIndex;
                                                  }
                                                });
                                          }
                                        : () {
                                            store.toggleSelectForResizing(data);
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          const double patternWidth = 80.0;
                                          final numRepeat =
                                              (constraints.maxWidth /
                                                      patternWidth)
                                                  .ceil();
                                          return SingleChildScrollView(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Observer(
                                              builder: (context) {
                                                return Row(
                                                  children: [
                                                    for (
                                                      int i = 0;
                                                      i < numRepeat;
                                                      i++
                                                    )
                                                      VibePatters.getByIndex(
                                                        data.patternIndex,
                                                        width: patternWidth,
                                                        color: context
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    HorizontalResizer(
                      onDrag: resizeIntensity,
                      store: store,
                      side: HorizontalResizerSide.right,
                      child: Container(
                        width: deleteButtonMargin,
                        height:
                            data.duration *
                            VibeStudioConfig.heightOfOneSecondBar,
                        // without, Listener does not listen.
                        color: Colors.transparent,
                      ),
                    ),
                    if (data.selected)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => store.removeBar(data),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            size: 18,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum VerticalResizerSide { top, bottom }

class VerticalResizer extends StatelessWidget {
  const VerticalResizer({
    super.key,
    required this.onDrag,
    required this.store,
    this.child,
    required this.side,
  });

  final Function(double dy) onDrag;
  final VibeTimeline store;
  final VerticalResizerSide side;

  /// The child of this resizer. If child is null, the standard resizer UI is used instead.
  /// This is useful for creating an empty space above the bar, that can extend the length of resize tap area.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => store.aBarIsBeingResized = true,
      onPointerMove: (details) => onDrag(details.localPosition.dy),
      onPointerUp: (_) => store.aBarIsBeingResized = false,
      child:
          child ??
          Align(
            alignment: side == VerticalResizerSide.top
                ? Alignment.topCenter
                : Alignment.bottomCenter,
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: side == VerticalResizerSide.top ? -7.5 : null,
                    bottom: side == VerticalResizerSide.bottom ? -7.5 : null,
                    child: const Icon(VibesV2.resizeTop, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

enum HorizontalResizerSide { left, right }

/// Note the use of [Listener] instead of [GestureDetector].
/// It seems, because [VibeBar]s are placed inside a [ReorderableListView], gestures are being eaten by the list view.
class HorizontalResizer extends StatelessWidget {
  const HorizontalResizer({
    super.key,
    required this.onDrag,
    required this.store,
    required this.side,
    this.child,
  });

  final Function(double dx) onDrag;
  final VibeTimeline store;
  final HorizontalResizerSide side;

  /// The child of this resizer. If child is null, the standard resizer UI is used instead.
  /// This is useful for creating an empty space beside the bar, that can extend the length of resize tap area.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => store.aBarIsBeingResized = true,
      onPointerMove: (details) => onDrag(details.delta.dx),
      onPointerUp: (_) => store.aBarIsBeingResized = false,
      child:
          child ??
          Align(
            alignment: side == HorizontalResizerSide.left
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: SizedBox(
              width: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: side == HorizontalResizerSide.left ? -7.5 : null,
                    right: side == HorizontalResizerSide.right ? -7.5 : null,
                    child: const Icon(VibesV2.resizeRight, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
