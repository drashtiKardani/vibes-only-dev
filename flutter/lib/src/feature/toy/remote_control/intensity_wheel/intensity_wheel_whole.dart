import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/toy/remote_control/intensity_wheel/copper_decoration.dart';

class IntensityWheelWhole extends StatelessWidget {
  const IntensityWheelWhole(
      {super.key,
      required this.onNewAngleSelected,
      required this.selectedAngle});

  final void Function(double) onNewAngleSelected;
  final double selectedAngle;

  static const innerCirclePadding1 = 5.0;
  static const pinkWheelShadowPadding = 45.0;
  static const pinkWheelPadding = 50.0;
  static const onWheelIndicatorPadding = 65.0;
  static const intensityLightsPadding = 25.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final intensityLightsRadius =
            (availableWidth - 2 * intensityLightsPadding) / 2;
        final onWheelIndicatorRadius =
            (availableWidth - 2 * onWheelIndicatorPadding) / 2;
        final wholeWheelRadius = availableWidth / 2;
        // final pinkWheelRadius = (availableWidth - 2 * pinkWheelPadding) / 2;
        return Listener(
          onPointerMove: (event) {
            // transforming x & y to cartesian
            final x = event.localPosition.dx - wholeWheelRadius;
            final y = wholeWheelRadius - event.localPosition.dy;
            // transforming math-angle to mirror mode we use here.
            final newAngle = math.pi - math.atan2(y, x);
            onNewAngleSelected(newAngle);
          },
          child: SizedBox(
            width: availableWidth,
            height: availableWidth,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: availableWidth,
                    height: availableWidth,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF151515),
                      shape: OvalBorder(),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: innerCirclePadding1,
                  top: innerCirclePadding1,
                  child: Container(
                    width: availableWidth - 2 * innerCirclePadding1,
                    height: availableWidth - 2 * innerCirclePadding1,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF252525),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                Positioned(
                  left: pinkWheelShadowPadding,
                  top: pinkWheelShadowPadding,
                  child: Container(
                    width: availableWidth - 2 * pinkWheelShadowPadding,
                    height: availableWidth - 2 * pinkWheelShadowPadding,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF151515),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
                ...[for (var i = 0; i <= 47; i++) 2 * i * math.pi / 48].map(
                  (angle) => Positioned(
                    // -4 => positioned rel to center
                    top: -4 +
                        intensityLightsPadding +
                        intensityLightsRadius -
                        intensityLightsRadius * math.sin(angle),
                    left: -4 +
                        intensityLightsPadding +
                        intensityLightsRadius -
                        intensityLightsRadius * math.cos(angle),
                    height: 8,
                    width: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: angle <= selectedAngle
                            ? AppColors.vibesPink
                            : const Color(0xFF606060),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .25),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: pinkWheelPadding,
                  top: pinkWheelPadding,
                  child: Container(
                    width: availableWidth - 2 * pinkWheelPadding,
                    height: availableWidth - 2 * pinkWheelPadding,
                    decoration: const CopperDecoration(),
                  ),
                ),
                Positioned(
                  top: -5 +
                      onWheelIndicatorPadding +
                      onWheelIndicatorRadius -
                      onWheelIndicatorRadius * math.sin(selectedAngle),
                  left: -5 +
                      onWheelIndicatorPadding +
                      onWheelIndicatorRadius -
                      onWheelIndicatorRadius * math.cos(selectedAngle),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFCE4C68),
                      shape: OvalBorder(),
                    ),
                  ),
                ),

                /// Grey bar at the bottom, essentially covers up the bottom half of whole wheel.
                Positioned(
                  bottom: 0,
                  left: innerCirclePadding1,
                  right: innerCirclePadding1,
                  child: Container(
                    color: AppColors.grey25,
                    height: wholeWheelRadius,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
