import 'package:flutter/material.dart';

const vibesPink = Color(0xffCE4C68);

ThemeData getAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1A1A1A),
    primaryColor: vibesPink,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: vibesPink,
    ),
    fontFamily: 'Poppins',
    textTheme: Typography()
        .white
        .apply(
          fontFamily: 'Poppins',
          displayColor: Colors.white,
          bodyColor: Colors.white,
        )
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xff8A8A8A),
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w300,
            color: Color(0xff505050),
            letterSpacing: 0.1,
          ),
        ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Color(0xff272727),
    ),
  );
}
