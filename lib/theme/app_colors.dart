import 'package:flutter/material.dart';

/// Outdoor-dashboard vizuelni tokeni (light + dark), portovani iz redizajn
/// CSS-a (`styles.css`). Čita se preko `Theme.of(context).extension<AppColors>()`
/// ili skraćeno `context.c`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color green, green2, greenInk, greenBright;
  final Color water, water2;
  final Color gold, coral;
  final Color bg, surface, surface2, surface3;
  final Color ink, muted, faint, line;
  final Color onGreen; // tekst na tamnom zelenom hero gradijentu
  final Color onBrand; // tekst na primarnom dugmetu (brend bg)
  final Color good, ok, bad;
  final List<BoxShadow> shadow, shadowLg;

  const AppColors({
    required this.green,
    required this.green2,
    required this.greenInk,
    required this.greenBright,
    required this.water,
    required this.water2,
    required this.gold,
    required this.coral,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.line,
    required this.onGreen,
    required this.onBrand,
    required this.good,
    required this.ok,
    required this.bad,
    required this.shadow,
    required this.shadowLg,
  });

  /// Boja skora: zeleno ≥70, zlatno ≥55, koralno ispod.
  Color score(num v) => v >= 70 ? good : v >= 55 ? ok : bad;

  static const light = AppColors(
    green: Color(0xFF1D5A33),
    green2: Color(0xFF16482A),
    greenInk: Color(0xFF0F3A22),
    greenBright: Color(0xFF2F8B4E),
    water: Color(0xFF1F8A9C),
    water2: Color(0xFF156B7A),
    gold: Color(0xFFE0A02F),
    coral: Color(0xFFD9542B),
    bg: Color(0xFFF1EAD9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFFAF5E9),
    surface3: Color(0xFFF3ECDB),
    ink: Color(0xFF1A241D),
    muted: Color(0xFF6C7269),
    faint: Color(0xFF9AA096),
    line: Color(0xFFE5DDCA),
    onGreen: Color(0xFFF4EFE1),
    onBrand: Color(0xFFF4EFE1),
    good: Color(0xFF2F8B4E),
    ok: Color(0xFFE0A02F),
    bad: Color(0xFFD9542B),
    shadow: [
      BoxShadow(color: Color(0x0D1E3223), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x141E3223), blurRadius: 26, offset: Offset(0, 10)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x14142819), blurRadius: 6, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x24142819), blurRadius: 50, offset: Offset(0, 22)),
    ],
  );

  static const dark = AppColors(
    green: Color(0xFF3FAE63),
    green2: Color(0xFF2F8B4E),
    greenInk: Color(0xFF8FE3A8),
    greenBright: Color(0xFF4FC274),
    water: Color(0xFF3BB6C9),
    water2: Color(0xFF2A93A5),
    gold: Color(0xFFEAB63F),
    coral: Color(0xFFF0704A),
    bg: Color(0xFF0D1712),
    surface: Color(0xFF15241B),
    surface2: Color(0xFF1A2C20),
    surface3: Color(0xFF213629),
    ink: Color(0xFFEAF1E8),
    muted: Color(0xFF9BAE9F),
    faint: Color(0xFF6F8375),
    line: Color(0xFF26382B),
    onGreen: Color(0xFFEAF1E8),
    onBrand: Color(0xFF08130C),
    good: Color(0xFF2F8B4E),
    ok: Color(0xFFE0A02F),
    bad: Color(0xFFD9542B),
    shadow: [
      BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x59000000), blurRadius: 26, offset: Offset(0, 10)),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
      BoxShadow(color: Color(0x80000000), blurRadius: 50, offset: Offset(0, 22)),
    ],
  );

  @override
  AppColors copyWith({
    Color? green,
    Color? green2,
    Color? greenInk,
    Color? greenBright,
    Color? water,
    Color? water2,
    Color? gold,
    Color? coral,
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? ink,
    Color? muted,
    Color? faint,
    Color? line,
    Color? onGreen,
    Color? onBrand,
    Color? good,
    Color? ok,
    Color? bad,
    List<BoxShadow>? shadow,
    List<BoxShadow>? shadowLg,
  }) {
    return AppColors(
      green: green ?? this.green,
      green2: green2 ?? this.green2,
      greenInk: greenInk ?? this.greenInk,
      greenBright: greenBright ?? this.greenBright,
      water: water ?? this.water,
      water2: water2 ?? this.water2,
      gold: gold ?? this.gold,
      coral: coral ?? this.coral,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      line: line ?? this.line,
      onGreen: onGreen ?? this.onGreen,
      onBrand: onBrand ?? this.onBrand,
      good: good ?? this.good,
      ok: ok ?? this.ok,
      bad: bad ?? this.bad,
      shadow: shadow ?? this.shadow,
      shadowLg: shadowLg ?? this.shadowLg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      green: Color.lerp(green, other.green, t)!,
      green2: Color.lerp(green2, other.green2, t)!,
      greenInk: Color.lerp(greenInk, other.greenInk, t)!,
      greenBright: Color.lerp(greenBright, other.greenBright, t)!,
      water: Color.lerp(water, other.water, t)!,
      water2: Color.lerp(water2, other.water2, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      line: Color.lerp(line, other.line, t)!,
      onGreen: Color.lerp(onGreen, other.onGreen, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      good: Color.lerp(good, other.good, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      shadow: t < 0.5 ? shadow : other.shadow,
      shadowLg: t < 0.5 ? shadowLg : other.shadowLg,
    );
  }
}

/// Radijusi (px) — rS/r/rL/rXl iz dizajn sistema.
class AppRadius {
  static const double s = 12, m = 18, l = 26, xl = 32;
}

/// Skraćeni pristup tokenima: `context.c.green`.
extension AppColorsX on BuildContext {
  AppColors get c => Theme.of(this).extension<AppColors>()!;
}
