import 'package:flutter/material.dart';

class ColorOverlayContainer extends StatelessWidget {
  const ColorOverlayContainer({super.key, required this.color, this.child});

  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcOver),
      child: child,
    );
  }
}
