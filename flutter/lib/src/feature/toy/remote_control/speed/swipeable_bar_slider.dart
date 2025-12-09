import 'package:flutter/material.dart';

class SwipeableBarSlider extends StatefulWidget {
  final int totalBars;
  final double barWidth;
  final double barHeight;
  final int initialCompletedBars;
  final Color completedColor;
  final Color remainingColor;
  final ValueChanged<int>? onChanged;

  const SwipeableBarSlider({
    super.key,
    required this.totalBars,
    this.initialCompletedBars = 0,
    required this.completedColor,
    required this.remainingColor,
    this.onChanged,
    this.barWidth = 2,
    this.barHeight = 42,
  });

  @override
  State<SwipeableBarSlider> createState() => _SwipeableBarSliderState();
}

class _SwipeableBarSliderState extends State<SwipeableBarSlider> {
  late int completedBars;

  @override
  void initState() {
    super.initState();
    completedBars = widget.initialCompletedBars;
  }

  void _updateProgress(Offset localPosition, double maxWidth) {
    final double barWidth = maxWidth / widget.totalBars;
    final int tappedIndex =
        (localPosition.dx / barWidth).clamp(0, widget.totalBars).floor();
    setState(() => completedBars = tappedIndex);
    widget.onChanged?.call(completedBars);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            _updateProgress(details.localPosition, constraints.maxWidth);
          },
          onTapDown: (details) {
            _updateProgress(details.localPosition, constraints.maxWidth);
          },
          child: Row(
            spacing: 4,
            children: List.generate(
              widget.totalBars,
              (index) {
                final isCompleted = index < completedBars;
                return Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: widget.barWidth,
                      height: widget.barHeight,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? widget.completedColor
                            : widget.remainingColor,
                        borderRadius:
                            BorderRadius.circular(widget.barHeight / 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
