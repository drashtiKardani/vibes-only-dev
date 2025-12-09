import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/src/feature/toy/remote_control/speed/swipeable_bar_slider.dart';

import '../../../../service/logger.dart';
import '../../cubit/toy_cubit.dart';
import '../motor_selector/motor_selector_cubit.dart';

class SpeedSlider extends StatefulWidget {
  const SpeedSlider({super.key});

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  ToyCubit get toy => BlocProvider.of<ToyCubit>(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToyCubit, ToyState>(
      builder: (context, toyState) {
        return BlocBuilder<MotorSelectorCubit, ToyMotor>(
          builder: (context, selectedMotor) {
            return SwipeableBarSlider(
              totalBars: 48,
              completedColor: context.colorScheme.onSurface,
              remainingColor:
                  context.colorScheme.onSurface.withValues(alpha: 0.25),
              onChanged: (int angle) {
                if (toy.state.getPattern(selectedMotor.motorNumber) == 0) {
                  /// Manual mode intensity
                  int intensity1 = toyState.motor1Int;
                  int intensity2 = toyState.motor2Int;
                  int intensity3 = toyState.motor3Int;

                  if (selectedMotor == ToyMotor.mainMotor) {
                    intensity1 = (angle / math.pi * 100).round().clamp(0, 99);
                  } else if (selectedMotor == ToyMotor.subMotor) {
                    intensity2 = (angle / math.pi * 100).round().clamp(0, 99);
                  } else {
                    intensity3 = (angle / math.pi * 100).round().clamp(0, 99);
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
            );
          },
        );
      },
    );
  }

  final Map<String, int> intensitySteps = {
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
