import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/service/logger.dart';

import '../dev/hex.dart';
import '../dev/toy_commands.dart';
import '../remote_lover/service/nodes/commands.dart';

/// Although we're loading toys from the server,
/// for now, we need this hardcoded list for some special case configs.
/// See its usage for more info.
const List<String> bleDeviceNames = [
  "Ashley Wand",
  "Rayna Vibe",
  "Gigi Vibe",
  "Lucy Vibe",
  "Analise Vibe",
];

class ToyCubitImpl extends ToyCubit with ToyCommands {
  @override
  bool get adminPanelSimulationMode => false;

  ToyCubitImpl() : super(ToyState(discoveredDevices: []));

  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<List<ScanResult>>? _searchSubscription;

  @override
  Future<void> search() async {
    _searchSubscription?.cancel();
    try {
      await for (final state in FlutterBluePlus.adapterState.timeout(
        const Duration(seconds: 5),
      )) {
        if (state == BluetoothAdapterState.on) {
          break;
        }
      }
    } catch (e) {
      log('search', 'Blue state is not on');
    }
    FlutterBluePlus.startScan();

    if (Flavor.isStaging() &&
        SyncSharedPreferences.bluetoothDiscoverEverything.value) {
      _searchSubscription = FlutterBluePlus.scanResults.listen((devices) {
        print(
          'devices: ${devices.map((e) => e.bluetoothName.toString()).toList()}',
        );
        emit(state.copyWith(discoveredDevices: devices));
      });
    } else {
      // In Production only show known [bleDeviceNames].
      _searchSubscription = FlutterBluePlus.scanResults.listen((devices) {
        emit(
          state.copyWith(
            discoveredDevices: devices
                .where(
                  (d) => GetIt.I<CommoditiesStore>().knownToys
                      .map((e) => e.bluetoothName)
                      .contains(d.bluetoothName),
                )
                .toList(),
          ),
        );
      });
    }
  }

  @override
  void exitFromSearch() {
    FlutterBluePlus.stopScan();
    _searchSubscription?.cancel();
  }

  @override
  Future<void> connect(ScanResult result) async {
    Logger.toy.i('Connecting ${result.bluetoothName}...');
    _disconnect();
    var device = result.device;
    await device.connect(license: License.free);
    emit(state.copyWith(connectedDevice: result));
    Logger.toy.i('${result.bluetoothName} connected.');
    await _notify(device);
    await _auth(device);

    doInitialReadAndWrites();

    checkEvery2SecondsIfStillConnected();
  }

  @override
  Future<void> doInitialReadAndWrites() async {
    const waitBeforeNextCommand = 100; // milliseconds
    wait() async {
      Logger.toy.i('Wait ${waitBeforeNextCommand}ms');
      await Future.delayed(const Duration(milliseconds: waitBeforeNextCommand));
    }

    await wait();
    Logger.toy.i('Reading battery...');
    getBattery();

    const batteryReadPeriod = 15; // seconds
    Logger.toy.i(
      'Setup battery reading timer with period=${batteryReadPeriod}s.',
    );
    Timer.periodic(const Duration(seconds: batteryReadPeriod), (Timer t) {
      if (state.connectedDevice == null) {
        t.cancel();
      } else {
        getBattery();
      }
    });

    await wait();
    Logger.toy.i('Reading light...');
    getLight();

    await wait();
    Logger.toy.i('Write initial intensities: zero & zero');
    vibrate(0, 0);
  }

  @override
  void getBattery() {
    write(state.connectedDevice!.device, batteryCommand);
  }

  @override
  void getLight() {
    write(state.connectedDevice!.device, getLightCommand);
  }

