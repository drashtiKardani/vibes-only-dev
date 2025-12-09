import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/speed/speed_slider.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toolbar.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_picture.dart';
import 'package:vibes_only/src/feature/vibes_tab/four_way_controller/controller_ui.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class FourWayController extends StatefulWidget {
  const FourWayController({super.key});

  @override
  State<FourWayController> createState() => _FourWayControllerState();
}

class _FourWayControllerState extends State<FourWayController> {
  late final ToyCubit toy;
  final MotorSelectorCubit motorSelectorCubit = MotorSelectorCubit();

  @override
  void initState() {
    super.initState();
    toy = BlocProvider.of<ToyCubit>(context);
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
      body: BlocProvider(
        create: (_) => motorSelectorCubit,
        child: Stack(
          children: [
            Positioned.fill(
              child: Assets.images.background.image(
                filterQuality: FilterQuality.high,
                package: 'flutter_mobile_app_presentation',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: context.viewPadding.top + kToolbarHeight + 10,
                bottom: 10,
              ),
              child: Column(
                spacing: 30,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ToyPicture(toy: toy),
                      SizedBox(height: 30),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      onToySwitchClicked: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: MotorSelector(
                      userCustomTabSelectorUI: true,
                      toyAsCommodity: GetIt.I<CommoditiesStore>()
                          .toyWithName(toy.connectedDeviceName),
                    ),
                  ),
                  const FourWayControllerUI(),
                  Padding(
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
