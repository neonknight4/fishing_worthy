import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Gradi light/dark [ThemeData] sa outdoor tokenima ([AppColors]) i
/// tipografijom: Baloo 2 (display/naslovi) + Manrope (UI/telo).
class AppTheme {
  static ThemeData light() => _base(Brightness.light, AppColors.light);
  static ThemeData dark() => _base(Brightness.dark, AppColors.dark);

  static ThemeData _base(Brightness b, AppColors c) {
    final base = ThemeData(brightness: b, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.green,
        brightness: b,
      ).copyWith(surface: c.surface),
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: c.ink,
        displayColor: c.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      dividerColor: c.line,
      extensions: [c],
    );
  }
}

/// Tipografski helperi vezani za temu. `context.display(...)` = Baloo 2,
/// `context.ui(...)` = Manrope. Boja podrazumevano `ink`.
extension AppText on BuildContext {
  TextStyle display({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.05,
    double letterSpacing = -0.2,
  }) =>
      GoogleFonts.baloo2(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.ink,
        height: height,
        letterSpacing: letterSpacing,
      );

  TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.3,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color ?? c.ink,
        height: height,
        letterSpacing: letterSpacing,
      );
}
