import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';

void showBlurDialog(BuildContext context, String title, String text, {CrudCubit? cubit}) {
  showGeneralDialog(
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black38,
    useRootNavigator: false,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim1, anim2) => AlertDialog(
      title: Text(title),
      content: cubit == null
          ? Text(text)
          : BlocBuilder<CrudCubit, CrudState>(
              bloc: cubit,
              builder: (context, state) {
                return FadeTransition(
                  opacity: anim1,
                  child: SizedBox(
                    width: 250,
                    height: 100,
                    child: Column(
                      children: [
                        state.maybeWhen(
                          onProgress: (progress) => Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '$progress/100',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              LinearProgressIndicator(
                                value: progress.toDouble() / 100,
                              ),
                            ],
                          ),
                          orElse: (crudState) => Container(),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(text),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: max(0.001, 4 * anim1.value),
          sigmaY: max(0.001, 4 * anim1.value),
        ),
        child: child),
    context: context,
  );
}
