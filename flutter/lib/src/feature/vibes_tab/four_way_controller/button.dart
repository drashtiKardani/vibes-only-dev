import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vibes_only/src/feature/toy/remote_control/intensity_wheel/copper_decoration.dart';

import 'zones.dart';

class PositionedFourWayButton extends StatefulWidget {
  const PositionedFourWayButton(
      {super.key, required this.constraints, required this.onButtonSnapped, required this.selectedZone});

  final Zones selectedZone;
  final BoxConstraints constraints;
  final void Function(Zones) onButtonSnapped;

  @override
  State createState() => _PositionedFourWayButtonState();
}

class _PositionedFourWayButtonState extends State<PositionedFourWayButton> {
  /// Variable of this [State].
  late Offset _buttonCenter = zoneToOffsetMap[widget.selectedZone]!;

  static const buttonSize = 47.0;

  late final size = widget.constraints.biggest;
  late final center = Offset(size.width / 2, size.height / 2);
  late final quarterWidth = size.width / 4;
  late final quarterHeight = size.height / 4;

  late final offsetToZoneMap = {
    center: Zones.center,
    Offset(quarterWidth, quarterHeight): Zones.topLeft,
    Offset(quarterWidth * 3, quarterHeight): Zones.topRight,
    Offset(quarterWidth, quarterHeight * 3): Zones.bottomLeft,
    Offset(quarterWidth * 3, quarterHeight * 3): Zones.bottomRight,
  };

  Map<Zones, Offset> get zoneToOffsetMap => {for (var e in offsetToZoneMap.entries) e.value: e.key};

  Offset get _buttonTopLeft => _buttonCenter - const Offset(buttonSize / 2, buttonSize / 2);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _buttonTopLeft.dx,
      top: _buttonTopLeft.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _buttonCenter += details.delta;
          });
        },
        onPanEnd: (details) {
          setState(() {
            late Offset closestCenter;
            double minDistance = double.infinity;

            for (var c in offsetToZoneMap.keys) {
              double distance = _buttonCenter.distanceTo(c);
              if (distance < minDistance) {
                closestCenter = c;
                minDistance = distance;
              }
            }

            // Snap to closest center
            _buttonCenter = closestCenter;
            widget.onButtonSnapped(offsetToZoneMap[_buttonCenter]!);
          });
        },
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: const CopperDecoration(),
        ),
      ),
    );
  }
}

extension on Offset {
  double distanceTo(Offset other) {
    return math.sqrt(math.pow(dx - other.dx, 2) + math.pow(dy - other.dy, 2));
  }
}
