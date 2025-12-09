import 'package:flutter/material.dart';
import 'package:flutter_panel/generated/fonts.gen.dart';

const _primaryColor = Color(0xffEF4F7F);
const MaterialColor _primarySwatch = MaterialColor(_primaryInt, <int, Color>{
  50: Color(0xFFFDEAF0),
  100: Color(0xFFFACAD9),
  200: Color(0xFFF7A7BF),
  300: Color(0xFFF484A5),
  400: Color(0xFFF16992),
  500: Color(_primaryInt),
  600: Color(0xFFED4877),
  700: Color(0xFFEB3F6C),
  800: Color(0xFFE83662),
  900: Color(0xFFE4264F),
});
const int _primaryInt = 0xFFEF4F7F;

ThemeData lightTheme() {
  return ThemeData(
    fontFamily: FontFamily.poppins,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xfff7f7f7),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      fillColor: Color(0xffdbdbdb),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(180, 45)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: Colors.black,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
      brightness: Brightness.light,
    ).copyWith(surface: Colors.white),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    fontFamily: FontFamily.poppins,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: const Color(0xff1a1a1a),
    cardColor: const Color(0xff333333),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      fillColor: Color(0xff3A3A3A),
      filled: true,
    ),
    disabledColor: const Color(0xff8A8A8A),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(180, 45)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: Colors.white,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        if (states.contains(WidgetState.selected)) {
          return _primaryColor;
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _primarySwatch,
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xff1a1a1a)),
  );
}
