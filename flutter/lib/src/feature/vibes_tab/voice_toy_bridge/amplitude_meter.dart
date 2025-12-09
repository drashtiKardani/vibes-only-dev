import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:record/record.dart';

class AmplitudeMeter extends StatelessWidget {
  final Amplitude? amplitude;
  final Axis direction;
  final Color topColor;
  final Color bottomColor;
  final Color offColor;
  final Color noSignalColor;

  const AmplitudeMeter({
    super.key,
    required this.amplitude,
    this.direction = Axis.vertical,
    this.topColor = AppColors.primaryAlt1,
    this.bottomColor = AppColors.primaryAlt1Light,
    this.offColor = AppColors.grey30,
    this.noSignalColor = AppColors.grey20,
  });

  static const _midHeight = 330.0;
  static const _sideHeight = 310.0;
  static const _width = 16.0;

  static const _midDots = 24;
  static const _sideDots = 21;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _midHeight,
      transform: Matrix4.identity() * 0.6,
      transformAlignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            painter: AmplitudePainter(amplitude, direction, topColor, bottomColor, offColor, noSignalColor,
                indicatorLightsAreCircular: true, numOfSquares: _sideDots),
            size: const Size(_width, _sideHeight),
          ),
          CustomPaint(
            painter: AmplitudePainter(
                amplitude, direction, AppColors.primaryAlt2Light, AppColors.primaryAlt2, offColor, noSignalColor,
                indicatorLightsAreCircular: true, numOfSquares: _midDots),
            size: const Size(_width, _midHeight),
          ),
          CustomPaint(
            painter: AmplitudePainter(
                amplitude, direction, AppColors.primaryAlt3Light, AppColors.primaryAlt3, offColor, noSignalColor,
                indicatorLightsAreCircular: true, numOfSquares: _sideDots),
            size: const Size(_width, _sideHeight),
          ),
        ],
      ),
    );
  }
}

class AmplitudePainter extends CustomPainter {
  final Amplitude? amplitude;
  final Axis direction;
  final Color topColor;
  final Color bottomColor;
  final Color offColor;
  final Color noSignalColor;

  /// defaults to false: Light are [RRect] with constant `cornerRadius`/`sideSize`.
  final bool indicatorLightsAreCircular;

  /// How many indicators lights are placed in the column/row.
  final int numOfSquares;

  AmplitudePainter(this.amplitude, this.direction, this.topColor, this.bottomColor, this.offColor, this.noSignalColor,
      {this.indicatorLightsAreCircular = false, this.numOfSquares = 10});

  static const gapToSquareRatio = 0.2; // Gap between each two boxes, as ratio of box side.
  static const cornerRadiusToSideRatio = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = direction == Axis.horizontal
        ? size.width / (numOfSquares + (numOfSquares - 1) * gapToSquareRatio)
        : size.height / (numOfSquares + (numOfSquares - 1) * gapToSquareRatio);

    Paint paint = Paint();

    final noSignal = amplitude == null;

    double? normalizedAmplitude = noSignal ? null : (amplitude!.current - (-40)) / ((-10) - (-40));
    double? progress = normalizedAmplitude?.clamp(0.0, 1.0);
    double pos = direction == Axis.horizontal ? 0.0 : size.height - squareSize;

    for (var i = 0; i < numOfSquares; i++) {
      final relPos = (i + 1) / numOfSquares;
      final lightIsOn = !noSignal && relPos <= progress!;
      if (noSignal) {
        paint.color = noSignalColor;
      } else if (lightIsOn) {
        paint.color = Color.lerp(bottomColor, topColor, relPos)!;
      } else {
        paint.color = offColor;
      }

      final lightRect = RRect.fromRectAndRadius(
        direction == Axis.horizontal
            ? Rect.fromLTWH(pos, size.height / 2 - squareSize / 2, squareSize, squareSize)
            : Rect.fromLTWH(size.width / 2 - squareSize / 2, pos, squareSize, squareSize),
        Radius.circular(indicatorLightsAreCircular ? squareSize / 2 : squareSize * cornerRadiusToSideRatio),
      );

      canvas.drawRRect(lightRect, paint);

      if (lightIsOn) {
        canvas.drawShadow(Path()..addRRect(lightRect), paint.color, 1, true);
        canvas.drawShadow(Path()..addRRect(lightRect), paint.color, 2, true);
      }

      if (direction == Axis.horizontal) {
        pos += gapToSquareRatio * squareSize;
        pos += squareSize;
      } else {
        pos -= gapToSquareRatio * squareSize;
        pos -= squareSize;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
