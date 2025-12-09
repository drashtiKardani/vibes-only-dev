import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

import '../../toy/toy_visual_elements.dart';
import '../vibes_studio/choose_pattern_screen.dart';

class PatternSelectButton extends StatelessWidget {
  const PatternSelectButton({super.key, required this.onPatternSelected, required this.patternIndex});

  final int patternIndex;
  final void Function(int patternIndex) onPatternSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push<int?>(MaterialPageRoute(builder: (_) => const ChoosePatternScreen()))
          .then((patternIndex) {
        if (patternIndex != null) {
          onPatternSelected(patternIndex);
        }
      }),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.grey30),
        child: Center(
          child: VibePatters.getByIndex(patternIndex, width: 34),
        ),
      ),
    );
  }
}
