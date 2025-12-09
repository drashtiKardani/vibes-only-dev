import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class RoundedRectGradientButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const RoundedRectGradientButton({
    super.key,
    this.onTap,
    required this.child,
    this.width = double.infinity,
    this.height = 55,
    this.borderRadius = 100.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  const RoundedRectGradientButton.circular({
    super.key,
    required this.onTap,
    required this.child,
    this.width = 59,
    this.height = 59,
    this.borderRadius = 59 / 2,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: backgroundColor == null
                ? LinearGradient(
                    colors: onTap != null
                        ? [AppColors.vibesPinkLighter, AppColors.vibesPink, AppColors.vibesPinkDarker]
                        : [AppColors.grey90, AppColors.grey8A, AppColors.grey75],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: backgroundColor,
          ),
          child: Center(
            child: applyForegroundColor(child, foregroundColor),
          ),
        ),
      ),
    );
  }

  Widget applyForegroundColor(Widget child, Color? color) {
    if (child is Text) {
      return Text(
        child.data!,
        style: child.style?.copyWith(color: color) ?? TextStyle(color: color),
      );
    } else if (child is Icon) {
      return Icon(
        child.icon,
        color: color ?? child.color,
        size: child.size,
      );
    } else {
      // You can handle more widget types here if needed
      return child; // Return the child unchanged if it doesn't support foregroundColor
    }
  }
}
