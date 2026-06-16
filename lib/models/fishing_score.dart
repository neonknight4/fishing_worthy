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

  /// Wind-direction modifier. Warm SW/S winds boost feeding; cold E/N winds
  /// suppress it (Angling Times / match consensus). Negligible when calm.
  static int windDirectionAdjustment(double deg, double speed) {
    if (speed < 5) return 0;
    final i = ((deg + 22.5) ~/ 45) % 8; // 0=N,1=NE,2=E,3=SE,4=S,5=SW,6=W,7=NW
    switch (i) {
      case 4: // S (jug)
      case 5: // SW (jugozapad)
        return 6;
      case 3: // SE (jugoistok)
      case 6: // W (zapad)
        return 3;
      case 2: // E (istok)
        return -6;
      case 0: // N (sever)
      case 1: // NE (severoistok)
        return -4;
      default: // NW
        return 0;
    }
  }

  static FishingScore calculate(
    DailyForecast forecast, {
    WaterLevelForecast? waterLevel,
    double? waterTempOverride,
  }) {
    int score = 50;
    final positives = <String>[];
    final negatives = <String>[];

    final wind = forecast.avgWindSpeed;
    final rain = forecast.totalPrecipitation;
    final pressure = forecast.avgPressure;
    final clouds = forecast.avgCloudCover;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Water temperature: species-weighted (bream 40% + carp 40% + barbel 20%)
    final tempScore = waterTempScore(waterTemp);
    final tempAdj = ((tempScore - 50) * 15 / 50).round();
    score += tempAdj;
    if (tempAdj >= 8) {
      positives.add('Temperatura vode idealna (~${waterTemp.toStringAsFixed(0)}°C)');
    } else if (tempAdj <= -8) {
      negatives.add('Temperatura vode nepovoljna (~${waterTemp.toStringAsFixed(0)}°C)');
    }

    // Wind
    if (wind < 10) {
      score += 10;
      positives.add('Slab vetar (${wind.toStringAsFixed(1)} km/h)');
    } else if (wind < 20) {
      score += 3;
    } else if (wind < 30) {
      score -= 12;
      negatives.add('Jak vetar (${wind.toStringAsFixed(1)} km/h)');
    } else if (wind < 40) {
      score -= 25;
      negatives.add('Jak vetar (${wind.toStringAsFixed(1)} km/h) — otežano bacanje');
    } else {
      score -= 35;
      negatives.add('Olujni vetar (${wind.toStringAsFixed(1)} km/h)');
    }

    // Wind direction (warm S/SW good, cold E/N bad)
    final windDirAdj = windDirectionAdjustment(forecast.avgWindDirection, wind);
    score += windDirAdj;
    if (windDirAdj >= 6) {
      positives.add('Topao južni vetar — podstiče hranjenje');
    } else if (windDirAdj <= -6) {
      negatives.add('Hladan istočni vetar — ribe slabije jedu');
    }

    // Rain
    if (rain == 0) {
      score += 5;
    } else if (rain < 2) {
      score += 3;
      positives.add('Lagana kiša — aktivira ribe');
    } else if (rain < 8) {
      score -= 10;
      negatives.add('Kiša otežava pecanje (${rain.toStringAsFixed(1)} mm)');
    } else if (rain < 20) {
      score -= 25;
      negatives.add('Jaka kiša — loši uslovi (${rain.toStringAsFixed(1)} mm)');
    } else {
      score -= 40;
      negatives.add('Pljusak — pecanje nemoguće (${rain.toStringAsFixed(1)} mm)');
    }

    // Pressure: absolute value
    if (pressure >= 1013 && pressure <= 1025) {
      score += 8;
    } else if (pressure > 1025) {
      score += 3;
    } else if (pressure < 1000) {
      score -= 12;
      negatives.add('Nizak pritisak (${pressure.toStringAsFixed(0)} hPa)');
    }

    // Pressure trend — kritičniji od apsolutne vrednosti
    switch (forecast.pressureTrendCategory) {
      case PressureTrendCategory.stable:
        score += 12;
        positives.add('Stabilan pritisak — ribe predvidive');
      case PressureTrendCategory.preFront:
        score += 15;
        positives.add('⚡ Pre-frontalni prozor — ribe nahranjene i aktivne');
      case PressureTrendCategory.slowRise:
        score += 5;
        positives.add('Pritisak raste — uslovi se poboljšavaju');
      case PressureTrendCategory.rapidFall:
        score -= 20;
        negatives.add('Brzi pad pritiska — ribe se gase');
      case PressureTrendCategory.rapidRise:
        score -= 10;
        negatives.add('Pritisak naglo raste — ribe se adaptiraju');
    }

    // Cloud cover: 30–70% ideal (overcast sky = fish less cautious)
    if (clouds >= 30 && clouds <= 70) {
      score += 10;
      positives.add('Delimična oblačnost — idealno za pecanje');
    } else if (clouds > 70 && clouds <= 90) {
      score += 3;
    } else if (clouds == 0) {
      score -= 5;
      negatives.add('Vedro nebo — ribe opreznije');
    }

    // Turbidity
    switch (forecast.turbidity) {
      case WaterTurbidity.veryTurbid:
        score -= 15;
        negatives.add('Jako mutna voda — ribe teže lociraju mamac');
      case WaterTurbidity.turbid:
        score -= 8;
        negatives.add('Zamućena voda — feeder sa mirisom preporučen');
      case WaterTurbidity.slightlyTurbid:
        score += 2;
      case WaterTurbidity.clear:
        score += 8;
        positives.add('Bistra voda — dobra vidljivost mamca');
    }

    // Water level trend
    if (waterLevel != null) {
      score += waterLevel.scoreAdjustment;
      if (waterLevel.scoreAdjustment > 0) {
        positives.add(waterLevel.trendLabel);
      } else if (waterLevel.scoreAdjustment < 0) {
        negatives.add(waterLevel.trendLabel);
      }
    }

    // Cap za ekstremne temperature vode
    if (waterTemp < 4) score = score.clamp(0, 15);
    if (waterTemp > 30) score = score.clamp(0, 20);

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
