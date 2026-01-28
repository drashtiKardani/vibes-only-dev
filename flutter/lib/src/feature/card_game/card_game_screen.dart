import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/feature/card_game/components/card_game_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';
import 'package:vibes_only/src/feature/card_game/pages/select_show_me_or_tell_me_page.dart';
import 'package:vibes_only/src/feature/card_game/show_card_screen.dart';
import 'package:vibes_only/src/feature/card_game/pages/initial_card_game_page.dart';
import 'package:vibes_only/src/feature/card_game/pages/select_play_type_page.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

/// A mixin that defines the interface for a step-based card game page.
///
/// Intended for use with `Widget`s that represent individual steps in a
/// multi-step flow such as onboarding, quizzes, or forms. This mixin
/// standardizes validation and navigation behavior across all steps.
mixin CardGamePage on Widget {
  /// Whether the current page is valid and the user is allowed to proceed.
  ///
  /// Typically used to enable or disable the "Next" button.
  bool get isValid;

  /// The label to display on the "Next" button.
  ///
  /// Can be `null` to use a default label. Override to customize per page
  /// (e.g., "Next", "Submit", "Finish").
  String? get nextButtonLabel;

  /// Called when the "Next" button is tapped.
  ///
  /// Return `true` to proceed to the next page, or `false` to prevent navigation.
  /// Return `null` to fall back to default navigation behavior.
  Future<bool> Function(BuildContext context)? get nextButtonTapped => null;
}

class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  static const String path = '/card_game';

  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen> {
  late final CardGameCubit _gameCubit = context.read<CardGameCubit>();

  final PageController _pageController = PageController();

  Future<void> _onShowCard(CardGameState state) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final List<GameCard> gameCards = _gameCubit.getMatchingCards();

    if (gameCards.isNotEmpty) {
      CardGameDetails cardGameDetails = CardGameDetails(
        playType: state.playType!,
        promptType: state.promptType!,
        gameCards: _gameCubit.getMatchingCards(),
      );

      context.push(ShowCardScreen.path, extra: cardGameDetails.toJson()).then((
        value,
      ) {
        if (value == true) {
          _pageController.animateToPageByIndex(1);
          _gameCubit.onPlayTypeOrPromptTypeChanged(null, null);
          _gameCubit.getAllGameCard();
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Card not found')));
    }
  }

  @override
  void initState() {
    super.initState();
    _gameCubit
      ..reset()
      ..getAllGameCard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardGameCubit, CardGameState>(
      listenWhen: (previous, current) =>
          previous.promptType != current.promptType ||
          previous.playType != current.playType,
      listener: (context, state) {
        print(
          '[DEBUG] Current: playType=${state.playType}, promptType=${state.promptType} , pageIndex=${state.pageIndex}',
        );

        // This will be called with the NEW state after the cubit updates
        if (state.playType != null && state.promptType != null) {
          Future.delayed(Durations.medium4, () => _onShowCard(state));
        } else {
          if (state.playType == PlayType.surpriseMe) {
            _pageController.animateToNextPage();
          }
        }
      },
      builder: (c, state) {
        List<CardGamePage> pages = [
          const InitialCardGamePage(),
          SelectPlayTypePage(
            playType: state.playType,
            promptType: state.promptType,
            onChanged: _gameCubit.onPlayTypeOrPromptTypeChanged,
          ),
          SelectShowMeOrTellMePage(onSelected: _gameCubit.onPromptTypeChanged),
        ];

        EdgeInsets padding = EdgeInsets.only(
          top: context.viewPadding.top + kToolbarHeight + 14,
          bottom: context.viewPadding.bottom + 10,
        );

        CardGamePage page = pages[state.pageIndex];

        bool isInitial = page.runtimeType == InitialCardGamePage;

        String? nextButtonLabel = page.nextButtonLabel;

        bool showBackButton = [
          SelectPlayTypePage,
          SelectShowMeOrTellMePage,
        ].contains(page.runtimeType);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: isInitial
              ? CardGameAppBar(context)
              : showBackButton
              ? BackButtonAppBar(
                  context,
                  onPressed: () {
                    try {
                      print(_pageController.pageOffset);
                      _pageController.animateToPreviousPage();
                    } catch (e) {
                      print('Error animating to previous page: $e');
                    }
                    // if (page.runtimeType == SelectPlayTypePage) {
                    _gameCubit.onPlayTypeOrPromptTypeChanged(null, null);
                    // }
                  },
                )
              : null,
          body: Stack(
            children: [
              Positioned.fill(
                child: Assets.images.background.image(
                  filterQuality: FilterQuality.high,
                  package: 'flutter_mobile_app_presentation',
                ),
              ),
              Padding(
                padding: padding.copyWith(left: 10, right: 10),
                child: Column(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _gameCubit.onPageChanged,
                        scrollBehavior: const _ScrollBehaviorModified(),
                        physics: const NeverScrollableScrollPhysics(),
                        children: pages.map((page) => page).toList(),
                      ),
                    ),
                    if (nextButtonLabel != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isInitial ? 20 : 0,
                        ),
                        child: VibesElevatedButton(
                          text: nextButtonLabel,
                          onPressed: page.isValid
                              ? () async {
                                  if (page.nextButtonTapped == null ||
                                      await page.nextButtonTapped!(context) ==
                                          true) {
                                    _pageController.animateToNextPage();
                                  }
                                }
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// An extension on [PageController] that provides convenience methods
/// for animating to the next, previous, or a specific page with a standard duration and curve.
///
/// This simplifies navigation between pages in a [PageView] with consistent animation behavior.
extension AnimateTo on PageController {
  /// Animates to the next page using a short duration and ease curve.
  void animateToNextPage() {
    nextPage(duration: Durations.short4, curve: Curves.ease);
  }

  /// Animates to the previous page using a short duration and ease curve.
  void animateToPreviousPage() {
    previousPage(duration: Durations.short4, curve: Curves.ease);
  }

  /// Animates to the specified [index] page using a short duration and ease curve.
  void animateToPageByIndex(int index) {
    animateToPage(index, duration: Durations.short4, curve: Curves.ease);
  }

  /// Returns the current scroll position as a fractional page offset.
  ///
  /// Returns `0` if the controller has no attached clients or the page is `null`.
  double get pageOffset => hasClients ? page ?? 0 : 0;
}

class _ScrollBehaviorModified extends ScrollBehavior {
  const _ScrollBehaviorModified();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}
