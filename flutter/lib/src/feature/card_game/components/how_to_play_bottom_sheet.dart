import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class HowToPlayBottomSheet extends StatefulWidget {
  const HowToPlayBottomSheet({super.key});

  @override
  State<HowToPlayBottomSheet> createState() => _HowToPlayBottomSheetState();
}

class _HowToPlayBottomSheetState extends State<HowToPlayBottomSheet> {
  final ValueNotifier<bool> _doNotShowHowToPlayForCardGameNotifier =
      ValueNotifier<bool>(false);

  void _onDoNotShowHowTOPlayForCardGameChanged(bool value) {
    _doNotShowHowToPlayForCardGameNotifier.value = value;
    SyncSharedPreferences.doNotShowHowToPlayForCardGame.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'How to Play',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Play one-on-one with a partner or spice things up with a group.\n\nWhen it\'s your turn, take the phone and choose your adventure:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: context.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: {
              'Show Me': 'Do something',
              'Tell Me': 'Say something',
              'Surprise Me': 'Let fate decide with a random card'
            }.entries.map((e) {
              return Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    e.value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        _buildDoNotShowHowToPlayForCardGame(),
        VibesElevatedButton(
          text: 'Got It',
          size: Size(context.mediaQuery.size.width, 50),
          onPressed: () {
            Navigator.pop(context, true);
          },
        )
      ],
    );
  }

  Widget _buildDoNotShowHowToPlayForCardGame() {
    return ValueListenableBuilder<bool>(
      valueListenable: _doNotShowHowToPlayForCardGameNotifier,
      builder: (context, value, _) {
        return Row(
          spacing: 10,
          children: [
            Checkbox(
              value: value,
              onChanged: (value) {
                _onDoNotShowHowTOPlayForCardGameChanged(value ?? false);
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _onDoNotShowHowTOPlayForCardGameChanged(!value);
                },
                child: Text(
                  'Don\'t show this again.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
