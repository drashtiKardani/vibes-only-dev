import 'package:flutter/material.dart';
import 'package:flutter_panel/src/extension/constraint_extension.dart';
import 'package:vibes_common/vibes.dart';

class ComparisonSymbolSelector extends StatelessWidget {
  final ValueNotifier<Constraint?> selectedComparison;

  const ComparisonSymbolSelector({super.key, required this.selectedComparison});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Constraint?>(
      builder: (context, comparison, widget) {
        return Wrap(
          spacing: 4,
          children: Constraint.values.map((e) {
            return FilledButton(
              onPressed: () {
                selectedComparison.value = e;
              },
              style: FilledButton.styleFrom(backgroundColor: e == comparison ? null : Colors.black),
              child: Text(e.mathSymbol),
            );
          }).toList(),
        );
      },
      valueListenable: selectedComparison,
    );
  }
}
