import 'package:flutter/cupertino.dart';

class CopperDecoration extends ShapeDecoration {
  const CopperDecoration()
      : super(
          gradient: const SweepGradient(
            colors: [
              Color(0xFFB77B6E),
              Color(0xFFFFD7CA),
              Color(0xFFB7726E),
              Color(0xFFFFD7CA),
              Color(0xFFB7726E),
              Color(0xFFFFD6C9),
              Color(0xFFB7726E),
              Color(0xFFFFD7CA),
              Color(0xFFB7726E),
            ],
          ),
          shape: const OvalBorder(),
        );
}
