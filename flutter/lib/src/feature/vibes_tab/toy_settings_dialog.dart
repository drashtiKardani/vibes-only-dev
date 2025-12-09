import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toolbar.dart';
import 'package:vibes_only/src/feature/toy/toy_state_extension.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

void openToySettingsDialog(BuildContext context) {
  showBlurredBackgroundBottomSheet(
    context: context,
    builder: (context) {
      return BlocBuilder<ToyCubit, ToyState>(
        builder: (c, state) {
          return Column(
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.circle.provider(),
                  ),
                ),
                child: state.toyImage(height: 80, width: 80),
              ),
              Gap(20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ToyBatteryPercentage(percentage: state.batteryPercentage),
                    Row(
                      spacing: 14,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LightOnOff(
                          isLightOn: state.isLightOn,
                          onToggle: () {
                            BlocProvider.of<ToyCubit>(context).switchLight();
                          },
                        ),
                        PowerOff(
                          toy: BlocProvider.of<ToyCubit>(context),
                          onToySwitchClicked: () => context.pop(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Gap(40),
              Row(
                spacing: 14,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                          fixedSize: Size(context.mediaQuery.size.width, 48)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: VibesElevatedButton(
                      onPressed: () {
                        BlocProvider.of<ToyCubit>(context).disconnect();
                        context.pop();
                      },
                      text: 'Disconnect',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
