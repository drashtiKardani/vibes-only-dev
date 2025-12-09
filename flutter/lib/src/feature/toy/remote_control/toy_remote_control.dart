import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/remote_toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/freestyle_mode/controller.dart';
import 'package:vibes_only/src/feature/toy/remote_control/freestyle_mode/freestyle_mode_ui.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/pattern_number_mode/pattern_number_runner.dart';
import 'package:vibes_only/src/feature/toy/remote_control/speed/speed_slider.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toolbar.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_picture.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/feature/vibes_tab/custom_selector.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class ToyRemoteControl extends StatefulWidget {
  /// With this we can change the execution target of commands: E.g. the device at hand, or a remote device.
  /// If user not set this, the default is the local execution target.
  final ToyCubit? commandExecutionTarget;

  const ToyRemoteControl({super.key, this.commandExecutionTarget});

  @override
  State<ToyRemoteControl> createState() => _ToyRemoteControlState();
}

enum Mode {
  manual, // Control toy using intensity wheel and pattern selectors
  freeStyle, // Control toy using a touch pad
  patternNumber, // Used only in STAGING app for testing purposes
}

class _ToyRemoteControlState extends State<ToyRemoteControl> {
  Mode selectedMode = Mode.manual;

  final MotorSelectorCubit motorSelectorCubit = MotorSelectorCubit();

  int get selectedMotor => motorSelectorCubit.state.motorNumber;

  late final ToyCubit toy;
  late final Commodity? toyAsCommodity;

  late final StreamSubscription disconnectStreamSubscription;

