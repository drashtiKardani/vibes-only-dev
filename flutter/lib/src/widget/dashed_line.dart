import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class HorizontalDashedLine extends StatelessWidget {
  const HorizontalDashedLine({super.key, this.color = AppColors.grey3A, this.strokeWidth = 1.5});

  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(painter: DashedLinePainter(color, strokeWidth)),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 0.1, dashSpace = 8, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