  @override
  Future<void> switchLight() async {
    write(
      state.connectedDevice!.device,
      state.isLightOn ? lightOffCommand : lightOnCommand,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    getLight();
  }

  @override
  void powerOff() {
    write(state.connectedDevice!.device, powerOffCommand);
  }

  @override
  void vibrate(int mainMotor, int subMotor, {int thirdMotor = 0}) {
    // It's important to change the state first,
    // because logic of this part scales the arguments for a better result on the actuator.
    // Also set motor pattern indexes to 0, signaling the switch to manual mode.
    emit(
      state.copyWith(
        motor1Int: mainMotor,
        motor2Int: subMotor,
        motor3Int: thirdMotor, // Use the provided third motor intensity
        motor1Pat: 0,
        motor2Pat: 0,
        motor3Pat: 0,
      ),
    ); // Reset third motor pattern

    // In Rayna Vibe (the only two motor device), Intensity commands below 30, does not have any effects.
    // So we map requested intensity which is between 0 and 100 to a value between 30 and 99 (100 could cause problem).
    if (state.connectedDevice?.bluetoothName == bleDeviceNames[1]) {
      mainMotor = (30 + 69 / 100 * mainMotor).toInt();
      subMotor = (30 + 69 / 100 * subMotor).toInt();
    }
    // Similarly, map Lucy Vibes's intensity to 20-99
    else if (state.connectedDevice?.bluetoothName == bleDeviceNames[3]) {
      mainMotor = (20 + 79 / 100 * mainMotor).toInt();
    }

    // Check if the toy has three motors
    if (GetIt.I<CommoditiesStore>().toyHasThreeMotors(
      state.connectedDevice?.bluetoothName,
    )) {
      // For 3-motor devices, use the MM command with the provided third motor intensity
      write(
        state.connectedDevice!.device,
        multiMotorIntensityCommand(mainMotor, subMotor, thirdMotor),
      );
    } else {
      // For 1 or 2-motor devices, use the MtInt command
      write(
        state.connectedDevice!.device,
        motorIntensityCommand(mainMotor, subMotor),
      );
    }
  }

  @override
  void pattern(int motorId, int pattern) {
    write(state.connectedDevice!.device, patternCommand(motorId, pattern));
    if (motorId == 0) {
      emit(state.copyWith(motor1Pat: pattern));
    } else if (motorId == 1) {
      emit(state.copyWith(motor2Pat: pattern));
    } else if (motorId == 2) {
      emit(state.copyWith(motor3Pat: pattern));
    }
  }

  /// This is used for controlling the intensity of a pattern.
  @override
  void patternIntensity(int motorId, int intensity) {
    write(
      state.connectedDevice!.device,
      motorIntensityRangeAndRatioCommand(motorId, intensity),
    );
    if (motorId == 0) {
      emit(state.copyWith(motor1IntRatio: intensity));
    } else if (motorId == 1) {
      emit(state.copyWith(motor2IntRatio: intensity));
    } else if (motorId == 2) {
      emit(state.copyWith(motor3IntRatio: intensity));
    }
  }

  Future<void> _notify(BluetoothDevice device) async {
    _notifySubscription?.cancel();
    List<BluetoothService> services = await device.discoverServices();
    var service = services.firstWhere((d) => d.uuid == serviceUUID);

    var charNotify = service.characteristics.firstWhere(
      (d) => d.uuid == characteristicNotify,
    );
    await charNotify.setNotifyValue(true);
    _notifySubscription = charNotify.lastValueStream.listen((event) {
      if (event.isEmpty) return;
      var response = decodeCommand(HEX.encode(event));
      log('notify', response);
      _onCommandReceived(response);
    });
  }

  Future<void> write(
    BluetoothDevice device,
    String command, {
    bool withoutResponse = false,
  }) async {
    log('write', command);
    List<BluetoothService> services = await device.discoverServices();
    var service = services.firstWhere((d) => d.uuid == serviceUUID);
    var charWrite = service.characteristics.firstWhere(
      (d) => d.uuid == characteristicWrite,
    );
    return charWrite.write(
      HEX.decode(command),
      withoutResponse: withoutResponse,
    );
  }

  Future<void> _disconnect() async {
    await state.connectedDevice?.device.disconnect();
  }

  @override
  Future<void> stop(int motorId) async {
    // Ignore calls for stopping second motor, if the connected toy does not have it.
    if (motorId == 1 &&
        !GetIt.I<CommoditiesStore>().toyHasTwoMotors(
          state.connectedDevice?.bluetoothName,
        )) {
      return;
    }
    // Ignore calls for stopping third motor, if the connected toy does not have it.
    if (motorId == 2 &&
        !GetIt.I<CommoditiesStore>().toyHasThreeMotors(
          state.connectedDevice?.bluetoothName,
        )) {
      return;
    }
    await write(state.connectedDevice!.device, stopMotorCommand(motorId));

    if (motorId == 0) {
      emit(state.copyWith(motor1Int: 0));
    } else if (motorId == 1) {
      emit(state.copyWith(motor2Int: 0));
    } else if (motorId == 2) {
      emit(state.copyWith(motor3Int: 0));
    }
  }

  void log(dynamic scope, dynamic msg) {
    print('Toy($scope): $msg');
  }

  @override
  Future<void> disconnect() async {
    _disconnect();
    emit(ToyState(discoveredDevices: state.discoveredDevices));
  }

  Future<void> _auth(BluetoothDevice device) async {
    await write(device, authParams1Command);
  }

  Future<void> _auth2(BluetoothDevice device, String response) async {
    var code = response.split(':')[1];
    var authCode = code.replaceAll(';', '');
    await write(device, authParams2Command(authCode));
  }

  void _onCommandReceived(String response) {
    if (state.connectedDevice == null) {
      return;
    }
    if (response == 'OK;') {
      emit(state.copyWith(authenticated: true));
    } else if (RegExp(r'^\d+;$').hasMatch(response)) {
      final battery = int.parse(response.replaceAll(';', ''));
      emit(state.copyWith(batteryPercentage: battery));
    } else if (response.startsWith('Light:')) {
      // Possible responses are "Light:0;" (off) and "Light:1;" (on)
      emit(state.copyWith(isLightOn: response.contains('1')));
    } else if (response.contains(':')) {
      _auth2(state.connectedDevice!.device, response);
    }
  }

  void checkEvery2SecondsIfStillConnected() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (state.connectedDevice == null) {
        print('Already disconnected; Cancelling the periodic checker...');
        timer.cancel();
        return;
      }
      if (FlutterBluePlus.connectedDevices.isEmpty) {
        print(
          'No device connected; Disconnecting... & Cancelling the periodic checker...',
        );
        disconnect();
        timer.cancel();
      }
    });
  }

  @override
  String? get connectedDeviceName => state.connectedDevice?.bluetoothName;

  @override
  Stream<bool> disconnectSignal() =>
      stream.map((toyState) => toyState.connectedDevice == null).distinct();

  @override
  String? get displayName => state.connectedDevice?.displayName;

  StreamSubscription<DatabaseEvent>? _commandsStreamSubscription;

  /// Remember to call [unsetRemoteCommander] when you are done using this,
  /// Otherwise [StreamSubscription] will leak.
  void setRemoteCommander(RemoteLoverCommands? commands) {
    if (commands == null) {
      Logger.remoteLover.e('RemoteLoverCommands value is null');
    } else {
      _commandsStreamSubscription = commands.stream.listen((event) {
        event.snapshot.asCommand()?.run(this);
      });
    }
  }

  void unsetRemoteCommander() {
    _commandsStreamSubscription?.cancel();
  }
}

extension Name on ScanResult {
  String get bluetoothName => device.platformName.isNotEmpty
      ? device.platformName
      : advertisementData.advName;

  String get displayName {
    return GetIt.I<CommoditiesStore>().knownToys
            .firstWhereOrNull(
              (toy) =>
                  toy.bluetoothName != null &&
                  toy.bluetoothName!.contains(bluetoothName),
            )
            ?.name ??
        bluetoothName;
  }

  Widget? get toyImage {
    String? controllerPagePicture = GetIt.I<CommoditiesStore>().knownToys
        .firstWhereOrNull((toy) {
          return toy.bluetoothName != null &&
              toy.bluetoothName!.contains(bluetoothName);
        })
        ?.controllerPagePicture;
    if (controllerPagePicture == null) return null;
    return CachedNetworkImage(
      imageUrl: controllerPagePicture,
      filterQuality: FilterQuality.high,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: Assets.images.circle.provider()),
          ),
          child: Image(image: imageProvider),
        );
      },
    );
  }
}
