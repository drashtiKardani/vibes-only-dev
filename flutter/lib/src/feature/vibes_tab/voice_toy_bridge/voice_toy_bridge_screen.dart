import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/controllers/linear_controller.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/vibes_tab/voice_toy_bridge/sound_rays.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class VoiceToyBridgeScreen extends StatefulWidget {
  const VoiceToyBridgeScreen({super.key});

  @override
  State<VoiceToyBridgeScreen> createState() => _VoiceToyBridgeScreenState();
}

class _VoiceToyBridgeScreenState extends State<VoiceToyBridgeScreen>
    with SingleTickerProviderStateMixin {
  final MotorSelectorCubit motorSelectorCubit = MotorSelectorCubit();
  late final LinearController controller;

  String? get connectedDeviceName =>
      BlocProvider.of<ToyCubit>(context).state.connectedDevice?.bluetoothName;

  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRecorder;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 25),
    upperBound: 2 * pi,
  )..repeat(); // Continuously animate the spinning;

  @override
  void initState() {
    super.initState();
    controller = LinearController(
      toyCubit: BlocProvider.of(context),
      motorSelectorCubit: motorSelectorCubit,
    );

    _audioRecorder = AudioRecorder();

    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 60))
        .listen((amp) {
      double normalizedAmplitude =
          ((amp.current - (-40)) / ((-10) - (-40))).clamp(0, 1);
      controller.setNormalizedPower(normalizedAmplitude);
      setState(() => _amplitude = amp);
    });

    super.initState();
  }

  @override
  void dispose() {
    _stop();
    animationController.dispose();
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
      body: BlocProvider(
        create: (c) => motorSelectorCubit,
        child: Stack(
          children: [
            Positioned.fill(
              child: assets.Assets.images.background.image(
                filterQuality: FilterQuality.high,
                package: 'flutter_mobile_app_presentation',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                top: context.viewPadding.top + kToolbarHeight + 10,
                bottom: context.viewPadding.bottom + 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: 10,
                    children: [
                      Text(
                        'Sound',
                        style: context.textTheme.displaySmall?.copyWith(
                          fontSize: 24,
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (GetIt.I<CommoditiesStore>()
                          .toyHasTwoMotors(connectedDeviceName))
                        MotorSelector(
                          toyAsCommodity: GetIt.I<CommoditiesStore>()
                              .toyWithName(connectedDeviceName),
                        ),
                    ],
                  ),
                  Center(
                    child: Column(
                      spacing: 20,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                painter: SoundRaysPainter(
                                  amplitude: _amplitude,
                                  innerRadius: 70,
                                  phase: animationController.value,
                                ),
                                size: const Size(200, 200),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  if (_recordState == RecordState.stop) {
                                    _start();
                                  } else {
                                    _stop();
                                  }
                                },
                                child: AnimatedSwitcher(
                                  duration: Durations.medium2,
                                  child: controller.isOn
                                      ? Assets.svg.micFill.svg(
                                          height: 120,
                                          key: ValueKey('true'),
                                        )
                                      : Assets.svg.mic.svg(
                                          height: 120,
                                          key: ValueKey('false'),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _recordState != RecordState.stop
                              ? 'Tap button to switch\noff the vibration'
                              : 'Tap button to switch\non the vibration',
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(0)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    controller.turnOn();
    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.pcm16bits;

        if (!await _isEncoderSupported(encoder)) {
          return;
        }

        final devs = await _audioRecorder.listInputDevices();
        debugPrint(devs.toString());

        const config = RecordConfig(encoder: encoder, numChannels: 1);

        // Start listening. Data aren't relevant here, we only need the amplitude.
        final _ = await _audioRecorder.startStream(config);

        // Record to stream
        // await recordStream(_audioRecorder, config);

        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    await _audioRecorder.stop();
    controller.turnOff();
    if (mounted) {
      setState(() => _amplitude = null);
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }
}
