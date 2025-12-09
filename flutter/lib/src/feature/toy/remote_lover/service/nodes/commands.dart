import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/constants.dart';

import '../../../../../service/logger.dart';

class RemoteLoverCommands {
  final DatabaseReference _commandsNodeReference;

  RemoteLoverCommands({required DatabaseReference connectionRoot})
      : _commandsNodeReference = connectionRoot.child(Node.commands);

  Stream<DatabaseEvent> get stream => _commandsNodeReference.onChildAdded;

  void disconnect() {
    _commandsNodeReference.push().set(DisconnectCommand().asMap());
  }

  void pattern(int motorId, int pattern) {
    _commandsNodeReference
        .push()
        .set(PatternCommand(motorId: motorId, pattern: pattern).asMap());
  }

  void vibrate(int mainMotorIntensity, int subMotorIntensity,
      {int thirdMotorIntensity = 0}) {
    _commandsNodeReference.push().set(VibrateCommand(
            mainMotorIntensity: mainMotorIntensity,
            subMotorIntensity: subMotorIntensity,
            thirdMotorIntensity: thirdMotorIntensity)
        .asMap());
  }

  void patternIntensity(int motorId, int intensity) {
    _commandsNodeReference.push().set(
        PatternIntensityCommand(motorId: motorId, intensity: intensity)
            .asMap());
  }
}

extension RemoteLoverCommandAdapter on DataSnapshot {
  RemoteLoverCommand? asCommand() {
    final map = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
    final command = DisconnectCommand.fromMap(map) ??
        PatternCommand.fromMap(map) ??
        VibrateCommand.fromMap(map);
    if (command == null) {
      Logger.remoteLover.e('Received command  $value is not parsable.');
    }
    return command;
  }
}

abstract class RemoteLoverCommand {
  Map<String, dynamic> asMap();

  void run(ToyCubit target);
}

class DisconnectCommand extends RemoteLoverCommand {
  static const _disconnect = 'disconnect';

  @override
  Map<String, dynamic> asMap() {
    return {_disconnect: true};
  }

  @override
  void run(ToyCubit target) {
    target.disconnect();
  }

  static DisconnectCommand? fromMap(Map<String, dynamic> map) {
    if (map.containsKey(_disconnect) && map[_disconnect] == true) {
      return DisconnectCommand();
    }
    return null;
  }
}

class PatternCommand extends RemoteLoverCommand {
  static const _motorId = 'motorId';
  static const _pattern = 'pattern';

  final int motorId;
  final int pattern;

  PatternCommand({required this.motorId, required this.pattern});

  @override
  Map<String, dynamic> asMap() {
    return {
      _motorId: motorId,
      _pattern: pattern,
    };
  }

  @override
  void run(ToyCubit target) {
    target.pattern(motorId, pattern);
  }

  static PatternCommand? fromMap(Map<String, dynamic> map) {
    if (map.containsKey(_motorId) &&
        map.containsKey(_pattern) &&
        map[_motorId] is int &&
        map[_pattern] is int) {
      return PatternCommand(motorId: map[_motorId], pattern: map[_pattern]);
    }
    return null;
  }
}

class VibrateCommand extends RemoteLoverCommand {
  static const _mainMotorIntensity = 'mainMotorIntensity';
  static const _subMotorIntensity = 'subMotorIntensity';
  static const _thirdMotorIntensity = 'thirdMotorIntensity';

  final int mainMotorIntensity;
  final int subMotorIntensity;
  final int thirdMotorIntensity;

  VibrateCommand(
      {required this.mainMotorIntensity,
      required this.subMotorIntensity,
      this.thirdMotorIntensity = 0});

  @override
  Map<String, dynamic> asMap() {
    return {
      _mainMotorIntensity: mainMotorIntensity,
      _subMotorIntensity: subMotorIntensity,
      _thirdMotorIntensity: thirdMotorIntensity,
    };
  }

  @override
  void run(ToyCubit target) {
    target.vibrate(mainMotorIntensity, subMotorIntensity,
        thirdMotor: thirdMotorIntensity);
  }

  static VibrateCommand? fromMap(Map<String, dynamic> map) {
    if (map.containsKey(_mainMotorIntensity) &&
        map.containsKey(_subMotorIntensity) &&
        map[_mainMotorIntensity] is int &&
        map[_subMotorIntensity] is int) {
      return VibrateCommand(
        mainMotorIntensity: map[_mainMotorIntensity],
        subMotorIntensity: map[_subMotorIntensity],
        thirdMotorIntensity: map[_thirdMotorIntensity] ?? 0,
      );
    }
    return null;
  }
}

class PatternIntensityCommand extends RemoteLoverCommand {
  static const String _motorId = 'motorId';
  static const String _intensity = 'intensity';

  final int motorId;
  final int intensity;

  PatternIntensityCommand({required this.motorId, required this.intensity});

  @override
  Map<String, dynamic> asMap() {
    return {_motorId: motorId, _intensity: intensity};
  }

  @override
  void run(ToyCubit target) {
    target.patternIntensity(motorId, intensity);
  }

  static PatternIntensityCommand? fromMap(Map<String, dynamic> map) {
    if (map.containsKey(_motorId) &&
        map.containsKey(_intensity) &&
        map[_motorId] is int &&
        map[_intensity] is int) {
      return PatternIntensityCommand(
        motorId: map[_motorId],
        intensity: map[_intensity],
      );
    }
    return null;
  }
}
