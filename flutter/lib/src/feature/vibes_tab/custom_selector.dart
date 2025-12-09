import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

/// A selector that supports up to 3 options ([children]).
/// The [groupValue] determines which option is currently selected,
/// and [onValueChanged] is called when a new option is selected.
class CustomSelector<T> extends StatelessWidget {
  const CustomSelector({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  final T groupValue;
  final Map<T, String> children;
  final ValueChanged<T> onValueChanged;

  static const double _selectorHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: 4,
        children: children.entries.map((valueToWidgetMap) {
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(valueToWidgetMap.key),
              child: AnimatedContainer(
                  duration: Durations.medium2,
                  height: _selectorHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: groupValue == valueToWidgetMap.key
                        ? context.colorScheme.onSurface
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    valueToWidgetMap.value,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: groupValue == valueToWidgetMap.key
                          ? Colors.black
                          : Colors.white,
                    ),
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A selector that supports up to 3 options ([children]).
/// The [groupValue] determines which option is currently selected,
/// and [onValueChanged] is called when a new option is selected.
class CustomRadioSelector<T> extends StatelessWidget {
  const CustomRadioSelector({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  final T groupValue;
  final Map<T, String> children;
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      children: children.entries.map((valueToWidgetMap) {
        return Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 20,
              child: Radio<T>(
                value: valueToWidgetMap.key,
                groupValue: groupValue,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return context.colorScheme.onSurface;
                  }
                  return context.colorScheme.onSurface.withValues(alpha: 0.2);
                }),
                activeColor: context.colorScheme.onSurface,
                onChanged: (value) {
                  if (value == null) return;
                  onValueChanged(value);
                },
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => onValueChanged(valueToWidgetMap.key),
              child: Text(
                valueToWidgetMap.value,
                style: context.textTheme.titleMedium,
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}
