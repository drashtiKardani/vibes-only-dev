import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/vibes_studio_screen.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class VibeStudioIntro extends StatefulWidget {
  const VibeStudioIntro({super.key});

  @override
  State<VibeStudioIntro> createState() => _VibeStudioIntroState();
}

class _VibeStudioIntroState extends State<VibeStudioIntro> {
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
                const Gap(80),
                Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            patternInBox(1),
                            const Gap(4),
                            patternInBox(2)
                          ],
                        ),
                        const Gap(4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            patternInBox(3),
                            const Gap(4),
                            patternInBox(4)
                          ],
                        ),
                      ],
                    ),
                    Gap(16),
                    Text(
                      'Customize your experience',
                      textAlign: TextAlign.center,
                      style: context.textTheme.displaySmall
                          ?.copyWith(fontSize: 24),
                    ),
                    Gap(6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Combine our premade vibration patterns to create your perfect Vibe session.\n\n'
                        'Save the Vibe you created as a “playlist” and enjoy it on your device whenever you like.',
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
                              .doNotShowVibeStudioIntro.value,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          onChanged: (value) {
                            setState(() {
                              SyncSharedPreferences.doNotShowVibeStudioIntro
                                  .value = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                SyncSharedPreferences
                                        .doNotShowVibeStudioIntro.value =
                                    !SyncSharedPreferences
                                        .doNotShowVibeStudioIntro.value;
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
                            builder: (context) => const VibesStudioScreen(),
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

  Widget patternInBox(int patternIndex) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      child: VibePatters.getByIndex(patternIndex,
          color: context.colorScheme.onSurface),
    );
  }
}
