import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({super.key, required this.value, required this.title, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged.call(!value),
      child: Container(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8,),
            Text(title),
          ],
        ),
      ),
    );
  }
}
