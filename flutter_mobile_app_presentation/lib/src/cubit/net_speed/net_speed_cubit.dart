import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

class NetSpeedCubit extends Cubit<double> {
  final _dio = Dio();
  late DateTime _startTime;

  final bool dontTestSpeed;

  /// State is the perceived transfer rate in Mbps.
  /// 1Mbps is the initial designated speed.
  NetSpeedCubit({this.dontTestSpeed = false}) : super(1) {
    testSpeed();
  }

  void testSpeed() {
    if (dontTestSpeed) {
      debugPrint(
          'NetSpeedCubit.testSpeed() called but `dontTestSpeed` is set to true. '
          'This is probably a simulation environemt. '
          'Speed is fixed to 1Mbps which means the videos will be loaded with medium quality.');
      return;
    }
    _startTime = DateTime.now();
    _dio.get(
      "https://vibe-app-speed-test.s3.us-east-2.amazonaws.com/video_test.mp4",
      onReceiveProgress: _determineSpeed,
    );
  }

  void _determineSpeed(int received, int total) {
    if (total != -1) {
      var passedTimeFromStart =
          DateTime.now().difference(_startTime).inMicroseconds;
      var speedInMbps = received * 8 / passedTimeFromStart;
      emit(speedInMbps);
    }
  }
}
