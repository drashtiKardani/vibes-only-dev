import 'package:flutter/material.dart';

class GreyContainer extends Container {
  GreyContainer({
    super.key,
    super.width,
    super.height,
    EdgeInsetsGeometry? padding,
    super.child,
    Color? color,
  }) : super(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        );

  /// Creates a [GreyContainer] without padding or rounded corners.
  GreyContainer.raw({
    super.key,
    super.width,
    super.height,
    Alignment? super.alignment,
    super.child,
    super.color,
  }) : super();
}
