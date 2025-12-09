import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'hex.dart';

mixin ToyCommands {
  final _encrypter =
      Encrypter(AES(Key.fromUtf8('jdk#ekl%y8aloiei'), mode: AESMode.ecb));
  final _iv = IV.fromLength(16);

  String get batteryCommand => encodeCommand('Battery;');

  String get getLightCommand => encodeCommand('GetLight;');

  String get lightOffCommand => encodeCommand('Light:off;');

  String get lightOnCommand => encodeCommand('Light:on;');

  String get powerOffCommand => encodeCommand('PowerOff;');

  String get authKey => 'Auth:';

  String get random => 'ABCD1234';

  String get authParams1Command => encodeCommand('$authKey$random;');

  String stopMotorCommand(int motorId) => encodeCommand('Stop$motorId;');

  String authParams2Command(String authCode) {
    List<int> bytes = utf8.encode(authCode);
    String hash = sha256.convert(bytes).toString();
    return encodeCommand('$authKey${hash.substring(0, 4)};');
  }

  /// Main Motor Intensity, Val: 00~99
  /// Sub Motor Intensity, Val: 00~99
  String motorIntensityCommand(int mainMotorIntensity, int subMotorIntensity) {
    var main = mainMotorIntensity.toString().padLeft(2, '0');
    var sub = subMotorIntensity.toString().padLeft(2, '0');
    return encodeCommand("MtInt:$main$sub;");
  }

  /// Set Multi Motor duty for devices with 3 motors
  /// - [mainMotorIntensity] Main motor intensity (00-99)
  /// - [subMotorIntensity] Second motor intensity (00-99)
  /// - [thirdMotorIntensity] Third motor intensity (00-99)
  /// Example command: MM:990000;
  String multiMotorIntensityCommand(
    int mainMotorIntensity,
    int subMotorIntensity,
    int thirdMotorIntensity,
  ) {
    var main = mainMotorIntensity.toString().padLeft(2, '0');
    var sub = subMotorIntensity.toString().padLeft(2, '0');
    var third = thirdMotorIntensity.toString().padLeft(2, '0');
    return encodeCommand("MM:$main$sub$third;");
  }

  /// motorID 0: Main Motor; 1: Sub Motor; 2: Third Motor
  /// PrePattern Pre-Pattern，value：1~9
  /// MotorPrePattern; eg. (Prest0:9;)
  String patternCommand(int motorId, int prePattern) {
    return encodeCommand("Prest$motorId:$prePattern;");
  }

  /// Set the global intensity range and ratio for a toy.
  /// - [motorId] 0~3
  /// - [intensityScaleRation] 0~99. Use this to set intensity of pattern.
  /// Example command: MRat0:0990080;
  String motorIntensityRangeAndRatioCommand(
      int motorId, int intensityScaleRatio) {
    assert(motorId >= 0 && motorId <= 3);
    assert(intensityScaleRatio >= 0 && intensityScaleRatio <= 99);
    const connectionWay = 0; // 0:AppControl ; 1:HardwareButton
    const upperLimit = '99';
    const lowerLimit = '00';
    final ratio = intensityScaleRatio.toString().padLeft(2, '0');
    return encodeCommand(
        'MRat$motorId:$connectionWay$upperLimit$lowerLimit$ratio;');
  }

  String get securityTypeAuth => 'securityTypeAuth';

  Guid get serviceUUID => Guid("53300011-0050-4BD4-BBE5-A6920E4C5663");

  //
  Guid get characteristicWrite => Guid("53300012-0050-4BD4-BBE5-A6920E4C5663");

  //
  Guid get characteristicNotify => Guid("53300013-0050-4BD4-BBE5-A6920E4C5663");

  String encodeCommand(String command) {
    final encrypted = _encrypter.encrypt(command, iv: _iv);
    return HEX.encode(encrypted.bytes);
  }

  String decodeCommand(String command) {
    final encrypted =
        _encrypter.decrypt(Encrypted.fromBase16(command), iv: _iv);
    return encrypted;
  }
}
