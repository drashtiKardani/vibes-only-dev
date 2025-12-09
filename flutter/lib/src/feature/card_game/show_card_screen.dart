import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/feature/card_game/components/card_game_app_bar.dart';
import 'package:vibes_only/src/feature/card_game/components/glowing_background.dart';
import 'package:vibes_only/src/feature/card_game/components/play_type_list_item.dart';

class ShowCardScreen extends StatefulWidget {
  final CardGameDetails cardGameDetails;

  const ShowCardScreen({super.key, required this.cardGameDetails});

  static const String path = '/show_card';

  @override
  State<ShowCardScreen> createState() => _ShowCardScreenState();
}

class _ShowCardScreenState extends State<ShowCardScreen> {
  final Duration _animationDuration = const Duration(milliseconds: 2000);

  @override
  Widget build(BuildContext context) {
    List<GameCard> gameCards = widget.cardGameDetails.gameCards;
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CardGameAppBar(
          context,
          leading: Transform.scale(
            scale: 0.7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              child: IconButton(
                onPressed: () => context.pop(true),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft02,
                  color: context.colorScheme.onSurface,
                ),
                iconSize: 30,
              ),
            ),
          ),
        ),
        body: GlowingBackground.animated(
          duration: _animationDuration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
              top: context.viewPadding.top + kToolbarHeight + 14,
              bottom: context.viewPadding.bottom + 20,
            ),
            child: switch (widget.cardGameDetails.promptType) {
              PromptType.showMe => ZoomIn(
                duration: _animationDuration,
                curve: Curves.ease,

                child: CardSwiper(
                  cardsCount: gameCards.length,
                  backCardOffset: Offset.zero,
                  padding: EdgeInsetsGeometry.zero,
                  isLoop: false,
                  allowedSwipeDirection: AllowedSwipeDirection.symmetric(
                    horizontal: true,
                  ),
                  onEnd: () {
                    Future.delayed(Duration(milliseconds: 400), () {
                      context.pop(true);
                    });
                  },
                  cardBuilder: (context, index, hop, vop) {
                    GameCard gameCard = gameCards[index];
                    return _buildCard(
                      colors: [
                        const Color(0xFF210B1F),
                        const Color(0xFF872D7E),
                        const Color(0xFF210B1F),
                      ],
                      gameCard: gameCard,
                    );
                  },
                ),
              ),
              PromptType.tellMe => CornerScaleTransition(
                duration: _animationDuration,
                curve: Curves.ease,
                child: CardSwiper(
                  cardsCount: gameCards.length,
                  padding: EdgeInsetsGeometry.zero,
                  isLoop: false,
                  allowedSwipeDirection: AllowedSwipeDirection.symmetric(
                    horizontal: true,
                  ),
                  onEnd: () {
                    Future.delayed(Duration(milliseconds: 400), () {
                      context.pop(true);
                    });
                  },
                  cardBuilder: (context, index, hop, vop) {
                    GameCard gameCard = gameCards[index];
                    return _buildCard(
                      colors: [
                        const Color(0xFF4713C2),
                        const Color(0xFFAA8DF0),
                        const Color(0xFF4713C2),
                      ],
                      gameCard: gameCard,
                    );
                  },
                ),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Color> colors, required GameCard gameCard}) {
    return Container(
      padding: const EdgeInsets.all(14),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Container(
        width: context.mediaQuery.size.width,
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: switch (widget.cardGameDetails.promptType) {
              PromptType.showMe => const Color(0xFF872D7E),
              PromptType.tellMe => Colors.white38,
            },
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 14,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                child: Text(
                  gameCard.promptType.displayName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                gameCard.content,
                style: GoogleFonts.alata(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CornerScaleTransition extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final Alignment alignment;
  final Widget child;

  const CornerScaleTransition({
    super.key,
    required this.duration,
    required this.child,
    required this.curve,
    this.alignment = Alignment.topLeft,
  });

  @override
  CornerScaleTransitionState createState() => CornerScaleTransitionState();
}

class CornerScaleTransitionState extends State<CornerScaleTransition>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = CurvedAnimation(parent: _controller, curve: widget.curve);

    _toggleCard();
  }

  void _toggleCard() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          alignment: widget.alignment,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
