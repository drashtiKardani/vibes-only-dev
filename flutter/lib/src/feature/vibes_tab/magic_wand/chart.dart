import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../toy/remote_control/motor_selector/motor_selector_cubit.dart';

class IntensityChart extends StatelessWidget {
  final List<int> motor1Intensities;
  final List<int> motor2Intensities;
  final List<int> motor3Intensities;

  const IntensityChart({
    super.key,
    required this.motor1Intensities,
    required this.motor2Intensities,
    required this.motor3Intensities,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorSelectorCubit, ToyMotor>(
        builder: (context, selectedMotor) {
      return CustomPaint(
        size: const Size(double.infinity, 214),
        painter: selectedMotor == ToyMotor.mainMotor
            ? IntensityChartPainter(motor1Intensities)
            : selectedMotor == ToyMotor.subMotor
                ? IntensityChartPainter(motor2Intensities)
                : IntensityChartPainter(motor3Intensities),
      );
    });
  }
}

class IntensityChartPainter extends CustomPainter {
  final List<int> intensities;

  IntensityChartPainter(this.intensities);

  @override
  void paint(Canvas canvas, Size size) {
    if (intensities.length < 10) return;

    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Draw the middle horizontal line at intensity 50
    double midY = size.height * 0.5;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), linePaint);

    // Use the last 100 points, or all if less
    int pointsToShow = intensities.length < 200 ? intensities.length : 200;
    List<int> recentIntensities =
        intensities.sublist(intensities.length - pointsToShow);

    // Prepare a path for the intensities
    double stepX = size.width / (pointsToShow - 1);
    Path intensityPath = Path();
    Path fillPath = Path();

    for (int i = 0; i < pointsToShow; i++) {
      double intensity = recentIntensities[i].toDouble();
      double y = size.height - (intensity / 100.0) * size.height;

      if (i == 0) {
        intensityPath.moveTo(0, y);
        fillPath.moveTo(0, y);
      } else {
        intensityPath.lineTo(i * stepX, y);
        fillPath.lineTo(i * stepX, y);
      }
    }

    // Complete the fillPath by connecting it to the middle (intensity 50)
    fillPath.lineTo(size.width, midY);
    fillPath.lineTo(0, midY);
    fillPath.close();

    // Define the gradient for the area under the curve
    Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Colors.transparent,
          Colors.white,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Clip the gradient to the area under the intensity curve
    canvas.save();
    canvas.clipPath(fillPath);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
    canvas.restore();

    // Paint the intensity line with a gradient
    Paint intensityLinePaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Create a gradient that changes from pink to white near the extremes
    LinearGradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.5),
        Colors.white,
        Colors.white.withValues(alpha: 0.5),
      ],
      stops: [0.0, 0.5, 1.0],
    );

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    intensityLinePaint.shader = gradient.createShader(rect);

    // Draw the intensity line
    canvas.drawPath(intensityPath, intensityLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
