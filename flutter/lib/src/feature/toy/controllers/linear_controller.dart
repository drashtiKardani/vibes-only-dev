import 'dart:async';

import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';

part 'linear_controller.g.dart';

// ignore: library_private_types_in_public_api
class LinearController = _LinearController with _$LinearController;

abstract class _LinearController with Store {
  ObservableList<int> motor1Intensities = ObservableList.of([]);
  ObservableList<int> motor2Intensities = ObservableList.of([]);
  ObservableList<int> motor3Intensities = ObservableList.of([]);

  final ToyCubit toyCubit;
  final MotorSelectorCubit motorSelectorCubit;

  _LinearController({required this.toyCubit, required this.motorSelectorCubit});

  @observable
  bool isOn = false;

  @action
  void turnOn() {
    if (isOn) return;
    _vibrateLinear();
    isOn = true;
  }

  @action
  void turnOff() {
    signalSendingTimer?.cancel();
    signalSendingTimer = null;
    _intensity = 0;

    motor1Intensities.add(0);
    motor2Intensities.add(0);
    motor3Intensities.add(0);

    toyCubit.stop(0);
    toyCubit.stop(1);
    toyCubit.stop(2);
    isOn = false;
  }

  void setNormalizedPower(double power) {
    power = power.clamp(0, 1);
    _intensity = (power * _maxIntensity).floor();
  }

  int _intensity = 0;

  static const _maxIntensity = 80;
  static const _baselineIntensity = 30;

  void _vibrateLinear() {
    signalSendingTimer = Timer.periodic(signalSendingPeriod, (timer) {
      final selectedMotor = motorSelectorCubit.state.motorNumber;
      final intensity =
          _intensity < _baselineIntensity ? _baselineIntensity : _intensity;

      var mainMotor = toyCubit.state.motor1Int;
      var subMotor = toyCubit.state.motor2Int;
      var thirdMotor = toyCubit.state.motor3Int;

      if (selectedMotor == 0) {
        mainMotor = intensity;
        motor1Intensities.add(intensity);
      } else if (selectedMotor == 1) {
        subMotor = intensity;
        motor2Intensities.add(intensity);
      } else {
        thirdMotor = intensity;
        motor3Intensities.add(intensity);
      }
      toyCubit.vibrate(mainMotor, subMotor, thirdMotor: thirdMotor);
    });
  }

  static const signalSendingPeriod = Duration(milliseconds: 100);
  Timer? signalSendingTimer;
}
