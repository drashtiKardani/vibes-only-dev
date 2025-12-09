import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:rxdart/rxdart.dart';

import '../remote_lover/service/nodes/state.dart';
import '../remote_lover/service/service.dart';

class RemoteToyCubit extends ToyCubit {
  final RemoteLoverConnection connection;

  RemoteToyCubit(this.connection) : super(ToyState(discoveredDevices: []));

  @override
  bool get adminPanelSimulationMode => false;

  @override
  Future<void> connect(ScanResult result) async {}

  @override
  Future<void> disconnect() async {
    connection.commands.disconnect();
  }

  @override
  void pattern(int motorId, int pattern) {
    connection.commands.pattern(motorId, pattern);
    if (motorId == 0) {
      emit(state.copyWith(motor1Pat: pattern));
    } else if (motorId == 1) {
      emit(state.copyWith(motor2Pat: pattern));
    } else if (motorId == 2) {
      emit(state.copyWith(motor3Pat: pattern));
    }
  }

  @override
  void vibrate(int mainMotor, int subMotor, {int thirdMotor = 0}) {
    connection.commands
        .vibrate(mainMotor, subMotor, thirdMotorIntensity: thirdMotor);
    emit(state.copyWith(
      motor1Int: mainMotor,
      motor2Int: subMotor,
      motor3Int: thirdMotor, // Use the provided third motor intensity
      motor1Pat: 0,
      motor2Pat: 0,
      motor3Pat: 0,
    )); // Reset third motor pattern
  }

  /// This is used for controlling the intensity of a pattern.
  @override
  void patternIntensity(int motorId, int intensity) {
    connection.commands.patternIntensity(motorId, intensity);
    if (motorId == 0) {
      emit(state.copyWith(motor1IntRatio: intensity));
    } else if (motorId == 1) {
      emit(state.copyWith(motor2IntRatio: intensity));
    } else if (motorId == 2) {
      emit(state.copyWith(motor3IntRatio: intensity));
    }
  }

  @override
  String? get connectedDeviceName => connection.toyName;

  @override
  Stream<bool> disconnectSignal() => connection.state.stream
      .where((state) => state == ConnectionState.ended)
      .mapTo(true)
      .distinct();

  @override
  String? get displayName => 'Remote';

  @override
  Future<void> doInitialReadAndWrites() async {}

  @override
  void exitFromSearch() {}

  @override
  void getBattery() {}

  @override
  void getLight() {}

  @override
  void powerOff() {}

  @override
  Future<void> search() async {}

  @override
  Future<void> stop(int motorId) async {}

  @override
  Future<void> switchLight() async {}
}