  @override
  void initState() {
    super.initState();
    toy = widget.commandExecutionTarget ?? BlocProvider.of<ToyCubit>(context);
    toyAsCommodity =
        GetIt.I<CommoditiesStore>().toyWithName(toy.connectedDeviceName);

    disconnectStreamSubscription =
        toy.disconnectSignal().listen((disconnected) {
      if (disconnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.vibesPink,
            duration: Duration(seconds: 1),
            content: Text(
              'Vibe disconnected',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        Navigator.pop(context);
      }
    });
    BlocProvider.of<ToyCommandService>(context).pause();
  }

  @override
  void dispose() {
    disconnectStreamSubscription.cancel();
    // End connection when controlling partner leaves. If this is local toy control, nothing happens.
    GetIt.I<RemoteLoverService>().endConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        title: toy.displayName ?? 'Vibe disconnected',
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          MultiBlocProvider(
            providers: [
              /// Default ToyCubitImpl is provided at the top level. Only inject when it is remote.
              if (toy is RemoteToyCubit) BlocProvider(create: (_) => toy),
              BlocProvider(create: (_) => motorSelectorCubit),
            ],
            child: Padding(
              padding: EdgeInsets.only(
                top: context.viewPadding.top + kToolbarHeight,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ToyPicture(toy: toy),
                        SizedBox(height: 20),
                        BlocBuilder<ToyCubit, ToyState>(
                          bloc: toy,
                          builder: (context, state) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ToyBatteryPercentage(
                                    percentage: state.batteryPercentage,
                                  ),
                                  Row(
                                    spacing: 14,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LightOnOff(
                                        isLightOn: state.isLightOn,
                                        onToggle: () => toy.switchLight(),
                                      ),
                                      PowerOff(
                                        toy: BlocProvider.of<ToyCubit>(context),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        CustomSelector<Mode>(
                          groupValue: selectedMode,
                          children: const {
                            Mode.manual: 'Manual',
                            Mode.freeStyle: 'Free Style',
                          },
                          onValueChanged: (mode) {
                            setState(() => selectedMode = mode);
                          },
                        ),
                        if (selectedMode == Mode.manual) ...[
                          const SizedBox(height: 10),
                          MotorSelector(
                            toyAsCommodity: toyAsCommodity,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Builder(
                    builder: (context) {
                      return switch (selectedMode) {
                        Mode.manual => Expanded(
                            child: Column(
                              children: [
                                Expanded(child: _patternSelector()),
                                SizedBox(height: 30),
                                Expanded(child: _speedSelector())
                                // const IntensityWheel(),
                              ],
                            ),
                          ),
                        Mode.freeStyle => Expanded(
                            child: FreeStyleMode(
                              controller: FreeStylingController(
                                toyCubit: BlocProvider.of(context),
                                motorSelectorCubit: BlocProvider.of(context),
                              ),
                            ),
                          ),
                        Mode.patternNumber =>
                          const Expanded(child: PatternNumberRunner())
                      };
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void runAutoModeCommand(int patternIndex) {
    if (toy.isConnected()) {
      toy.pattern(selectedMotor, patternIndex);
    } else {
      print('Device is not connected. Command: '
          'Auto mode::change pattern for motor $selectedMotor '
          'to pattern#$patternIndex');
    }
  }

  Widget _patternSelector() {
    const int numRows = 1;
    const int numCols = 3;
    const int patternsInEachPage = numRows * numCols;
    final int numPages = (VibePatters.count() / patternsInEachPage).ceil();
    const double spacing = 16;

    final PageController controller = PageController(viewportFraction: 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Pattern',
            style: context.textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Gap(14),
        Expanded(
          child: PageView(
            controller: controller,
            children: [
              for (int p = 0; p < numPages; p++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double availableWidth = constraints.maxWidth;
                      final double availableHeight = constraints.maxHeight;
                      final double buttonWidth =
                          (availableWidth - (numCols - 1) * spacing) / numCols;
                      final double buttonHeight =
                          (availableHeight - (numRows - 1) * spacing) / numRows;

                      return BlocBuilder<ToyCubit, ToyState>(
                        builder: (context, toyState) {
                          return BlocBuilder<MotorSelectorCubit, ToyMotor>(
                            builder: (context, selectedMotor) {
                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                alignment: WrapAlignment.start,
                                children: [
                                  // first pattern (i=0) is reserved for manual mode.
                                  for (int i = p * patternsInEachPage;
                                      i <
                                          math.min((p + 1) * patternsInEachPage,
                                              VibePatters.count());
                                      i++)
                                    _buildPatternButton(
                                      index: i,
                                      buttonWidth: buttonWidth,
                                      buttonHeight: buttonHeight,
                                      selected: toyState.getPattern(
                                              selectedMotor.motorNumber) ==
                                          i,
                                    )
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                )
            ],
          ),
        ),
        Gap(20),
        Center(
          child: SmoothPageIndicator(
            controller: controller, // PageController
            count: numPages,
            effect: WormEffect(
              activeDotColor: context.colorScheme.onSurface,
              dotColor: context.colorScheme.onSurface.withValues(alpha: 0.5),
              dotHeight: 8,
              dotWidth: 8,
              spacing: 4,
            ), // your preferred effect
          ),
        ),
      ],
    );
  }

  Widget _buildPatternButton({
    required int index,
    required double buttonWidth,
    required double buttonHeight,
    required bool selected,
  }) {
    Color onSurface = context.colorScheme.onSurface;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        final int selectedPattern = index;
        if (selectedPattern == 0) {
          // Switch to manual mode with last knows intensities.
          toy.vibrate(toy.state.motor1Int, toy.state.motor2Int);
        } else {
          runAutoModeCommand(selectedPattern);
        }
      },
      child: AnimatedContainer(
        width: buttonWidth,
        height: buttonHeight,
        duration: Durations.medium2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color: selected ? onSurface : onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: VibePatters.getByIndex(
          index,
          color: selected ? onSurface : onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _speedSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speed',
            style: context.textTheme.headlineMedium
                ?.copyWith(fontSize: 18, letterSpacing: 0.5),
          ),
          Gap(14),
          SpeedSlider(),
        ],
      ),
    );
  }
}
