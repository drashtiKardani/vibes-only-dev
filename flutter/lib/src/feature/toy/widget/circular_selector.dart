import 'dart:math';

import 'package:flutter/material.dart';

class CircularSelector<T> extends StatefulWidget {
  final T groupValue;
  final Map<T, Widget> children;
  final ValueChanged<T> onValueChanged;

  final Color selectedColor;
  final Color unselectedColor;
  final Color smallerCircleColor;

  const CircularSelector({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
    this.selectedColor = const Color(0xFFCE4C68),
    this.unselectedColor = const Color(0xFF2A2A2A),
    this.smallerCircleColor = const Color(0xFF1A1A1A),
  });

  @override
  State createState() => _CircularSelectorState<T>();
}

class _CircularSelectorState<T> extends State<CircularSelector<T>> {
  late var selectedValue = widget.groupValue;
  static const insideToOutsideCirclesRatio = 130.0 / 150.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonDiameter =
            min(constraints.maxHeight, constraints.maxWidth / 2 - 6);
        final buttonsList = widget.children.entries
            .map(
              (valueToWidgetMap) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    selectedValue = valueToWidgetMap.key;
                    widget.onValueChanged(selectedValue);
                  }),
                  child: Container(
                    height: buttonDiameter,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: valueToWidgetMap.key == selectedValue
                          ? widget.selectedColor
                          : widget.unselectedColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      height: buttonDiameter * insideToOutsideCirclesRatio,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.smallerCircleColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: valueToWidgetMap.value,
                    ),
                  ),
                ),
              ),
            )
            .toList();
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: buttonsList,
        );
      },
    );
  }
}
