import 'weather_data.dart';

enum FishingRating { excellent, good, fair, poor, terrible }

class FishingScore {
  final int score; // 0–100
  final FishingRating rating;
  final List<String> positives;
  final List<String> negatives;
  final DailyForecast forecast;

  const FishingScore({
    required this.score,
    required this.rating,
    required this.positives,
    required this.negatives,
    required this.forecast,
  });

  static FishingScore calculateForHours(List<HourlyWeather> hours) {
    if (hours.isEmpty) {
      return FishingScore(score: 0, rating: FishingRating.terrible, positives: [], negatives: [], forecast: DailyForecast(date: DateTime.now(), hours: []));
    }
    final tempForecast = DailyForecast(date: hours.first.time, hours: hours);
    return calculate(tempForecast);
  }

  static int waterTempScore(double wt) {
    // Bream (deverika): 40%
    final b = wt < 3 ? 0 : wt < 6 ? 15 : wt < 8 ? 35 : wt < 12 ? 55
        : wt < 14 ? 70 : wt <= 22 ? 100 : wt <= 25 ? 70 : wt <= 28 ? 40 : 10;
    // Carp (šaran): 40%
    final c = wt < 4 ? 0 : wt < 8 ? 20 : wt < 12 ? 50 : wt < 16 ? 75
        : wt <= 24 ? 100 : wt <= 27 ? 80 : wt <= 30 ? 40 : 5;
    // Barbel (mrena): 20%
    final r = wt < 5 ? 0 : wt < 8 ? 25 : wt < 12 ? 55 : wt < 14 ? 75
        : wt <= 20 ? 100 : wt <= 22 ? 85 : wt <= 25 ? 60 : 25;
    return (b * 0.4 + c * 0.4 + r * 0.2).round();
  }

  // ── Sub-scores (0–100), shared with TechniqueAdvisor. Combined via weighted
  //    average (not additive) so the score spreads and 100 stays rare. ────────

  /// Weighted average of [subScore, weight] parts. Absent factors are simply
  /// omitted from the list and the remaining weights renormalise.
  static int weightedAverage(List<List<double>> parts) {
    double acc = 0, sw = 0;
    for (final p in parts) {
      acc += p[0].clamp(0, 100) * p[1];
      sw += p[1];
    }
    return sw == 0 ? 0 : (acc / sw).round();
  }

  static double pressureSub(PressureTrendCategory c, double p) {
    final t = switch (c) {
      PressureTrendCategory.preFront => 100.0,
      PressureTrendCategory.stable => 88.0,
      PressureTrendCategory.slowRise => 66.0,
      PressureTrendCategory.rapidRise => 42.0,
      PressureTrendCategory.rapidFall => 28.0,
    };
    final a = (p >= 1013 && p <= 1025)
        ? 100.0
        : p > 1025
            ? 70.0
            : p >= 1000
                ? 68.0
                : 38.0;
    return 0.6 * t + 0.4 * a;
  }

  static double rainSub(double r) =>
      r == 0 ? 84 : r < 2 ? 100 : r < 8 ? 46 : r < 20 ? 22 : 6;

  static double windCalmSub(double w) =>
      w < 8 ? 100 : w < 15 ? 80 : w < 22 ? 56 : w < 30 ? 36 : w < 40 ? 18 : 6;

  static double windChopSub(double w) =>
      (w >= 8 && w <= 20) ? 100 : w < 8 ? 70 : w < 30 ? 48 : w < 40 ? 26 : 10;

  /// 0=N,1=NE,2=E,3=SE,4=S,5=SW,6=W,7=NW. Warm S/SW best, cold E worst.
  static double windDirSub(double deg, double speed) {
    if (speed < 5) return 65;
    final i = ((deg + 22.5) ~/ 45) % 8;
    return switch (i) {
      4 || 5 => 100, // S, SW
      3 || 6 => 76, // SE, W
      0 || 1 => 44, // N, NE
      2 => 28, // E
      _ => 58, // NW
    };
  }

  static double cloudSub(int c, int lo, int hi) {
    if (c >= lo && c <= hi) return 100;
    if (c > hi) return c > 95 ? 60 : 74;
    return c < 10 ? 48 : 70;
  }

  static double turbiditySubWhite(WaterTurbidity t) => switch (t) {
        WaterTurbidity.slightlyTurbid => 100,
        WaterTurbidity.turbid => 80,
        WaterTurbidity.clear => 74,
        WaterTurbidity.veryTurbid => 44,
      };
  static double turbiditySubClear(WaterTurbidity t) => switch (t) {
        WaterTurbidity.clear => 100,
        WaterTurbidity.slightlyTurbid => 74,
        WaterTurbidity.turbid => 48,
        WaterTurbidity.veryTurbid => 28,
      };
  static double turbiditySubPredator(WaterTurbidity t) => switch (t) {
        WaterTurbidity.clear => 100,
        WaterTurbidity.slightlyTurbid => 66,
        WaterTurbidity.turbid => 38,
        WaterTurbidity.veryTurbid => 18,
      };

  static double levelSubWhite(WaterLevelTrend t) => switch (t) {
        WaterLevelTrend.slightRise => 100,
        WaterLevelTrend.stable => 84,
        WaterLevelTrend.slightFall => 60,
        WaterLevelTrend.largeFall => 34,
        WaterLevelTrend.largeRise => 28,
      };
  static double levelSubPredator(WaterLevelTrend t) => switch (t) {
        WaterLevelTrend.stable => 100,
        WaterLevelTrend.slightFall => 86,
        WaterLevelTrend.slightRise => 58,
        WaterLevelTrend.largeFall => 44,
        WaterLevelTrend.largeRise => 26,
      };

