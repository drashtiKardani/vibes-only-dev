import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';

import '../motor_selector/motor_selector_cubit.dart';

class PatternNumberRunner extends StatefulWidget {
  const PatternNumberRunner({super.key});

  @override
  State<PatternNumberRunner> createState() => _PatternNumberRunnerState();
}

class _PatternNumberRunnerState extends State<PatternNumberRunner> {
  final patternNumberController = TextEditingController();
  Widget? error;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorSelectorCubit, ToyMotor>(builder: (context, selectedMotor) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: patternNumberController,
                decoration: InputDecoration(
                    hintText: '1-18', hintStyle: const TextStyle(color: AppColors.grey50), error: error),
              ),
            ),
            const Gap(20),
            FilledButton(
                onPressed: () => runPatternByNumber(selectedMotor, int.tryParse(patternNumberController.text)),
                child: const Text('Run')),
          ],
        ),
      );
    });
  }

  void runPatternByNumber(ToyMotor motor, int? patternNumber) {
    if (patternNumber == null || patternNumber < 1 || patternNumber > 18) {
      setState(
          () => error = const Text('Please enter a number from 1 through 18', style: TextStyle(color: Colors.red)));
      return;
    }

    setState(() => error = null);
    BlocProvider.of<ToyCubit>(context).pattern(motor.motorNumber, patternNumber);
  }
}
