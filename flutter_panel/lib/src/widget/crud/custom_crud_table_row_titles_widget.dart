import 'package:flutter/material.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';

class CustomCrudTableRowTitlesWidget extends StatelessWidget {
  final List<String> rows;

  const CustomCrudTableRowTitlesWidget({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomText(
                text: rows[i],
              ),
            )),
            if (i < rows.length - 1) const VerticalDivider(width: 0,)
          ]
        ],
      ),
    );
  }
}
