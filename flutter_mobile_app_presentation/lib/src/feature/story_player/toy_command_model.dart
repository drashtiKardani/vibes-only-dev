import 'dart:convert';

import 'package:sealed_annotations/sealed_annotations.dart';

class ToyCommand extends Equatable {
  final Duration start;
  final Duration end;
  final int intensity;
  final int pattern;

  @override
  List<Object?> get props => [start, end, intensity, pattern];

  const ToyCommand({
    required this.start,
    required this.end,
    required this.intensity,
    required this.pattern,
  });

  static const ToyCommand stop = ToyCommand(start: Duration.zero, end: Duration.zero, intensity: 0, pattern: 0);
  static const ToyCommand unknown = ToyCommand(start: Duration.zero, end: Duration.zero, intensity: -1, pattern: -1);

  factory ToyCommand.fromJson(Map<String, dynamic> json) {
    return ToyCommand(
      start: parseDuration(json["start"] as String),
      end: parseDuration(json["end"] as String),
      intensity: (json["height"] as num).round(),
      pattern: int.parse((json["type"] as String).substring(1)), // e.g. p1 -> 1,
    );
  }

  static Duration parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length != 3 || parts[2].split(',').length != 2) {
      throw FormatException(
          'Duration format was not as expected. '
          'Must be H:MM:SS,mmm',
          duration);
    }
    final secMillis = parts[2].split(',');
    return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(secMillis[0]),
        milliseconds: int.parse(secMillis[1]));
  }
}

class MotorToyCommands extends Equatable {
  final int motorId;
  final List<ToyCommand> commands;

  @override
  List<Object?> get props => [motorId];

  const MotorToyCommands({
    required this.motorId,
    required this.commands,
  });

  static const MotorToyCommands unavailable = MotorToyCommands(motorId: -1, commands: []);

  factory MotorToyCommands.fromJson(Map<String, dynamic> json) {
    return MotorToyCommands(
      // server sends m0 for Ashley, m1 for Gigi, & m2 and m3 for motor0 and motor1 of Rayna
      motorId: int.parse((json["id"] as String).substring(1)) <= 2 ? 0 : 1, // e.g. m0 -> 0
      commands: (json["beats"] as List<dynamic>).map((e) => ToyCommand.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class AllToyCommands {
  final String toyName;
  final List<MotorToyCommands> motorCommands;

  const AllToyCommands({
    required this.toyName,
    required this.motorCommands,
  });

  factory AllToyCommands.fromJson(Map<String, dynamic> json) {
    return AllToyCommands(
      toyName: json["name"] as String,
      motorCommands:
          (json["rows"] as List<dynamic>).map((e) => MotorToyCommands.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class StoryBeatDecoder {
  static List<AllToyCommands> decode(String? storyBeat) {
    if (storyBeat == null || storyBeat == "") return [];

    return (json.decode(storyBeat) as List<dynamic>)
        .map((e) => AllToyCommands.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
