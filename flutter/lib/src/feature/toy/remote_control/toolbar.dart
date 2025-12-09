import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/gen/assets.gen.dart';

class ToyRemoteControlToolbar extends AppBar {
  ToyRemoteControlToolbar({
    super.key,
    required ToyCubit toy,
    Function()? onToySwitchClicked,
  }) : super(
         backgroundColor: Colors.transparent,
         foregroundColor: Colors.white,
         elevation: 0.0,
         title: Text(
           toy.displayName ?? 'Vibe disconnected',
           style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
         ),
         centerTitle: true,
         actions: [
           Padding(
             padding: const EdgeInsets.only(right: 16.0),
             child: Switch.adaptive(
               activeThumbColor: AppColors.vibesPink,
               value: toy.isConnected(),
               onChanged: (value) {
                 if (value == false) {
                   onToySwitchClicked?.call();
                   toy.disconnect();
                 }
               },
             ),
           ),
         ],
       );
}

class ToyBatteryPercentage extends StatelessWidget {
  final int percentage;

  const ToyBatteryPercentage({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _batteryImageForBatteryPercentage(
              percentage,
            ).svg(height: 30, width: 30),
            Text(
              '$percentage%',
              style: context.textTheme.headlineMedium?.copyWith(
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  SvgGenImage _batteryImageForBatteryPercentage(int percentage) {
    if (percentage > 90) {
      return Assets.svg.iconBattery100;
    } else if (percentage > 70) {
      return Assets.svg.iconBattery75;
    } else if (percentage > 40) {
      return Assets.svg.iconBattery50;
    } else if (percentage > 10) {
      return Assets.svg.iconBattery25;
    } else {
      return Assets.svg.iconBattery0;
    }
  }
}

class LightOnOff extends StatelessWidget {
  final bool isLightOn;
  final VoidCallback onToggle;

  const LightOnOff({
    super.key,
    required this.isLightOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
      builder: (c, subscription) {
        return CupertinoButton(
          onPressed: () {
            if (subscription.isNotActive()) {
              return showGoPremiumBottomSheet(
                context,
                type: PremiumType.feature,
              );
            }
            onToggle();
          },
          padding: EdgeInsets.zero,
          child: AnimatedSwitcher(
            duration: Durations.medium2,
            child: Assets.svg.light.svg(
              height: 40,
              width: 40,
              key: ValueKey(isLightOn),
              colorFilter: ColorFilter.mode(
                isLightOn
                    ? context.colorScheme.onSurface
                    : context.colorScheme.onSurface.withValues(alpha: 0.4),
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PowerOff extends StatelessWidget {
  final ToyCubit toy;
  final VoidCallback? onToySwitchClicked;

  const PowerOff({super.key, required this.toy, this.onToySwitchClicked});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        onToySwitchClicked?.call();
        toy.powerOff();
        toy.disconnect();
      },
      padding: EdgeInsets.zero,
      child: AnimatedSwitcher(
        duration: Durations.medium2,
        child: Assets.svg.power.svg(
          height: 40,
          width: 40,
          key: ValueKey(toy.isConnected()),
          colorFilter: ColorFilter.mode(
            toy.isConnected()
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurface.withValues(alpha: 0.4),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
