import 'dart:async';

import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';

part 'controller.g.dart';

// ignore: library_private_types_in_public_api
class FreeStylingController = _FreeStylingController with _$FreeStylingController;

abstract class _FreeStylingController with Store {
  ObservableList<int> motor1Intensities = ObservableList.of([]);
  ObservableList<int> motor2Intensities = ObservableList.of([]);

  final ToyCubit toyCubit;
  final MotorSelectorCubit motorSelectorCubit;

  _FreeStylingController({required this.toyCubit, required this.motorSelectorCubit});

  static const signalSendingPeriod = Duration(milliseconds: 20);
  Timer? signalSendingTimer;

  double _freeStylingSpeed = 0;

  /// This buffer helps to handle 'double' values for intensity increase,
  /// as actual device only accepts integer values.
  final _intensityIncreaseBuffer = [0.0, 0.0];

  int? lastSelectedMotor;

  set freeStylingSpeed(double freeStylingSpeed) {
    _freeStylingSpeed = freeStylingSpeed;
    final selectedMotor = motorSelectorCubit.state.motorNumber;
    final currentMotorIntensity = toyCubit.state.getIntensity(selectedMotor);

    if (selectedMotor != lastSelectedMotor) {
      /// Reset the controller for the newly selected motor.
      signalSendingTimer?.cancel();
      signalSendingTimer = null;
      lastSelectedMotor = selectedMotor;
    }

    if (_freeStylingSpeed == 0 ||
        _freeStylingSpeed < 0 && currentMotorIntensity == 0 ||
        _freeStylingSpeed > 0 && currentMotorIntensity == 99) {
      signalSendingTimer?.cancel();
      signalSendingTimer = null;
    } else {
      signalSendingTimer ??= Timer.periodic(
        signalSendingPeriod,
        (timer) {
          _intensityIncreaseBuffer[selectedMotor] += _freeStylingSpeed;
          final currentMotorIntensity = toyCubit.state.getIntensity(selectedMotor);

          if (currentMotorIntensity == 0 && _intensityIncreaseBuffer[selectedMotor] < 0 ||
              currentMotorIntensity == 99 && _intensityIncreaseBuffer[selectedMotor] > 0) {
            _intensityIncreaseBuffer[selectedMotor] = 0;
          } else {
            final intensityChange = _intensityIncreaseBuffer[selectedMotor].truncate();
            var mainMotor = toyCubit.state.motor1Int;
            var subMotor = toyCubit.state.motor2Int;
            if (selectedMotor == 0) {
              mainMotor += intensityChange;
              mainMotor = mainMotor.clamp(0, 99);
              motor1Intensities.add(mainMotor);
            } else {
              subMotor += intensityChange;
              subMotor = subMotor.clamp(0, 99);
              motor2Intensities.add(subMotor);
            }
            _intensityIncreaseBuffer[selectedMotor] -= intensityChange;

            toyCubit.vibrate(mainMotor, subMotor);
          }
        },
      );
    }
  }
}
