import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/vibes_tab/custom_selector.dart';

class MotorSelector extends StatelessWidget {
  const MotorSelector({
    super.key,
    required this.toyAsCommodity,
    this.userCustomTabSelectorUI = false,
  });

  final Commodity? toyAsCommodity;
  final bool userCustomTabSelectorUI;

  @override
  Widget build(BuildContext context) {
    final bool hasTwoMotors = GetIt.I<CommoditiesStore>()
        .toyHasTwoMotors(toyAsCommodity?.bluetoothName);
    final bool hasThreeMotors = GetIt.I<CommoditiesStore>()
        .toyHasThreeMotors(toyAsCommodity?.bluetoothName);

    // Don't show anything for single-motor toys
    if (!hasTwoMotors && !hasThreeMotors) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<MotorSelectorCubit, ToyMotor>(
        builder: (context, selectedMotor) {
      final Map<ToyMotor, String> children = {
        ToyMotor.mainMotor: toyAsCommodity?.motorName1 ?? 'Vibrator',
        // For three-motor toys, add both subMotor and thirdMotor
        if (hasThreeMotors) ...{
          ToyMotor.subMotor: toyAsCommodity?.motorName2 ?? 'Suction',
          ToyMotor.thirdMotor: toyAsCommodity?.motorName3 ?? 'Motor 3',

          // For two-motor toys, only add subMotor
        } else if (hasTwoMotors) ...{
          ToyMotor.subMotor: toyAsCommodity?.motorName2 ?? 'Suction',
        }
      };

      if (userCustomTabSelectorUI) {
        return CustomSelector<ToyMotor>(
          groupValue: selectedMotor,
          children: children,
          onValueChanged: (value) {
            if (value != selectedMotor) {
              BlocProvider.of<MotorSelectorCubit>(context).switchMotor(value);
            }
          },
        );
      }

      return CustomRadioSelector<ToyMotor>(
        groupValue: selectedMotor,
        children: children,
        onValueChanged: (value) {
          if (value != selectedMotor) {
            BlocProvider.of<MotorSelectorCubit>(context).switchMotor(value);
          }
        },
      );
    });
  }
}
