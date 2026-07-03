import 'package:flutter/material.dart';

class LedgePalette {
  const LedgePalette._();

  static const shaleInk = Color(0xFF111817);
  static const pineShadow = Color(0xFF1D352C);
  static const mossTrace = Color(0xFF42725B);
  static const ropeBlue = Color(0xFF3D6B8C);
  static const copperSun = Color(0xFFC06A3D);
  static const lichenGold = Color(0xFFD0B15E);
  static const chalkWhite = Color(0xFFF8F7F2);
  static const fogLine = Color(0xFFE4E1D7);
  static const graniteGrey = Color(0xFF69706C);
  static const cleanPanel = Color(0xFFFFFFFF);
}

class CragFonts {
  const CragFonts._();

  static const sans = 'ClimbySans';
  static const display = 'ClimbyDisplay';
  static const digits = 'ClimbyDigits';
}

ThemeData buildCragTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: LedgePalette.mossTrace,
        brightness: Brightness.light,
      ).copyWith(
        primary: LedgePalette.pineShadow,
        secondary: LedgePalette.ropeBlue,
        tertiary: LedgePalette.copperSun,
        surface: LedgePalette.chalkWhite,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: CragFonts.sans,
    scaffoldBackgroundColor: LedgePalette.chalkWhite,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: CragFonts.display,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.04,
      ),
      titleLarge: TextStyle(
        fontFamily: CragFonts.display,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontFamily: CragFonts.sans,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        fontFamily: CragFonts.sans,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.38,
      ),
      labelMedium: TextStyle(
        fontFamily: CragFonts.sans,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
  );
}
