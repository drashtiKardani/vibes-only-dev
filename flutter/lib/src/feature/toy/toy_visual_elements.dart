import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibes_only/gen/assets.gen.dart';

class VibePatters {
  static final _vibeGlowingPatterns = Assets.vibePatterns.values;

  /// [index] is zero-based. 0 ~~ [count]-1
  static SvgPicture getByIndex(int index, {double? width, Color? color}) {
    return _vibeGlowingPatterns[index].svg(
        width: width,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null);
  }

  static int count() {
    return _vibeGlowingPatterns.length;
  }
}
