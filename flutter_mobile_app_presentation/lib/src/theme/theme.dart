import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // this constructor prevents instantiation and extension.
  AppColors._();

  static const Color vibesPinkLighter = Color(0xFFDA5974);
  static const Color vibesPink = Color(0xFFFF1281);
  static const Color vibesPinkDarker = Color(0xFF80013F);

  static Color get primary => vibesPink;
  static const Color primary80 = Color(0xFFA84056);
  static const Color primary20 = Color(0xff361C22);

  static const Color primaryAlt1 = Color(0xFF51379C);
  static const Color primaryAlt1Light = Color(0xFF8767E3);

  static const Color primaryAlt2 = Color(0x669B1EA6);
  static const Color primaryAlt2Light = Color(0xFF9B1EA6);

  static const Color primaryAlt3 = Color(0x66BF127A);
  static const Color primaryAlt3Light = Color(0xFFBF127A);

  static const Color scaffoldBackgroundColor = Color(0xFF020202);

  static const Color greyE0 = Color(0xFFe0e0e0);
  static const Color greyD2 = Color(0xFFd2d2d2);
  static const Color greyAC = Color(0xFFacacac);
  static const Color grey9E = Color(0xFF9e9e9e);
  static const Color grey95 = Color(0xFF959595);
  static const Color grey90 = Color(0xFF909090);
  static const Color grey8A = Color(0xFF8A8A8A);
  static const Color grey75 = Color(0xFF757575);
  static const Color grey65 = Color(0xFF656565);
  static const Color grey60 = Color(0xFF606060);
  static const Color grey50 = Color(0xFF505050);
  static const Color grey4A = Color(0xFF4A4A4A);
  static const Color grey45 = Color(0xFF454545);
  static const Color grey40 = Color(0xFF404040);
  static const Color grey3A = Color(0xFF3A3A3A);
  static const Color grey34 = Color(0xFF343434);
  static const Color grey37 = Color(0xFF373737);
  static const Color grey30 = Color(0xFF303030);
  static const Color grey2F = Color(0xFF2F2F2F);
  static const Color grey2E = Color(0xFF2E2E2E);
  static const Color grey2C = Color(0xFF2C2C2C);
  static const Color grey2B = Color(0xFF2B2B2B);
  static const Color grey2A = Color(0xFF2A2A2A);
  static const Color grey25 = Color(0xFF252525);
  static const Color grey20 = Color(0xFF202020);
  static const Color grey1C = Color(0xFF1C1C1C);
  static const Color grey19 = Color(0xFF191919);
  static const Color grey11 = Color(0xFF111111);
  static const Color grey10 = Color(0xFF101010);
}

const Color _primaryColor = AppColors.vibesPink;
MaterialColor _primarySwatch =
    _GeneratedMaterialColor.from(AppColors.vibesPink);

const MaterialColor _accent = MaterialColor(_accentInt, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_accentInt),
  400: Color(0xFFFFB9C7),
  700: Color(0xFFFFA0B2),
});
const int _accentInt = 0xFFFFECF0;

extension VibesOnlyCustomStyle on TextTheme {
  TextTheme applyCustomStyle() {
    return copyWith(
      displaySmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 24,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w300,
        fontSize: 15,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w300,
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      labelMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w300,
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      labelSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    );
  }
}

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    package: 'flutter_mobile_app_presentation',
    primaryColor: _primaryColor,
    primaryColorDark: AppColors.vibesPinkDarker,
    splashColor: Colors.white.withValues(alpha: 0.01),
    highlightColor: Colors.white.withValues(alpha: 0.01),
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    bottomNavigationBarTheme: _lightBottomNavTheme(),
    dividerColor: const Color(0xffE0E0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.grey20),
    textTheme: GoogleFonts.poppinsTextTheme().applyCustomStyle(),
    outlinedButtonTheme: _buildOutlineButtonThemeData(primary: Colors.black),
    elevatedButtonTheme: _buildElevatedButtonThemeData(),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateColor.resolveWith((states) => Colors.black),
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        } else {
          return Colors.transparent;
        }
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) {
          return const BorderSide(color: Colors.white, width: 1.5);
        },
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: _primarySwatch)
        .copyWith(secondary: _accent, surface: Colors.white),
  );
}

ThemeData darkTheme() {
  return lightTheme().copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        color: AppColors.grey75,
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    ),
    bottomNavigationBarTheme: _darkBottomNavTheme(),
    dividerColor: const Color(0xff3A3A3A),
    elevatedButtonTheme: _buildElevatedButtonThemeData(),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        disabledForegroundColor: AppColors.grey50,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme()
        .apply(bodyColor: Colors.white, displayColor: Colors.white)
        .applyCustomStyle(),
    outlinedButtonTheme: _buildOutlineButtonThemeData(primary: Colors.white),
    colorScheme: lightTheme().colorScheme.copyWith(
          surface: AppColors.scaffoldBackgroundColor,
          onSurface: Colors.white,
          primaryContainer: AppColors.grey20,
        ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.vibesPink,
      contentTextStyle: GoogleFonts.poppins(color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.grey20), tabBarTheme: TabBarThemeData(indicatorColor: Colors.white),
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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarBrightness: Brightness.light));
  }
}

// see: https://medium.com/@filipvk/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
class _GeneratedMaterialColor extends MaterialColor {
  _GeneratedMaterialColor.from(Color color)
      : super(color.toARGB32(), _createMaterialColorSwatch(color));

  static Map<int, Color> _createMaterialColorSwatch(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.r.toInt(), g = color.g.toInt(), b = color.b.toInt();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return swatch;
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
    backgroundColor: AppColors.grey25,
    unselectedItemColor: AppColors.grey65,
    selectedItemColor: Colors.white,
  );
}

OutlinedButtonThemeData _buildOutlineButtonThemeData({required Color primary}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(),
      side: BorderSide(color: primary.withValues(alpha: 0.2)),
    ),
  );
}

ElevatedButtonThemeData _buildElevatedButtonThemeData() {
  return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    foregroundColor: Colors.black,
    backgroundColor: Colors.white,
    elevation: 0,
    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
  ));
}
