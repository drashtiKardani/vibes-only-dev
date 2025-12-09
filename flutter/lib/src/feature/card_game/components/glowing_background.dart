import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class GlowingBackground extends StatelessWidget {
  final Duration _duration;
  final Widget child;

  const GlowingBackground({
    super.key,
    required this.child,
  }) : _duration = Duration.zero;

  const GlowingBackground.animated(
      {super.key, required this.child, required Duration duration})
      : _duration = duration;

  @override
  Widget build(BuildContext context) {
    double screenHeight = context.mediaQuery.size.height;

    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: _duration,
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final double right = lerpDouble(-100, -30, value)!;
            final double? top = lerpDouble(null, 140, value);
            final double height = lerpDouble(screenHeight / 2, 160, value)!;
            final double width = height;

            return Positioned(
              top: value == 0 ? null : top,
              bottom: value == 0 ? 0 : null,
              right: right,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(
                  height: height,
                  width: width,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF4713C2),
                        Colors.transparent,
                      ],
                      radius: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: _duration,
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final double bottom = lerpDouble(0, 140, value)!;
            final double left = lerpDouble(-100, -50, value)!;
            final double size = lerpDouble(screenHeight / 2, 160, value)!;

            return Positioned(
              bottom: bottom,
              left: left,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(
                  height: size,
                  width: size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFB560A9),
                        Colors.transparent,
                      ],
                      radius: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        child,
      ],
    );
  }
}
