import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class VibesElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Size? size;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;

  const VibesElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        elevation: 0,
        fixedSize: size ?? Size(context.mediaQuery.size.width, 48),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
