import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class SoundRaysPainter extends CustomPainter {
  final Amplitude? amplitude;
  final double innerRadius; // Inner disk radius
  final double phase; // External phase for spinning effect

  SoundRaysPainter({
    required this.amplitude,
    required this.innerRadius,
    required this.phase,
  });

  double _normalizeAmplitude(double dbfs) {
    // Normalize dBFS (0 to -40) into a range of 0 to 1
    return dbfs > -40 ? (1 + dbfs / 40) : 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Don't paint if amplitude is null
    if (amplitude == null) return;

    final soundLevel = _normalizeAmplitude(amplitude!.current);
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill; // Use fill to draw filled wedges

    final center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = size.width / 2; // Size defines the outer radius

    // Draw central circle (eclipse disk)
    canvas.drawCircle(center, innerRadius, Paint()..color = Colors.black);

    // Number of rays
    int rayCount = 120;
    double angleStep = 2 * pi / rayCount;

    for (int i = 0; i < rayCount; i++) {
      double angle =
          i * angleStep + phase; // Add global phase for smooth spinning

      // Different heights for peaks, with the highest peak correlating to soundLevel
      double waveEffect = (sin(angle + phase) +
              1 / 2 * sin(2 * angle + phase) +
              1 / 3 * sin(3 * angle + phase) +
              1 / 4 * sin(4 * angle + phase) +
              1 / 5 * sin(5 * angle + phase) +
              1 / 6 * sin(6 * angle + phase)) *
          (outerRadius / 8) *
          soundLevel;

      double rayLength =
          outerRadius * 1.1 + 4 * waveEffect; // Base ray length + peak height

      // Start and end points for the ray
      double startX = center.dx + cos(angle) * innerRadius;
      double startY = center.dy + sin(angle) * innerRadius;
      double endX = center.dx + cos(angle) * rayLength;
      double endY = center.dy + sin(angle) * rayLength;

      // Define the path for the wedge
      Path rayPath = Path()
        ..moveTo(startX, startY) // Move to the start point
        ..lineTo(endX, endY) // Draw line to the outer end
        ..lineTo(
            center.dx + cos(angle + 0.25 * pi / rayCount) * rayLength,
            center.dy +
                sin(angle + 0.25 * pi / rayCount) *
                    rayLength) // Draw the second side of the wedge
        ..close(); // Close the path to create a filled wedge

      canvas.drawPath(rayPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when sound level or phase changes
  }
}
