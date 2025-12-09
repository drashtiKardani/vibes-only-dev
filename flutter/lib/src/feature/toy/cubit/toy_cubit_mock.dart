import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/service/logger.dart';
import 'package:flutter_blue_plus_platform_interface/src/bluetooth_msgs.dart';

class ToyCubitMock extends ToyCubitImpl {
  @override
  Future<void> search() async {
    emit(state.copyWith(
      discoveredDevices: GetIt.I<CommoditiesStore>()
          .knownToys
          .map((e) => e.bluetoothName)
          .map(
            (deviceName) => ScanResult.fromProto(
              BmScanAdvertisement(
                remoteId: DeviceIdentifier('mock_device__$deviceName'),
                platformName: deviceName,
                advName: deviceName,
                connectable: true,
                txPowerLevel: null,
                manufacturerData: {},
                serviceData: {},
                serviceUuids: [],
                rssi: 12345,
                appearance: null,
              ),
            ),
          )
          .toList(),
    ));
  }

  @override
  void exitFromSearch() {}

  @override
  Future<void> connect(ScanResult result) async {
    emit(state.copyWith(connectedDevice: result));
    Logger.toy.i('${result.bluetoothName} faux connected 🤨.');

    const batteryReducingPeriod = 10; // seconds
    emit(state.copyWith(batteryPercentage: 100));
    Logger.toy
        .i('Setup timer to reduce battery every ${batteryReducingPeriod}s 🤨.');
    Timer.periodic(const Duration(seconds: batteryReducingPeriod), (Timer t) {
      if (state.batteryPercentage == 0) {
        t.cancel();
      } else {
        emit(state.copyWith(batteryPercentage: state.batteryPercentage - 1));
      }
    });

    doInitialReadAndWrites();
  }

  @override
  Future<void> disconnect() async {
    emit(ToyState(discoveredDevices: state.discoveredDevices));
  }

  @override
  Future<void> write(BluetoothDevice device, String command,
      {bool withoutResponse = false}) async {
    log('write', '$command --decode--> ${decodeCommand(command)}');
  }

  @override
  Future<void> switchLight() async {
    await super.switchLight();
    emit(state.copyWith(isLightOn: !state.isLightOn));
  }
}
