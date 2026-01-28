import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

/// Returns the index of selected pattern from [VibePatters].
class ChoosePatternScreen extends StatelessWidget {
  const ChoosePatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int itemCount = VibePatters.count();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
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
              top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
            ),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Pattern',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                Expanded(
                  child: 
                  GridView.builder(
                    itemCount: itemCount,
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
                            border: Border.all(
                                color: onSurface.withValues(alpha: 0.2)),
                          ),
                          child:
                              VibePatters.getByIndex(index, color: onSurface),
                        ),
                      );
                    },
                  ),
               
               
               
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
