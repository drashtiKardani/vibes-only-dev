import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';

class VibeStudioGridView extends StatelessWidget {
  final int itemCount;

  const VibeStudioGridView({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,

      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: context.mediaQuery.viewPadding.bottom + 10,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        Color onSurface = context.colorScheme.onSurface;

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context, index);
          },
          child: AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            duration: Durations.medium2,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: onSurface.withValues(alpha: 0.05),
              border: Border.all(color: onSurface.withValues(alpha: 0.2)),
            ),
            child: VibePatters.getByIndex(index, color: onSurface),
          ),
        );
      },
    );
  }
}
