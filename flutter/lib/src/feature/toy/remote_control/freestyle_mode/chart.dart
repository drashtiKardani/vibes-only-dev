import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_only/src/feature/toy/remote_control/freestyle_mode/waves.dart';
import 'package:wave/config.dart';

import '../motor_selector/motor_selector_cubit.dart';

class Chart extends StatelessWidget {
  const Chart(
      {super.key,
      required this.motor1Intensities,
      required this.motor2Intensities});

  final List<int> motor1Intensities;
  final List<int> motor2Intensities;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorSelectorCubit, ToyMotor>(
        builder: (context, selectedMotor) {
      // Widget chartInFront, chartInBehind;
      // if (selectedMotor == ToyMotor.mainMotor) {
      //   chartInFront = CustomPaint(
      //     painter: _ChartPainter(motor1Intensities),
      //     child: Container(),
      //   );
      //   chartInBehind = CustomPaint(
      //     painter: _ChartPainter(motor2Intensities, glow: false),
      //     child: Container(),
      //   );
      // } else {
      //   chartInFront = CustomPaint(
      //     painter: _ChartPainter(motor2Intensities),
      //     child: Container(),
      //   );
      //   chartInBehind = CustomPaint(
      //     painter: _ChartPainter(motor1Intensities, glow: false),
      //     child: Container(),
      //   );
      // }
      return Stack(
        alignment: Alignment.center,
        children: [
          WaveWidget(
            config: CustomConfig(
              gradients: [
                [AppColors.primary, AppColors.primary20],
                [AppColors.primaryAlt1, AppColors.primaryAlt1Light],
                [AppColors.primaryAlt2, AppColors.primaryAlt2Light],
                [AppColors.primaryAlt3, AppColors.primaryAlt3Light],
              ],
              durations: [5000, 4000, 3000, 2000],
              heightPercentages: [0.9, 0.82, 0.73, 0.64],
            ),
            size: const Size(double.infinity, 100),
            intensity: selectedMotor == ToyMotor.mainMotor
                ? motor1Intensities.lastOrNull ?? 0
                : motor2Intensities.lastOrNull ?? 0,
          ),
          // chartInBehind,
          // chartInFront,
        ],
      );
    });
  }
}

// class _ChartPainter extends CustomPainter {
//   _ChartPainter(this.intensities, {this.glow = true});

//   final bool glow;
//   final List<int> intensities;

//   /// at most 100 points can be draws.
//   static const pointLimit = 100;

//   static const headCircleRadius = 3.0;

//   late final _paint = Paint()
//     ..strokeWidth = 2
//     ..color = glow ? Colors.white : AppColors.grey40;
//   final _shadowPaint1 = Paint()
//     ..strokeWidth = 2
//     ..style = PaintingStyle.stroke
//     ..color = AppColors.vibesPink
//     ..imageFilter = ImageFilter.blur(sigmaX: 5, sigmaY: 5);
//   final _shadowPaint2 = Paint()
//     ..strokeWidth = 2
//     ..style = PaintingStyle.stroke
//     ..color = AppColors.vibesPink
//     ..imageFilter = ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (intensities.isEmpty) return; // have at lease one point to paint.

//     final last100Intensities =
//         intensities.length > pointLimit ? intensities.sublist(intensities.length - pointLimit) : intensities;
//     final dx = size.width / pointLimit;
//     var x = 0.0;
//     yForIntensity(int intensity) => (100.0 - intensity) / 100 * size.height;

//     final path = Path();
//     path.moveTo(x, yForIntensity(last100Intensities.first));
//     for (final intensity in last100Intensities) {
//       path.lineTo(x, yForIntensity(intensity));
//       x += dx;
//     }
//     canvas.drawPath(path, _paint..style = PaintingStyle.stroke);
//     canvas.drawCircle(
//         Offset(x - dx, yForIntensity(last100Intensities.last)), headCircleRadius, _paint..style = PaintingStyle.fill);

//     if (glow) {
//       canvas.drawPath(path, _shadowPaint1);
//       canvas.drawPath(path, _shadowPaint2);
//       canvas.drawCircle(Offset(x - dx, yForIntensity(last100Intensities.last)), headCircleRadius, _shadowPaint1);
//       canvas.drawCircle(Offset(x - dx, yForIntensity(last100Intensities.last)), headCircleRadius, _shadowPaint2);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
