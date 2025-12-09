import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:vibes_only/src/feature/toy/remote_control/motor_selector/motor_selector_cubit.dart';
import 'package:vibes_only/src/feature/toy/toy_visual_elements.dart';
import 'package:vibes_only/src/feature/vibes_tab/four_way_controller/zones.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_studio/choose_pattern_screen.dart';

class FourWayControllerUI extends StatefulWidget {
  const FourWayControllerUI({super.key});

  @override
  State<FourWayControllerUI> createState() => _FourWayControllerUIState();
}

class _FourWayControllerUIState extends State<FourWayControllerUI> {
  Zones _zone = Zones.topLeft;
  final double _boxSize = 120;

  List<Zones> zones = [
    Zones.topLeft,
    Zones.topRight,
    Zones.bottomLeft,
    Zones.bottomRight,
  ];

  /// Mapping of each zone to a [VibePatters] index, for each motor.
  final Map<int, Map<Zones, int>> zonePatternsByMotorId = {
    0: {
      Zones.topLeft: 1,
      Zones.topRight: 2,
      Zones.bottomRight: 3,
      Zones.bottomLeft: 4,
    },
    1: {
      Zones.topLeft: 1,
      Zones.topRight: 2,
      Zones.bottomRight: 3,
      Zones.bottomLeft: 4,
    },
    // TODO: check for final version if it's needed
    2: {
      Zones.topLeft: 1,
      Zones.topRight: 2,
      Zones.bottomRight: 3,
      Zones.bottomLeft: 4,
    },
  };

  late final List<Zones> selectedZoneByMotorId;

  @override
  void initState() {
    super.initState();
    // Initialize with center for each available motor
    selectedZoneByMotorId = List.generate(
      zonePatternsByMotorId.length,
      (_) => Zones.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotorSelectorCubit, ToyMotor>(
      builder: (context, toyMotor) {
        return Column(
          spacing: 14,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pattern',
                      style: context.textTheme.headlineMedium
                          ?.copyWith(fontSize: 18, letterSpacing: 0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push<int?>(
                        MaterialPageRoute(
                          builder: (_) => const ChoosePatternScreen(),
                        ),
                      )
                          .then((patternIndex) {
                        if (patternIndex != null) {
                          if (_zone == selectedZoneByMotorId[toyMotor.index]) {
                            /// Pattern of currently selected zone is changed.
                            BlocProvider.of<ToyCubit>(context)
                                .pattern(toyMotor.index, patternIndex);
                          }
                          setState(() {
                            zonePatternsByMotorId[toyMotor.index]?[_zone] =
                                patternIndex;
                          });
                        }
                      });
                    },
                    child: Text(
                      'Change',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        decorationColor: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _boxSize,
              width: context.mediaQuery.size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  spacing: 14,
                  children: zones.map((e) {
                    return patternSelector(e, toyMotor);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget patternSelector(Zones zone, ToyMotor toyMotor) {
    Color onSurface = context.colorScheme.onSurface;

    // Safety check - if the motor index is out of range, show disabled state
    if (!zonePatternsByMotorId.containsKey(toyMotor.index)) {
      return AnimatedContainer(
        width: _boxSize,
        duration: Durations.medium2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: VibePatters.getByIndex(1),
      );
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _zone = zone;

        if (zone == selectedZoneByMotorId[toyMotor.index]) {
          /// Selected zone is tapped, deselect it.
          setState(() => selectedZoneByMotorId[toyMotor.index] = Zones.center);
          BlocProvider.of<ToyCubit>(context).stop(toyMotor.index);
        } else {
          /// Select new zone and run the pattern.
          setState(() => selectedZoneByMotorId[toyMotor.index] = zone);
          BlocProvider.of<ToyCubit>(context).pattern(
            toyMotor.index,
            zonePatternsByMotorId[toyMotor.index]![zone]!,
          );
        }
      },
      child: AnimatedContainer(
        width: _boxSize,
        duration: Durations.medium2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color: zone == selectedZoneByMotorId[toyMotor.index]
                ? onSurface
                : onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: VibePatters.getByIndex(
          zonePatternsByMotorId[toyMotor.index]?[zone] ?? 1,
          color: zone == selectedZoneByMotorId[toyMotor.index]
              ? onSurface
              : onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
