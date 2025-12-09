import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class VibeBarRuler extends StatelessWidget {
  const VibeBarRuler({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i <= 100; i += 10)
          Text(
            '$i',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
