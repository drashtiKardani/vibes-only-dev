import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

Future<T?> showBlurredBackgroundBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: DateTime.now().millisecondsSinceEpoch.toString(),
    transitionDuration: const Duration(milliseconds: 500),
    barrierDismissible: barrierDismissible,
    pageBuilder: (context, anim1, anim2) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Stack(
          children: [
            GestureDetector(
              onTap: barrierDismissible ? () => Navigator.pop(context) : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: context.colorScheme.surface.withValues(alpha: 0.2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                type: MaterialType.transparency,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14)
                      .copyWith(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 6,
                          width: 70,
                          margin: const EdgeInsets.only(top: 20, bottom: 26),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        builder(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position:
            Tween(begin: const Offset(0, 1), end: Offset.zero).animate(anim1),
        child: child,
      );
    },
  );
}
