import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

const MaterialColor _accent = MaterialColor(_accentInt, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_accentInt),
  400: Color(0xFFFFB9C7),
  700: Color(0xFFFFA0B2),
});
const int _accentInt = 0xFFFFECF0;

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.white,
    bottomNavigationBarTheme: _lightBottomNavTheme(),
    dividerColor: const Color(0xffE0E0E0),
    textTheme: Typography.material2018()
        .black
        .copyWith(
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleSmall: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodySmall: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xff717171),
          ),
        )
        .apply(fontFamily: 'Poppins'),
    outlinedButtonTheme: _lightOutlinedButton(),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primarySwatch)
        .copyWith(surface: Colors.white)
        .copyWith(secondary: _accent),
  );
}

ThemeData darkTheme() {
  return lightTheme().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff1A1A1A),
    bottomNavigationBarTheme: _darkBottomNavTheme(),
    indicatorColor: Colors.white,
    dividerColor: const Color(0xff3A3A3A),
    textTheme: Typography.material2018()
        .white
        .copyWith(
          headlineMedium: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          titleMedium: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleSmall: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodySmall: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Color(0xff717171),
          ),
        )
        .apply(fontFamily: 'Poppins'),
    outlinedButtonTheme: _darkOutlinedButton(),
    colorScheme: lightTheme().colorScheme.copyWith(surface: const Color(0xff1A1A1A)),
  );
}

Future<AdaptiveThemeMode> getThemeMode() async {
  final themeMode = await AdaptiveTheme.getThemeMode();
  return themeMode ?? AdaptiveThemeMode.dark;
}

void changeTheme(BuildContext context, AdaptiveThemeMode mode) {
  switch (mode) {
    case AdaptiveThemeMode.light:
      AdaptiveTheme.of(context).setLight();
      break;
    case AdaptiveThemeMode.dark:
      AdaptiveTheme.of(context).setDark();
      break;
    default:
      AdaptiveTheme.of(context).setLight();
  }
  updateStatusBar(mode);
}

void toggleTheme(BuildContext context) {
  getThemeMode().then((mode) {
    if (mode == AdaptiveThemeMode.light) {
      changeTheme(context, AdaptiveThemeMode.dark);
    } else {
      changeTheme(context, AdaptiveThemeMode.light);
    }
  });
}

void updateStatusBar(AdaptiveThemeMode mode) {
  if (mode == AdaptiveThemeMode.dark) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarBrightness: Brightness.light));
  }
}

BottomNavigationBarThemeData _lightBottomNavTheme() {
  return const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedLabelStyle: TextStyle(
      fontSize: 12,
    ),
  );
}

BottomNavigationBarThemeData _darkBottomNavTheme() {
  return _lightBottomNavTheme().copyWith(
    backgroundColor: const Color(0xff2A2A2A),
    unselectedItemColor: const Color(0xff616161),
    selectedItemColor: Colors.white,
  );
}

OutlinedButtonThemeData _lightOutlinedButton() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      shadowColor: _primaryColor,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      backgroundColor: Colors.transparent,
      side: const BorderSide(width: 1, color: _primaryColor),
    ),
  );
}

OutlinedButtonThemeData _darkOutlinedButton() {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      shadowColor: _primaryColor,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      backgroundColor: Colors.transparent,
      side: const BorderSide(width: 1, color: _primaryColor),
    ),
  );
}
