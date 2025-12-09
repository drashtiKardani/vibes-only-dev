import 'package:flutter/material.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class ElevatedButtonWithLoading extends StatelessWidget {
  const ElevatedButtonWithLoading({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : VibesElevatedButton(
            text: text,
            onPressed: onPressed,
          );
  }
}
