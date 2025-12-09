import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/theme/theme.dart';

Future<T?> showBlurredBackdropDialog<T>({
  required BuildContext context,
  Widget? title,
  List<Widget>? children,
  Color? backgroundColor,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return BlurredBackdropDialog(
        context: context,
        title: title,
        backgroundColor: backgroundColor,
        children: children,
      );
    },
  );
}

class BlurredBackdropDialog extends BackdropFilter {
  BlurredBackdropDialog({
    super.key,
    required BuildContext context,
    Widget? title,
    List<Widget>? children,
    EdgeInsetsGeometry titlePadding =
        const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.only(top: 0, left: 35, right: 35, bottom: 15),
    Color? backgroundColor,
  }) : super(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SimpleDialog(
            insetPadding: const EdgeInsets.all(20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            titlePadding: titlePadding,
            contentPadding: contentPadding,
            surfaceTintColor: Colors.transparent,
            backgroundColor:
                backgroundColor ?? AppColors.grey3A.withValues(alpha: 0.8),
            title: title,
            children: children,
          ),
        );
}
