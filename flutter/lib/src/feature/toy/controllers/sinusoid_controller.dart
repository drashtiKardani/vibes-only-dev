import 'dart:async';
import 'dart:math';

import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';

part 'sinusoid_controller.g.dart';

// ignore: library_private_types_in_public_api
class SinusoidController = _SinusoidController with _$SinusoidController;

abstract class _SinusoidController with Store {
  ObservableList<int> motor1Intensities = ObservableList.of([]);
  ObservableList<int> motor2Intensities = ObservableList.of([]);
  ObservableList<int> motor3Intensities = ObservableList.of([]);

  final ToyCubit toyCubit;
  final MotorSelectorCubit motorSelectorCubit;

  _SinusoidController(
      {required this.toyCubit, required this.motorSelectorCubit});

  @observable
  bool isOn = false;

  @action
  void turnOn() {
    if (isOn) return;
    _vibrateSinusoidal();
    isOn = true;
  }

  @action
  void turnOff() {
    signalSendingTimer?.cancel();
    signalSendingTimer = null;

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
    _amplitude = (power * (_maxIntensity - _baselineIntensity)).floor();
  }

  int _amplitude = 0;

  static const _maxIntensity = 99;
  static const _baselineIntensity = 50;
  static const _idleAmplitude = 10;

  /// Number of samples (different intensities) in each period.
  static const _samplingRate = 40;

  void _vibrateSinusoidal() {
    signalSendingTimer = Timer.periodic(signalSendingPeriod, (timer) {
      final selectedMotor = motorSelectorCubit.state.motorNumber;
      final effectiveAmplitude =
          _amplitude < _idleAmplitude ? _idleAmplitude : _amplitude;
      final intensity = (_baselineIntensity +
              sin(timer.tick / _samplingRate * 2 * pi) * effectiveAmplitude)
          .floor()
          .clamp(0, 99);

      var mainMotor = toyCubit.state.motor1Int;
      var subMotor = toyCubit.state.motor2Int;
      var thirdMotor = toyCubit.state.motor3Int;

      switch (selectedMotor) {
        case 0:
          mainMotor = intensity;
          motor1Intensities.add(intensity);
          break;
        case 1:
          subMotor = intensity;
          motor2Intensities.add(intensity);
          break;
        case 2:
          thirdMotor = intensity;
          motor3Intensities.add(intensity);
          break;
      }

      toyCubit.vibrate(mainMotor, subMotor, thirdMotor: thirdMotor);
    });
  }

  static const signalSendingPeriod = Duration(milliseconds: 50);
  Timer? signalSendingTimer;
}
