import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';

import '../../../../service/logger.dart';
import '../../cubit/toy_cubit.dart';
import '../motor_selector/motor_selector_cubit.dart';
import 'intensity_wheel_whole.dart';

class IntensityWheel extends StatefulWidget {
  const IntensityWheel({super.key});

  @override
  State<IntensityWheel> createState() => _IntensityWheelState();
}

class _IntensityWheelState extends State<IntensityWheel> {
  ToyCubit get toy => BlocProvider.of<ToyCubit>(context);

  /// Space below the wheel, for ease of touch of bottom part.
  /// For the grey bar drawn at the bottom see [IntensityWheelWhole].
  static const double bottomPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableHeight = constraints.maxHeight;
      final wheelRadius = constraints.maxWidth / 2 - 10;
      double wheelYTransform = wheelRadius;
      if (availableHeight < 2 * wheelRadius) {
        wheelYTransform = availableHeight - wheelYTransform;
      }

      /// apply the bottom padding
      wheelYTransform -= bottomPadding;

      /// height factor as a function of [bottomPadding].
      final heightFactor = (wheelRadius + bottomPadding) / (2 * wheelRadius);
      return ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: heightFactor,
          child: Container(
            transform: Matrix4.translationValues(0, wheelYTransform, 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:
                  BlocBuilder<ToyCubit, ToyState>(builder: (context, toyState) {
                return BlocBuilder<MotorSelectorCubit, ToyMotor>(
                    builder: (context, selectedMotor) {
                  return IntensityWheelWhole(
                    onNewAngleSelected: (double angle) {
                      if (toy.state.getPattern(selectedMotor.motorNumber) ==
                          0) {
                        /// Manual mode intensity
                        int intensity1 = toyState.motor1Int;
                        int intensity2 = toyState.motor2Int;
                        int intensity3 = toyState.motor3Int;

                        if (selectedMotor == ToyMotor.mainMotor) {
                          intensity1 =
                              (angle / math.pi * 100).round().clamp(0, 99);
                        } else if (selectedMotor == ToyMotor.subMotor) {
                          intensity2 =
                              (angle / math.pi * 100).round().clamp(0, 99);
                        } else {
                          intensity3 =
                              (angle / math.pi * 100).round().clamp(0, 99);
                        }

                        vibrateWithThrottle(intensity1, intensity2, intensity3);
                      } else {
                        /// Pattern mode intensity
                        final intensity =
                            (angle / math.pi * 100).round().clamp(0, 99);
                        toy.patternIntensity(
                          selectedMotor.motorNumber,
                          intensity,
                        );
                      }
                    },
                    selectedAngle:
                        toy.state.getPattern(selectedMotor.motorNumber) == 0
                            ? selectedMotor == ToyMotor.mainMotor
                                ? toyState.motor1Int / 100 * math.pi
                                : selectedMotor == ToyMotor.subMotor
                                    ? toyState.motor2Int / 100 * math.pi
                                    : toyState.motor3Int / 100 * math.pi
                            : selectedMotor == ToyMotor.mainMotor
                                ? toyState.motor1IntRatio / 100 * math.pi
                                : selectedMotor == ToyMotor.subMotor
                                    ? toyState.motor2IntRatio / 100 * math.pi
                                    : toyState.motor3IntRatio / 100 * math.pi,
                  );
                });
              }),
            ),
          ),
        ),
      );
    });
  }

  final intensitySteps = {
    bleDeviceNames[0]: 5, // ashley
    bleDeviceNames[1]: 5, // rayna
    bleDeviceNames[2]: 10, // gigi
  };

  void vibrateWithThrottle(int intensity0, int intensity1, int intensity2) {
    // Throttling the intensity change command.
    // Excess firing of commands to the device, seems to cause the device to lag behind the intensity wheel.
    // This problem is more evident in the iOS devices.
    int intensityStep = intensitySteps[toy.connectedDeviceName] ?? 5;
    bool mustRunZeroCommand = intensity0 == 0 && toy.state.motor1Int != 0 ||
        intensity1 == 0 && toy.state.motor2Int != 0 ||
        intensity2 == 0 && toy.state.motor3Int != 0;
    if (!mustRunZeroCommand &&
        (intensity0 - toy.state.motor1Int).abs() < intensityStep &&
        (intensity1 - toy.state.motor2Int).abs() < intensityStep &&
        (intensity2 - toy.state.motor3Int).abs() < intensityStep) {
      Logger.toy.v(
          'Intensity change was less than $intensityStep. Skipping command.');
      return;
    }

    if (toy.isConnected()) {
      // manual mode; no need to set pattern
      toy.vibrate(intensity0, intensity1, thirdMotor: intensity2);
    } else {
      print('Device is not connected. Command: '
          'Manual mode (pattern 1)::'
          'Vibrate with intensities=$intensity0,$intensity1,$intensity2;');
    }
  }
}
