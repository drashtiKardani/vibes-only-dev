import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_control/freestyle_mode/controller.dart';
import 'package:vibes_only/src/feature/toy/remote_control/freestyle_mode/new_chart.dart';

part 'pad.dart';

class FreeStyleMode extends StatelessWidget {
  const FreeStyleMode({super.key, required this.controller});

  final FreeStylingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          flex: 136,
          child: Observer(builder: (context) {
            return MultiCurveChart(
              motor1Intensities: controller.motor1Intensities.toList(),
              motor2Intensities: controller.motor2Intensities.toList(),
            );
          }),
        ),
        Container(
          height: 1,
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        Expanded(
          flex: 297,
          child: _Pad(
            onNewPadValue: (double value) {
              controller.freeStylingSpeed = value;
            },
          ),
        ),
      ],
    );
  }
}
