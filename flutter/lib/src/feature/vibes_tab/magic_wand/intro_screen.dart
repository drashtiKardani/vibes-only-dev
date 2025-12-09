import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/vibes_tab/magic_wand/magic_wand_screen.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class MagicWandIntro extends StatefulWidget {
  const MagicWandIntro({super.key});

  @override
  State<MagicWandIntro> createState() => _MagicWandIntroState();
}

class _MagicWandIntroState extends State<MagicWandIntro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    extendBodyBehindAppBar: true,
      appBar:
          BackButtonAppBar(context, onPressed: () => Navigator.pop(context)),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14).copyWith(
              top: context.mediaQuery.viewPadding.top,
              bottom: context.mediaQuery.viewPadding.bottom + 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Gap(0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.1),
                      ),
                      child: Assets.svg.mobileVibrationStroke.svg(
                        height: 60,
                        width: 60,
                      ),
                    ),
                    Gap(16),
                    Text(
                      'Shake to Vibe',
                      style: context.textTheme.displaySmall
                          ?.copyWith(fontSize: 24),
                    ),
                    Gap(6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Shake your phone to feel the vibrations. The more you shake, the higher the intensity!',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  spacing: 14,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Checkbox(
                          value: SyncSharedPreferences
                              .doNotShowMagicWandIntro.value,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          onChanged: (value) {
                            setState(() {
                              SyncSharedPreferences.doNotShowMagicWandIntro
                                  .value = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                SyncSharedPreferences
                                        .doNotShowMagicWandIntro.value =
                                    !SyncSharedPreferences
                                        .doNotShowMagicWandIntro.value;
                              });
                            },
                            child: Text(
                              'Don\'t show this again.',
                              style: context.textTheme.titleLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    VibesElevatedButton(
                      text: 'Got it',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MagicWandScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
