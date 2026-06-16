class SolunarWindow {
  final DateTime start;
  final DateTime end;
  final bool isMajor;

  const SolunarWindow({required this.start, required this.end, required this.isMajor});
}

class MoonCalc {
  // Returns 0.0 (new moon) → 1.0 (back to new moon)
  static double phase(DateTime date) {
    final jd = _toJulian(date);
    const knownNewMoon = 2451550.26; // Jan 6, 2000 18:14 UTC
    const synodicMonth = 29.53058867;
    return ((jd - knownNewMoon) % synodicMonth) / synodicMonth;
  }

  static String phaseEmoji(double phase) {
    if (phase < 0.0625) return '🌑';
    if (phase < 0.1875) return '🌒';
    if (phase < 0.3125) return '🌓';
    if (phase < 0.4375) return '🌔';
    if (phase < 0.5625) return '🌕';
    if (phase < 0.6875) return '🌖';
    if (phase < 0.8125) return '🌗';
    if (phase < 0.9375) return '🌘';
    return '🌑';
  }

  static String phaseName(double phase) {
    if (phase < 0.05 || phase > 0.95) return 'Mlad mesec';
    if (phase < 0.20) return 'Rasteći srp';
    if (phase < 0.30) return 'Prva četvrt';
    if (phase < 0.45) return 'Rasteći mesec';
    if (phase < 0.55) return 'Pun mesec';
    if (phase < 0.70) return 'Opadajući mesec';
    if (phase < 0.80) return 'Poslednja četvrt';
    return 'Opadajući srp';
  }

  // Solunar windows for the day.
  // Major: upper transit (moon overhead) and lower transit (underfoot) ± 1h
  // Minor: approximate moonrise and moonset ± 45min
  //
  // Approximation: at new moon the moon transits at solar noon (12:00 local),
  // advancing by ~50min/day → transit_hour ≈ 12 + phase*24 (mod 24)
  static List<SolunarWindow> windows(DateTime date, double lon) {
    final p = phase(date);
    // Upper transit in local solar time (close enough to clock time for Serbia ±~20min)
    final transitH = (12.0 + p * 24.0) % 24.0;
    final day = DateTime(date.year, date.month, date.day);

    DateTime atH(double h) {
      final nh = ((h % 24) + 24) % 24;
      return day.add(Duration(seconds: (nh * 3600).round()));
    }

    return [
      SolunarWindow(start: atH(transitH - 1), end: atH(transitH + 1), isMajor: true),
      SolunarWindow(start: atH(transitH + 11), end: atH(transitH + 13), isMajor: true),
      SolunarWindow(start: atH(transitH + 5.25), end: atH(transitH + 6.75), isMajor: false),
      SolunarWindow(start: atH(transitH - 6.75), end: atH(transitH - 5.25), isMajor: false),
    ];
  }

  static double _toJulian(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day, 12);
    return d.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  }
}
