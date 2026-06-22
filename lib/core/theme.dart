import 'package:flutter/material.dart';
import 'constants.dart';

class CatWiseTheme {
  CatWiseTheme._();

  static const _fontFamily = 'Mali';

  static const pastelPeach = Color(0xFFFFE4D6);
  static const warmCream = Color(0xFFFFF8F0);
  static const softLavender = Color(0xFFE8DCF0);
  static const mintGreen = Color(0xFFC8E6C9);
  static const skyBlue = Color(0xFFB3D9F2);
  static const dustyRose = Color(0xFFE8C4C4);
  static const warmHoney = Color(0xFFFFD9A0);
  static const cocoa = Color(0xFF8B6F5E);

  static const starGold = Color(0xFFFFC107);
  static const candyPink = Color(0xFFFF80AB);
  static const successGreen = Color(0xFF81C784);
  static const errorPeach = Color(0xFFFFAB91);
  static const hintLavender = Color(0xFFCE93D8);

  static const textPrimary = Color(0xFF5D4037);
  static const textSecondary = Color(0xFF8D6E63);
  static const textOnDark = Color(0xFFFFF8F0);

  static const double plushRadius = 28.0;
  static const double bigRadius = 36.0;
  static const double screenPadding = 24.0;
  static const double iconLarge = 64.0;
  static const double iconMedium = 48.0;
  static const double iconSmall = 32.0;

  static const Duration animQuick = Duration(milliseconds: 200);
  static const Duration animSmooth = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);

  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        fontFamily: _fontFamily,
        brightness: Brightness.light,
        primaryColor: warmHoney,
        scaffoldBackgroundColor: warmCream,
        colorScheme: const ColorScheme.light(
          primary: warmHoney,
          secondary: softLavender,
          surface: warmCream,
          error: errorPeach,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: warmCream,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
        ),
      );

  static List<BoxShadow> get plushShadow => [
        BoxShadow(
          color: textPrimary.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: textPrimary.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softGlow => [
        BoxShadow(
          color: warmHoney.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(plushRadius),
        boxShadow: plushShadow,
      );

  static BoxDecoration watercolorBg() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [warmCream, pastelPeach, softLavender],
        ),
      );

  static TextStyle get displayStyle => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get parentStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );
}
