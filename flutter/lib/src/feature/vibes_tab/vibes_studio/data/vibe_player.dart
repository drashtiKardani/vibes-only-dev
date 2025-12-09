import 'dart:async';

import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';

import 'new_vibe_store.dart';
import 'vibe_bar_data.dart';

part 'vibe_player.g.dart';

// ignore: library_private_types_in_public_api
class VibePlayer = _VibePlayer with _$VibePlayer;

abstract class _VibePlayer with Store {
  final ToyCubit _toyCubit;

  _VibePlayer(this._toyCubit);

  /// Length will be always 3. Each position corresponds to a motor. null means nothing is currently playing on that motor.
  final ObservableList<NewVibeStore?> _currentlyPlaying =
      ObservableList.of([null, null, null]);

  @computed
  NewVibeStore? get currentlyPlayingOnMotor1 => _currentlyPlaying[0];

  @computed
  NewVibeStore? get currentlyPlayingOnMotor2 => _currentlyPlaying[1];

  @computed
  NewVibeStore? get currentlyPlayingOnMotor3 => _currentlyPlaying[2];

  /// A timer for each motor.
  final List<Timer?> _timer = [null, null, null];

  @action
  void stopMotor1() => _stopMotor(0);

  @action
  void playOnMotor1(NewVibeStore vibe) => _playOnMotor(0, vibe);

  @action
  void stopMotor2() => _stopMotor(1);

  @action
  void playOnMotor2(NewVibeStore vibe) => _playOnMotor(1, vibe);

  @action
  void stopMotor3() => _stopMotor(2);

  @action
  void playOnMotor3(NewVibeStore vibe) => _playOnMotor(2, vibe);

  @action
  void _stopMotor(int motorIndex) {
    _cancelTimerFor(motorIndex);
    _currentlyPlaying[motorIndex] = null;
    _toyCubit.stop(connectedToyHasTwoMotors ? motorIndex : 0);
  }

  bool get connectedToyHasTwoMotors => GetIt.I<CommoditiesStore>()
      .toyHasTwoMotors(_toyCubit.state.connectedDevice?.bluetoothName);

  @action
  void _playOnMotor(int motorIndex, NewVibeStore vibe) {
    final timeline = motorIndex == 0 ? vibe.timeline1 : vibe.timeline2;
    if (timeline.data.isEmpty) return;

    // Note that the index used for executing a command may be different than the selected one.
    final deviceMotorIndex = connectedToyHasTwoMotors ? motorIndex : 0;
    if (!connectedToyHasTwoMotors) {
      // This prevents intertwining of commands on single motor devices.
      // We can ask them to run on second motor, and they just run the second pattern on first motor.
      _stopMotor(1 - motorIndex /* index of the other motor */);
    }

    double addDurations(double currentSum, VibeBarData element) =>
        currentSum + element.duration;

    final totalLengthInSecs = timeline.data.fold<double>(0.0, addDurations);
    var currentPlayHeadInSecs = 0.0;
    int? indexOfCurrentlyPlayingBar;

    void runToyCommand() {
      final logicalPlayHeadInSecs = currentPlayHeadInSecs % totalLengthInSecs;
      var index = 0;
      while (logicalPlayHeadInSecs >
          timeline.data.take(index + 1).fold<double>(0.0, addDurations)) {
        index++;
      }

      // No need to send millions of commands.
      if (index == indexOfCurrentlyPlayingBar) return;
      indexOfCurrentlyPlayingBar = index;

      final patternIndex = timeline.data[index].patternIndex;
      if (patternIndex == 0) {
        // Special case: Pattern 0 is equivalent to stop. Vibrate instead.
        final intensity = timeline.data[index].intensity;
        if (deviceMotorIndex == 0) {
          _toyCubit.vibrate(intensity, 0);
        } else {
          _toyCubit.vibrate(0, intensity);
        }
      } else {
        _toyCubit.pattern(deviceMotorIndex, patternIndex);
      }
    }

    _cancelTimerFor(motorIndex);

    runToyCommand();
    const periodInSecs = 0.1;
    final period = Duration(milliseconds: (periodInSecs * 1000).toInt());
    _timer[motorIndex] = Timer.periodic(period, (timer) {
      currentPlayHeadInSecs += periodInSecs;
      runToyCommand();
    });
    _currentlyPlaying[motorIndex] = vibe;
  }

  void _cancelTimerFor(int motorIndex) {
    _timer[motorIndex]?.cancel();
    _timer[motorIndex] = null;
  }
}
