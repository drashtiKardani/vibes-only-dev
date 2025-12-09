import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class BGArt extends StatelessWidget {
  const BGArt({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BGArtPainter(), child: Container());
  }
}

class _BGArtPainter extends CustomPainter {
  static const _refCanvasSize = 335.0;
  static const _refArtSize = 270.0;
  static const _refCentralCircleRadius = 51;

  static double get _centralCircleRadiusRatio =>
      _refCentralCircleRadius / _refArtSize;

  /// padding/dimension for each side, where dimension is width or height of the canvas.
  static double get _paddingRatio =>
      (_refCanvasSize - _refArtSize) / (2 * _refCanvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey45
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Calculate center and radius based on size
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.shortestSide * _centralCircleRadiusRatio;

    final hPadding = _paddingRatio * size.width;
    final vPadding = _paddingRatio * size.height;

    // Draw horizontal lines
    canvas.drawLine(
      Offset(hPadding, centerY),
      Offset(centerX - radius, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + radius, centerY),
      Offset(size.width - hPadding, centerY),
      paint,
    );

    // Draw vertical lines
    canvas.drawLine(
      Offset(centerX, vPadding),
      Offset(centerX, centerY - radius),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + radius),
      Offset(centerX, size.height - vPadding),
      paint,
    );

    // Draw circle with dashed border
    final dashPaint = Paint()
      ..color = AppColors.grey45
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashWidth = 8;
    double dashSpace = 4;
    double circumference = 2 * math.pi * radius;
    int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    double dashAngle = 2 * math.pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      double startAngle = i * dashAngle;
      double endAngle = startAngle + dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
