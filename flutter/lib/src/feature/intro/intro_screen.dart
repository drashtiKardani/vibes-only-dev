import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/generated/l10n.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/gen/assets.gen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final ValueNotifier<int> _activeIndexNotifier = ValueNotifier<int>(0);

  final PageController _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<int>(
      valueListenable: _activeIndexNotifier,
      builder: (context, activeIndex, _) {
        final List<Widget> pages = List<Widget>.generate(
          introPages.length,
          (index) {
            Alignment alignment = switch (activeIndex) {
              0 => Alignment.topCenter,
              1 => const Alignment(0.0, -1.4),
              2 => const Alignment(0.0, -0.85),
              _ => Alignment.center,
            };

            EdgeInsets padding = switch (activeIndex) {
              2 => const EdgeInsets.symmetric(horizontal: 30),
              _ => EdgeInsets.zero,
            };

            return Padding(
              padding: padding,
              child: Image.asset(
                introPages[index].path,
                filterQuality: FilterQuality.high,
                alignment: alignment,
              ),
            );
          },
        );

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (value) {
                    _activeIndexNotifier.value = value;
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return pages[index];
                  },
                ),
                Container(
                  height: height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        context.colorScheme.surface.withValues(alpha: 0.7),
                        context.colorScheme.surface,
                        context.colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: Durations.medium3,
                        child: Column(
                          key: ValueKey(activeIndex),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              introPages[activeIndex].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: height > 800 ? 28 : 22,
                                height: 1.1,
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              introPages[activeIndex].caption,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: height > 800 ? 16 : 13,
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AnimatedDotIndicator(
                        length: pages.length,
                        activeIndex: activeIndex,
                      ),
                      const SizedBox(height: 20),
                      _buildPreviousOrNextButton(activeIndex),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviousOrNextButton(int activeIndex) {
    return Row(
      children: [
        if (activeIndex != 0)
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
              icon: const Icon(
                VibesV3.arrowLeft,
                size: 20,
              ),
            ),
          ),
        const Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorScheme.onSurface,
          ),
          child: IconButton(
            onPressed: () {
              if (activeIndex == (introPages.length - 1)) {
                context.pushReplacement('/iap?skippable=true');
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }
            },
            icon: const Icon(
              VibesV3.arrowRight,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  static final List<IntroPage> introPages = [
    IntroPage(
      Assets.images.intro1.path,
      S.current.intro1Title,
      S.current.intro1Text,
    ),
    IntroPage(
      Assets.images.intro2.path,
      S.current.intro2Title,
      S.current.intro2Text,
    ),
    IntroPage(
      Assets.images.intro3.path,
      S.current.intro3Title,
      S.current.intro3Text,
    ),
    // IntroPage(
    //   "https://video-vibes-test.s3.us-east-2.amazonaws.com/media/stories/character/profile_image/intro_4.png",
    //   S.current.intro4Title,
    //   S.current.intro4Text,
    // ),
  ];
}

class IntroPage {
  final String path;
  final String title;
  final String caption;

  IntroPage(this.path, this.title, this.caption);
}

extension CustomCalculation on double {
  double get distanceToNearestHalfPoint => (this - nearestHalfPoint).abs();

  double get nearestHalfPoint => truncate() + 0.5;
}

class _AnimatedDotIndicator extends StatelessWidget {
  final int length;
  final int activeIndex;

  const _AnimatedDotIndicator({
    required this.length,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (index) {
        bool activated = activeIndex == index;

        double height = 6;
        double width = activated ? 22 : 6;

        return AnimatedContainer(
          height: height,
          width: width,
          duration: Durations.medium2,
          decoration: BoxDecoration(
            color: activated
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
      }),
    );
  }
}
