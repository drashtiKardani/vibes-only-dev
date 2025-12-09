import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/controllers/sinusoid_controller.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/vibes_tab/magic_wand/chart.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class MagicWandScreen extends StatefulWidget {
  const MagicWandScreen({super.key});

  @override
  State<MagicWandScreen> createState() => _MagicWandScreenState();
}

class _MagicWandScreenState extends State<MagicWandScreen> {
  late final StreamSubscription<UserAccelerometerEvent> accSub;

  final MotorSelectorCubit motorSelectorCubit = MotorSelectorCubit();
  late final SinusoidController controller;

  String? get connectedDeviceName {
    return BlocProvider.of<ToyCubit>(context)
        .state
        .connectedDevice
        ?.bluetoothName;
  }

  @override
  void initState() {
    super.initState();

    controller = SinusoidController(
      toyCubit: BlocProvider.of(context),
      motorSelectorCubit: motorSelectorCubit,
    );

    accSub = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        final acc = math.sqrt(
            math.pow(event.x, 2) + math.pow(event.y, 2) + math.pow(event.z, 2));

        double normalizedAmplitude = (acc / 5).clamp(0, 1);
        controller.setNormalizedPower(normalizedAmplitude);
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    accSub.cancel();
    controller.turnOff();
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
                        'Magic Wind',
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
                  Observer(
                    builder: (context) {
                      return Center(
                        child: Column(
                          spacing: 20,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (!controller.isOn) {
                                  controller.turnOn();
                                } else {
                                  controller.turnOff();
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: Durations.medium2,
                                child: controller.isOn
                                    ? Assets.svg.mobileVibrationFill.svg(
                                        height: 120,
                                        key: ValueKey('true'),
                                      )
                                    : Assets.svg.mobile.svg(
                                        height: 120,
                                        key: ValueKey('false'),
                                      ),
                              ),
                            ),
                            Text(
                              controller.isOn
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
                      );
                    },
                  ),
                  Observer(
                    builder: (context) {
                      return IntensityChart(
                        motor1Intensities:
                            controller.motor1Intensities.toList(),
                        motor2Intensities:
                            controller.motor2Intensities.toList(),
                        motor3Intensities:
                            controller.motor3Intensities.toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
