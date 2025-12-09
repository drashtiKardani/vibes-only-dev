import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/widget/gradient_box_border.dart';

typedef PlayTypeValueChanged = void Function(
  PlayType playType,
  PromptType? promptType,
);

BoxBorder _kGradientBoxBorder = const GradientBoxBorder(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffB560A9), Color(0xff4F2A4A)],
  ),
);

class PlayTypeListItem extends StatelessWidget {
  final PlayType playType;
  final PromptType? promptType;
  final bool selected;
  final PlayTypeValueChanged onChanged;

  const PlayTypeListItem({
    super.key,
    required this.playType,
    required this.promptType,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (playType) {
      PlayType.choose => Row(
          spacing: 16,
          children: PromptType.values
              .map((promptType) {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onChanged(playType, promptType),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 20),
                    width: context.mediaQuery.size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: selected && promptType == this.promptType
                          ? _kGradientBoxBorder
                          : Border.all(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.1),
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 3,
                            child: promptType.image.svg(height: 60, width: 60)),
                        Expanded(
                          flex: 7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                promptType.displayName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                promptType.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList()
              .map((e) => Expanded(child: e))
              .toList(),
        ),
      PlayType.surpriseMe => InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(playType, null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            width: context.mediaQuery.size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? _kGradientBoxBorder
                  : Border.all(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 12,
              children: [
                Expanded(flex: 5, child: Assets.svg.showOrTellWheel.svg()),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Surprise me',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Let the app choose your fate — no take-backs.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    };
  }
}

extension PromptTypeEx on PromptType {
  SvgGenImage get image {
    return switch (this) {
      PromptType.showMe => Assets.svg.showMe,
      PromptType.tellMe => Assets.svg.tellMe,
    };
  }

  String get displayName {
    return switch (this) {
      PromptType.showMe => 'Show me',
      PromptType.tellMe => 'Tell me',
    };
  }

  String get description {
    return switch (this) {
      PromptType.showMe => 'Take the dare and put on a little show.',
      PromptType.tellMe => 'Share a truth you\'ve been keeping under wraps.',
    };
  }
}
