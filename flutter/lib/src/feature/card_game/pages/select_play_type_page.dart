import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/feature/card_game/card_game_screen.dart';
import 'package:vibes_only/src/feature/card_game/components/play_type_list_item.dart';

class SelectPlayTypePage extends StatelessWidget with CardGamePage {
  final PlayType? playType;
  final PromptType? promptType;
  final PlayTypeValueChanged onChanged;

  const SelectPlayTypePage({
    super.key,
    required this.playType,
    required this.promptType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 20,
      children: [
        Text(
          'How do you want to play?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Expanded(
          child: Column(
            spacing: 20,
            children: PlayType.values
                .map((playType) {
                  bool selected = playType == this.playType;

                  return PlayTypeListItem(
                    playType: playType,
                    promptType: promptType,
                    selected: selected,
                    onChanged: onChanged,
                  );
                })
                .map((e) => Expanded(child: e))
                .toList(),
          ),
        ),
        const Gap(40),
      ],
    );
  }

  @override
  bool get isValid => true;

  @override
  String? get nextButtonLabel => null;
}
