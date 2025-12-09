import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_mobile_app_presentation/audio.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';

class ToyCommandServiceImpl extends ToyCommandService {
  _ToyCommandListExecutioner? _motor0Exec;
  _ToyCommandListExecutioner? _motor1Exec;

  ToyCommandServiceImpl() : super();

  @override
  bool get currentStoryContainsVibes => _currentStoryContainsVibes;

  @override
  void pause() {
    emit(ToyCommandServiceState.inactive);
    _motor0Exec?.stop();
    _motor1Exec?.stop();
    print('ToyCommandService DEACTIVATED');
  }

  @override
  void resume() {
    emit(ToyCommandServiceState.active);
    print('ToyCommandService ACTIVATED');
  }

  StreamSubscription<Duration>? _playbackPositionSub;
  StreamSubscription<PlaybackState>? _playbackStateSub;

  bool _currentStoryContainsVibes = false;
  List<AllToyCommands>? _currentToyCommands;

  @override
  void executeSynchronizedWithAudio(List<AllToyCommands> toyCommands, ToyCubit toyCubit) {
    _currentToyCommands = toyCommands;
    final deviceCommands = _getDeviceCommands(toyCommands, toyCubit.state);
    _processCommands(toyCubit, deviceCommands);
  }

  @override
  void toyStateChanged(ToyState state, ToyCubit toyCubit) {
    if (_currentToyCommands != null) {
      final deviceCommands = _getDeviceCommands(_currentToyCommands!, state);
      _processCommands(toyCubit, deviceCommands);
    } else {
      print('> ERROR: _currentToyCommands is null. Something went wrong.');
    }
  }

  void _processCommands(ToyCubit toyCubit, AllToyCommands? deviceCommands) {
    _stopReceivingPlaybackEvents();
    _stopMotors(toyCubit);

    if (deviceCommands == null) {
      _currentStoryContainsVibes = false;
      _motor0Exec = null;
      _motor1Exec = null;
      emit(ToyCommandServiceState.inactive);
      print('> No Commands to execute');
      print('  ToyCommandService DEACTIVATED');
    } else {
      _currentStoryContainsVibes = true;

      final motorIntensities = [0, 0];
      _motor0Exec = _ToyCommandListExecutioner(
          deviceCommands.motorCommands.firstWhere(
            (element) => element.motorId == 0,
          ),
          toyCubit,
          motorIntensities);
      _motor1Exec = _ToyCommandListExecutioner(
          deviceCommands.motorCommands.firstWhere(
            (element) => element.motorId == 1,
            orElse: () => MotorToyCommands.unavailable,
          ),
          toyCubit,
          motorIntensities);

      _startReceivingPlaybackEvents();
    }
  }

  void _startReceivingPlaybackEvents() {
    print("> START getting playback position events from AudioService");
    _playbackPositionSub = AudioService.position.listen((Duration position) {
      if (state == ToyCommandServiceState.active) {
        _motor0Exec?.executeFor(position);
        _motor1Exec?.executeFor(position);
      }
    });

    print("> START getting playback state events from VibesAudioHandler");
    _playbackStateSub = VibesAudioHandler.instance.playbackState.listen((state) {
      if (!state.playing) {
        _motor0Exec?.stop();
        _motor1Exec?.stop();
      }
    });
  }

  void _stopReceivingPlaybackEvents() {
    print("> CANCEL getting playback position events from AudioService");
    _playbackPositionSub?.cancel();

    print("> CANCEL getting playback state events from VibesAudioHandler");
    _playbackStateSub?.cancel();
  }

  void _stopMotors(ToyCubit toyCubit) {
    print("> STOP command to both toy motors");
    if (toyCubit.state.connectedDevice != null) {
      toyCubit.stop(0);
      toyCubit.stop(1);
    }
  }

  AllToyCommands? _getDeviceCommands(List<AllToyCommands> listOfAllToyCommands, ToyState toyState) {
    if (listOfAllToyCommands.isEmpty) {
      return null;
    }

    // map between name of actual device and name that server sends.
    final deviceNameMapping = {
      "Ashley Wand": "Ashley",
      "Rayna Vibe": "Rayna",
      "Gigi Vibe": "Gigi",
    };
    final deviceName = toyState.connectedDevice?.bluetoothName;
    final serverSentName = deviceNameMapping[deviceName];

    return listOfAllToyCommands.firstWhere(
      (element) => element.toyName == serverSentName,
      orElse: () => listOfAllToyCommands[0],
    );
  }
}

class _ToyCommandListExecutioner {
  final MotorToyCommands motorCommands;
  late final List<ToyCommand> sortedCommands;
  final ToyCubit toyCubit;
  final List<int> motorIntensities;
  int nextCommandIndex = 0;
  ToyCommand lastCommand = ToyCommand.unknown;

  _ToyCommandListExecutioner(this.motorCommands, this.toyCubit, this.motorIntensities) {
    var commands = [...motorCommands.commands];
    commands.sort((a, b) => a.start.compareTo(b.start));
    sortedCommands = commands;
  }

  ToyCommand? executeFor(Duration position) {
    if (motorCommands == MotorToyCommands.unavailable) return null;

    final command = sortedCommands[nextCommandIndex];
    final motorId = motorCommands.motorId;
    nextCommandIndex = sortedCommands.indexWhere((command) => command.end > position);
    if (nextCommandIndex == -1) nextCommandIndex = sortedCommands.length - 1;

    if (position.isOutsideTimeSpanOf(command)) {
      if (lastCommand != ToyCommand.stop) {
        motorIntensities[motorId] = 0;
        if (toyCubit.state.connectedDevice != null) {
          toyCubit.stop(motorId);
        } else {
          print('${position.toString()} --- not connected. '
              'command: stop motor $motorId. intensities=$motorIntensities');
        }
      }
      lastCommand = ToyCommand.stop;
      return null;
    } else if (position.isInsideTimeSpanOf(command)) {
      if (lastCommand != command) {
        motorIntensities[motorId] = command.intensity;
        if (command.pattern == 1) {
          // MANUAL MODE
          if (toyCubit.state.connectedDevice != null) {
            toyCubit.vibrate(motorIntensities[0], motorIntensities[1]);
          } else {
            print('${position.toString()} --- not connected. MANUAL (p${command.pattern}) '
                'command: vibrate with intensities $motorIntensities; ');
          }
        } else {
          // AUTO MODE
          if (toyCubit.state.connectedDevice != null) {
            toyCubit.pattern(motorId, command.pattern);
          } else {
            print('${position.toString()} --- not connected. AUTO (p${command.pattern}) '
                'set motor$motorId pattern to ${command.pattern}; ');
          }
        }
      }
      lastCommand = command;
      return command;
    } else {
      return null;
    }
  }

  void stop() {
    if (lastCommand == ToyCommand.stop) return;

    if (toyCubit.state.connectedDevice != null) {
      toyCubit.stop(0);
      toyCubit.stop(1);
    } else {
      print("<No device Connected> STOP command to both motors; audio playback must have been stopped");
    }
    lastCommand = ToyCommand.stop;
  }
}

extension ToyCommandDuration on Duration {
  bool isInsideTimeSpanOf(ToyCommand command) {
    return this > command.start && this < command.end;
  }

  bool isOutsideTimeSpanOf(ToyCommand command) {
    return !isInsideTimeSpanOf(command);
  }
}
