import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/card_game/card_game_screen.dart';
import 'package:vibes_only/src/feature/card_game/components/spin_wheel.dart';

class SelectShowMeOrTellMePage extends StatelessWidget with CardGamePage {
  final void Function(PromptType promptType) onSelected;

  const SelectShowMeOrTellMePage({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 60,
      children: [
        Column(
          spacing: 6,
          children: [
            Text(
              'Surprise me',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            Text(
              'Show me or Tell me',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        SpinWheel(
          onComplete: (type) => onSelected(type),
          height: 280,
          pinWidget: Assets.svg.spinPin.svg(),
          wheelWidget: Assets.svg.showOrTellWheel.svg(),
        ),
      ],
    );
  }

  @override
  bool get isValid => true;

  @override
  String? get nextButtonLabel => null;
}