  static FishingScore calculate(
    DailyForecast forecast, {
    WaterLevelForecast? waterLevel,
    double? waterTempOverride,
  }) {
    final positives = <String>[];
    final negatives = <String>[];

    final wind = forecast.avgWindSpeed;
    final rain = forecast.totalPrecipitation;
    final pressure = forecast.avgPressure;
    final clouds = forecast.avgCloudCover;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Sub-scores (0–100), combined as a weighted average (no saturation).
    final tempSub = waterTempScore(waterTemp).toDouble();
    final pSub = pressureSub(forecast.pressureTrendCategory, pressure);
    final windSub = 0.7 * windCalmSub(wind) +
        0.3 * windDirSub(forecast.avgWindDirection, wind);
    final turbSub = turbiditySubClear(forecast.turbidity);
    final cSub = cloudSub(clouds, 30, 70);
    final rSub = rainSub(rain);

    final parts = <List<double>>[
      [tempSub, 0.27],
      [pSub, 0.20],
      [windSub, 0.17],
      [turbSub, 0.12],
      [cSub, 0.08],
      [rSub, 0.09],
    ];
    if (waterLevel != null) parts.add([levelSubWhite(waterLevel.trend), 0.07]);

    int score = weightedAverage(parts);

    // ── Reasons ──
    if (tempSub >= 82) {
      positives.add('Temperatura vode idealna (~${waterTemp.toStringAsFixed(0)}°C)');
    } else if (tempSub <= 42) {
      negatives.add('Temperatura vode nepovoljna (~${waterTemp.toStringAsFixed(0)}°C)');
    }
    switch (forecast.pressureTrendCategory) {
      case PressureTrendCategory.preFront:
        positives.add('⚡ Pre-frontalni prozor — ribe nahranjene i aktivne');
      case PressureTrendCategory.stable:
        positives.add('Stabilan pritisak — ribe predvidive');
      case PressureTrendCategory.rapidFall:
        negatives.add('Brzi pad pritiska — ribe se gase');
      case PressureTrendCategory.rapidRise:
        negatives.add('Pritisak naglo raste — ribe se adaptiraju');
      case PressureTrendCategory.slowRise:
        break;
    }
    if (wind < 10) {
      positives.add('Slab vetar (${wind.toStringAsFixed(1)} km/h)');
    } else if (wind >= 30) {
      negatives.add('Jak vetar (${wind.toStringAsFixed(1)} km/h) — otežano bacanje');
    }
    final wdSub = windDirSub(forecast.avgWindDirection, wind);
    if (wdSub >= 100) {
      positives.add('Topao južni vetar — podstiče hranjenje');
    } else if (wdSub <= 28) {
      negatives.add('Hladan istočni vetar — ribe slabije jedu');
    }
    if (rain >= 8) {
      negatives.add('Jaka kiša — loši uslovi (${rain.toStringAsFixed(1)} mm)');
    } else if (rain >= 2) {
      negatives.add('Kiša otežava pecanje (${rain.toStringAsFixed(1)} mm)');
    } else if (rain > 0) {
      positives.add('Lagana kiša — aktivira ribe');
    }
    switch (forecast.turbidity) {
      case WaterTurbidity.clear:
        positives.add('Bistra voda — dobra vidljivost mamca');
      case WaterTurbidity.veryTurbid:
        negatives.add('Jako mutna voda — ribe teže lociraju mamac');
      case WaterTurbidity.turbid:
      case WaterTurbidity.slightlyTurbid:
        break;
    }
    if (clouds >= 30 && clouds <= 70) {
      positives.add('Delimična oblačnost — idealno za pecanje');
    } else if (clouds == 0) {
      negatives.add('Vedro nebo — ribe opreznije');
    }
    if (waterLevel != null) {
      final ls = levelSubWhite(waterLevel.trend);
      if (ls >= 84) {
        positives.add(waterLevel.trendLabel);
      } else if (ls <= 40) {
        negatives.add(waterLevel.trendLabel);
      }
    }

    // Extreme water temp caps — cold/hot kills feeding regardless of weather.
    if (waterTemp < 4) score = score.clamp(0, 18);
    if (waterTemp > 30) score = score.clamp(0, 25);

    score = score.clamp(0, 100);

    FishingRating rating;
    if (score >= 80) {
      rating = FishingRating.excellent;
    } else if (score >= 60) {
      rating = FishingRating.good;
    } else if (score >= 40) {
      rating = FishingRating.fair;
    } else if (score >= 20) {
      rating = FishingRating.poor;
    } else {
      rating = FishingRating.terrible;
    }

    return FishingScore(
      score: score,
      rating: rating,
      positives: positives,
      negatives: negatives,
      forecast: forecast,
    );
  }

  String get ratingLabel {
    switch (rating) {
      case FishingRating.excellent:
        return 'Odlično';
      case FishingRating.good:
        return 'Dobro';
      case FishingRating.fair:
        return 'Osrednje';
      case FishingRating.poor:
        return 'Loše';
      case FishingRating.terrible:
        return 'Veoma loše';
    }
  }
}
