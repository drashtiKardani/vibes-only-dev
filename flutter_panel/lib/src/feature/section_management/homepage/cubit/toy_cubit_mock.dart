import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';

class ToyCubitMock extends ToyCubit {
  ToyCubitMock() : super(ToyState(discoveredDevices: []));

  @override
  bool get adminPanelSimulationMode => true;

  @override
  Future<void> connect(ScanResult result) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> doInitialReadAndWrites() async {}

  @override
  void exitFromSearch() {}

  @override
  void getBattery() {}

  @override
  void getLight() {}

  @override
  void pattern(int motorId, int pattern) {}

  @override
  void powerOff() {}

  @override
  Future<void> search() async {}

  @override
  Future<void> stop(int motorId) async {}

  @override
  Future<void> switchLight() async {}
  @override
  void vibrate(int mainMotor, int subMotor, {int thirdMotor = 0}) {}

  @override
  String? get connectedDeviceName => throw UnimplementedError();

  @override
  Stream<bool> disconnectSignal() {
    throw UnimplementedError();
  }

  @override
  String? get displayName => throw UnimplementedError();
}
