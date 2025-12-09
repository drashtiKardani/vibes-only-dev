import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class ToyCubit extends Cubit<ToyState> {
  ToyCubit(super.initialState);

  Future<void> search();

  void exitFromSearch();

  Future<void> connect(ScanResult result);

  Future<void> doInitialReadAndWrites();

  void getBattery();

  void getLight();

  Future<void> switchLight();

  void powerOff();

  void vibrate(int mainMotor, int subMotor, {int thirdMotor});

  void pattern(int motorId, int pattern);

  void patternIntensity(int motorId, int intensity) {}

  Future<void> disconnect();

  Future<void> stop(int motorId);

  bool get adminPanelSimulationMode;

  String? get connectedDeviceName;

  String? get displayName;

  bool isConnected() => connectedDeviceName != null;

  /// Sends 'true' if target is disconnected.
  Stream<bool> disconnectSignal();
}

class ToyState {
  ToyState({
    required this.discoveredDevices,
    this.connectedDevice,
    this.authenticated = false,
    this.batteryPercentage = 0,
    this.isLightOn = false,
    this.motor1Int = 0,
    this.motor2Int = 0,
    this.motor3Int = 0,
    this.motor1Pat = 0,
    this.motor2Pat = 0,
    this.motor3Pat = 0,
    this.motor1IntRatio = 0,
    this.motor2IntRatio = 0,
    this.motor3IntRatio = 0,
  });

  final List<ScanResult> discoveredDevices;
  final ScanResult? connectedDevice;
  final bool authenticated;
  final int batteryPercentage;
  final bool isLightOn;
  final int motor1Int;
  final int motor2Int;
  final int motor3Int;
  final int motor1Pat;
  final int motor2Pat;
  final int motor3Pat;

  /// These are used for setting pattern intensities.
  final int motor1IntRatio;
  final int motor2IntRatio;
  final int motor3IntRatio;

  int getIntensity(int motorIndex) {
    switch (motorIndex) {
      case 0:
        return motor1Int;
      case 1:
        return motor2Int;
      case 2:
        return motor3Int;
      default:
        return 0;
    }
  }

  int getPattern(int motorIndex) {
    switch (motorIndex) {
      case 0:
        return motor1Pat;
      case 1:
        return motor2Pat;
      case 2:
        return motor3Pat;
      default:
        return 0;
    }
  }

  ToyState copyWith({
    List<ScanResult>? discoveredDevices,
    ScanResult? connectedDevice,
    bool? authenticated,
    int? batteryPercentage,
    bool? isLightOn,
    int? motor1Int,
    int? motor2Int,
    int? motor3Int,
    int? motor1Pat,
    int? motor2Pat,
    int? motor3Pat,
    int? motor1IntRatio,
    int? motor2IntRatio,
    int? motor3IntRatio,
  }) {
    return ToyState(
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      authenticated: authenticated ?? this.authenticated,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      isLightOn: isLightOn ?? this.isLightOn,
      motor1Int: motor1Int ?? this.motor1Int,
      motor2Int: motor2Int ?? this.motor2Int,
      motor3Int: motor3Int ?? this.motor3Int,
      motor1Pat: motor1Pat ?? this.motor1Pat,
      motor2Pat: motor2Pat ?? this.motor2Pat,
      motor3Pat: motor3Pat ?? this.motor3Pat,
      motor1IntRatio: motor1IntRatio ?? this.motor1IntRatio,
      motor2IntRatio: motor2IntRatio ?? this.motor2IntRatio,
      motor3IntRatio: motor3IntRatio ?? this.motor3IntRatio,
    );
  }

  @override
  String toString() {
    return "connectedDevice:$connectedDevice, authenticated:$authenticated";
  }
}
