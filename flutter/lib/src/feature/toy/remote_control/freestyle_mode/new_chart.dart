import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../motor_selector/motor_selector_cubit.dart';

class MultiCurveChart extends StatelessWidget {
  final List<int> motor1Intensities;
  final List<int> motor2Intensities;

  const MultiCurveChart(
      {super.key,
      required this.motor1Intensities,
      required this.motor2Intensities});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorSelectorCubit, ToyMotor>(
        builder: (context, selectedMotor) {
      return CustomPaint(
        size: const Size.fromWidth(double.infinity),
        painter: selectedMotor == ToyMotor.mainMotor
            ? MultiCurveChartPainter(motor1Intensities)
            : MultiCurveChartPainter(motor2Intensities),
      );
    });
  }
}

class MultiCurveChartPainter extends CustomPainter {
  final List<int> intensities;

  MultiCurveChartPainter(this.intensities);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Create 9 variations by rotating around the X-axis
    for (int i = 0; i < 9; i++) {
      _drawIntensityCurve(canvas, size, i, paint);
    }
  }

  void _drawIntensityCurve(
      Canvas canvas, Size size, int rotation, Paint paint) {
    Path path = Path();
    double middleY = size.height / 2;

    int pointsToShow = intensities.length < 200 ? intensities.length : 200;
    List<int> recentIntensities =
        intensities.sublist(intensities.length - pointsToShow);

    for (int i = 0; i < recentIntensities.length; i++) {
      double x = (i / recentIntensities.length) * size.width;
      double y =
          size.height - recentIntensities[i].toDouble() / 99 * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Apply rotation
    canvas.save();
    canvas.translate(0, middleY); // Move the chart to the middle
    final adjustedRotation = 8 * pow(rotation / 8, 0.5);
    canvas.transform(Matrix4.rotationX(adjustedRotation * pi / 18).storage);
    canvas.translate(0, -middleY); // Move the chart back

    // Gradient effect based on Y position
    const Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Color(0x7FFFFFFF), Colors.white],
      stops: [0.0, 0.5, 1.0],
    );

    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
