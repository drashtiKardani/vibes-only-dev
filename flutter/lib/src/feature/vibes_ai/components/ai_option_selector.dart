import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/vibes_ai/extensions/extensions.dart';

class AiOptionSelector<T> extends StatelessWidget {
  final List<T> options;
  final String Function(T option) titleOf;
  final void Function(T option) onSelected;

  const AiOptionSelector({
    super.key,
    required this.onSelected,
    required this.options,
    required this.titleOf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((option) {
            return ListTile(
              minTileHeight: 30,
              onTap: () => onSelected(option),
              title: Text(titleOf(option)),
              titleTextStyle: context.textTheme.titleMedium?.copyWith(
                fontSize: 14,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.colorScheme.onSurface,
              ),
            );
          })
          .toList()
          .separateBuilder(() {
            return Divider(
              color: context.colorScheme.onSurface.withValues(alpha: 0.06),
            );
          }),
    );
  }
}
