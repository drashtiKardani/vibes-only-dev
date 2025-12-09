import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/card_game/card_game_screen.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';
import 'package:vibes_only/src/feature/card_game/components/how_to_play_bottom_sheet.dart';

class InitialCardGamePage extends StatelessWidget with CardGamePage {
  const InitialCardGamePage({super.key});

  @override
  String? get nextButtonLabel => 'Start Game';

  @override
  bool get isValid => true;

  @override
  Future<bool> Function(BuildContext context)? get nextButtonTapped {
    return (BuildContext context) async {
      bool value = SyncSharedPreferences.doNotShowHowToPlayForCardGame.value;
      if (value) {
        return await showBlurredBackgroundBottomSheet(
          context: context,
          builder: (context) => _LetsGetNaughtyBottomSheet(),
        );
      }

      return await showBlurredBackgroundBottomSheet(
        context: context,
        builder: (context) => const HowToPlayBottomSheet(),
      ).then((_) async {
        return await showBlurredBackgroundBottomSheet(
          context: context,
          builder: (context) => _LetsGetNaughtyBottomSheet(),
        );
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Assets.images.cardGameInitial.image(
      filterQuality: FilterQuality.high,
      fit: BoxFit.fill,
    );
  }
}

class _LetsGetNaughtyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Let\'s Get Naughty',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(20),
        Text(
          'By tapping "We\'re In," everyone agrees they\'re 18+, playing willingly, and totally down for spicy, suggestive fun.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: context.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const Gap(30),
        Row(
          spacing: 16,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const StadiumBorder(),
                fixedSize: const Size.fromHeight(50),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Nope, Back Out'),
            ),
            VibesElevatedButton(
              text: 'We\'re In',
              size: const Size.fromHeight(50),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ].map((e) => Expanded(child: e)).toList(),
        )
      ],
    );
  }
}
