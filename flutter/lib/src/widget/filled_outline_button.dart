import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class FilledOutlineButton extends OutlinedButton {
  FilledOutlineButton({super.key, required super.onPressed, required Widget super.child})
      : super(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              minimumSize: const Size.fromHeight(45),
              backgroundColor: AppColors.vibesPink,
            ));
}
