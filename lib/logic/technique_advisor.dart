import '../models/fishing_score.dart' show FishingScore, FishingRating;
import '../models/technique_score.dart';
import '../models/weather_data.dart';

class TechniqueAdvisor {
  static List<TechniqueScore> advise(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    DateTime date,
  ) {
    final month = date.month;
    final scores = [
      _scoreFeeder(forecast, waterLevel, waterBody, month),
      _scoreSpinning(forecast, waterLevel, waterBody, month),
      _scoreFloat(forecast, waterLevel, waterBody, month),
    ];
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  static List<SeasonalFish> seasonalFish(DateTime date) {
    return _fishForMonth(date.month);
  }

  /// Score a single technique for a forecast (used by per-interval filter).
  static int scoreFor(
    TechniqueType type,
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month, {
    double? waterTempOverride,
  }) {
    switch (type) {
      case TechniqueType.feeder:
        return _scoreFeeder(forecast, waterLevel, waterBody, month,
                waterTempOverride: waterTempOverride)
            .score;
      case TechniqueType.spinning:
        return _scoreSpinning(forecast, waterLevel, waterBody, month).score;
      case TechniqueType.float:
        return _scoreFloat(forecast, waterLevel, waterBody, month).score;
    }
  }

  static TechniqueScore _scoreFeeder(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month, {
    double? waterTempOverride,
  }) {
    int score = 50;
    final wind = forecast.avgWindSpeed;
    final rain = forecast.totalPrecipitation;
    final pressure = forecast.avgPressure;
    final clouds = forecast.avgCloudCover;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Species-weighted water temp: bream+carp+barbel (feeder target mix)
    final tempScore = FishingScore.waterTempScore(waterTemp);
    score += ((tempScore - 50) * 15 / 50).round();
    if (waterTemp < 4) score = score.clamp(0, 15);
    if (waterTemp > 30) score = score.clamp(0, 20);

    // Feeder zahteva mirno za kontrolu štapa
    if (wind < 10) {
      score += 10;
    } else if (wind < 20) {
      score += 2;
    } else if (wind < 30) {
      score -= 12;
    } else if (wind < 40) {
      score -= 25;
    } else {
      score -= 35;
    }

    score += FishingScore.windDirectionAdjustment(forecast.avgWindDirection, wind);

    // Lagana kiša kiseonik u vodi; jaka muti
    if (rain < 0.5) {
      score += 3;
    } else if (rain < 2) {
      score += 8;
    } else if (rain < 8) {
      score -= 10;
    } else if (rain < 20) {
      score -= 25;
    } else {
      score -= 40;
    }

    if (pressure >= 1013 && pressure <= 1025) {
      score += 10;
    } else if (pressure > 1025) {
      score += 3;
    } else if (pressure < 1000) {
      score -= 12;
    }

    if (clouds >= 40 && clouds <= 80) {
      score += 10;
    } else if (clouds > 80) {
      score += 3;
    } else if (clouds < 20) {
      score -= 3;
    }

    if (waterLevel != null) {
      switch (waterLevel.trend) {
        case WaterLevelTrend.slightRise:
          score += 15; // šaran aktivan na porastu
        case WaterLevelTrend.stable:
          score += 5;
        case WaterLevelTrend.slightFall:
          score -= 5;
        case WaterLevelTrend.largeRise:
          score -= 20; // mutna voda
        case WaterLevelTrend.largeFall:
          score -= 15;
      }
    }

    // Feeder radi dobro na mutnoj vodi — mirisni mamac
    switch (forecast.turbidity) {
      case WaterTurbidity.veryTurbid:
        score -= 5;
      case WaterTurbidity.turbid:
        score += 5;
      case WaterTurbidity.slightlyTurbid:
        score += 8;
      case WaterTurbidity.clear:
        score += 3;
    }

    if (waterBody?.type == 'lake') score += 3;

    return TechniqueScore(
      type: TechniqueType.feeder,
      score: score.clamp(0, 100),
      rating: _rating(score.clamp(0, 100)),
      targetFish: _feederFish(month),
    );
  }

  static TechniqueScore _scoreSpinning(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month,
  ) {
    int score = 50;
    final temp = forecast.avgTemperature;
    final wind = forecast.avgWindSpeed;
    final rain = forecast.totalPrecipitation;
    final pressure = forecast.avgPressure;
    final clouds = forecast.avgCloudCover;

    // Predatori aktivni 8–20°C; som i na višim
    if (temp >= 8 && temp <= 20) {
      score += 15;
    } else if (temp > 20 && temp <= 26) {
      score += 5;
    } else if (temp < 5) {
      score -= 20;
    } else if (temp > 26) {
      score -= 10;
    }

    // Malo talasanja aktivira predatore
    if (wind >= 8 && wind <= 20) {
      score += 8;
    } else if (wind < 8) {
      score += 3;
    } else if (wind < 30) {
      score -= 12;
    } else if (wind < 40) {
      score -= 25;
    } else {
      score -= 35;
    }

    score += FishingScore.windDirectionAdjustment(forecast.avgWindDirection, wind);

    // Predatori love na vid — mutna voda loša
    if (rain < 1) {
      score += 3;
    } else if (rain < 2) {
      score -= 3;
    } else if (rain < 8) {
      score -= 12;
    } else if (rain < 20) {
      score -= 25;
    } else {
      score -= 40;
    }

    if (pressure >= 1013 && pressure <= 1025) {
      score += 5;
    } else if (pressure < 1000) {
      score -= 12;
    } else if (pressure > 1025) {
      score += 2;
    }

    // Polumrak aktivira predatore
    if (clouds >= 20 && clouds <= 60) {
      score += 10;
    } else if (clouds > 60) {
      score += 4;
    } else if (clouds == 0) {
      score -= 5;
    }

    // Bistra voda — predatori love na vid
    if (waterLevel != null) {
      switch (waterLevel.trend) {
        case WaterLevelTrend.stable:
          score += 10;
        case WaterLevelTrend.slightFall:
          score += 8;
        case WaterLevelTrend.slightRise:
          score -= 5;
        case WaterLevelTrend.largeRise:
          score -= 20;
        case WaterLevelTrend.largeFall:
          score -= 5;
      }
    }

    // Predatori love na vid — mutna voda loša za varalicarenje
    switch (forecast.turbidity) {
      case WaterTurbidity.veryTurbid:
        score -= 15;
      case WaterTurbidity.turbid:
        score -= 8;
      case WaterTurbidity.slightlyTurbid:
        score -= 2;
      case WaterTurbidity.clear:
        score += 10;
    }

    // Struja u reci = predatori na zasedi
    if (waterBody?.type == 'river') score += 5;

    return TechniqueScore(
      type: TechniqueType.spinning,
      score: score.clamp(0, 100),
      rating: _rating(score.clamp(0, 100)),
      targetFish: _spinningFish(month),
    );
  }

  static TechniqueScore _scoreFloat(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month,
  ) {
    int score = 50;
    final temp = forecast.avgTemperature;
    final wind = forecast.avgWindSpeed;
    final rain = forecast.totalPrecipitation;
    final pressure = forecast.avgPressure;
    final clouds = forecast.avgCloudCover;

    if (temp >= 12 && temp <= 22) {
      score += 15;
    } else if (temp >= 8 && temp < 12) {
      score += 5;
    } else if (temp < 5) {
      score -= 15;
    } else if (temp > 25) {
      score -= 5;
    }

    // Plovak zahteva mirnu površinu
    if (wind < 8) {
      score += 15;
    } else if (wind < 15) {
      score += 5;
    } else if (wind < 25) {
      score -= 15;
    } else if (wind < 35) {
      score -= 28;
    } else {
      score -= 38;
    }

    score += FishingScore.windDirectionAdjustment(forecast.avgWindDirection, wind);

    if (rain < 1) {
      score += 8;
    } else if (rain < 2) {
      score += 2;
    } else if (rain < 8) {
      score -= 12;
    } else if (rain < 20) {
      score -= 28;
    } else {
      score -= 42;
    }

    if (pressure >= 1013 && pressure <= 1025) {
      score += 10;
    } else if (pressure > 1025) {
      score += 4;
    } else if (pressure < 1000) {
      score -= 10;
    }

    if (clouds >= 30 && clouds <= 70) {
      score += 5;
    }

    // Plovak voli mirnu, bistru vodu
    if (waterLevel != null) {
      switch (waterLevel.trend) {
        case WaterLevelTrend.stable:
          score += 10;
        case WaterLevelTrend.slightFall:
          score += 5;
        case WaterLevelTrend.slightRise:
          score -= 5;
        case WaterLevelTrend.largeRise:
          score -= 20;
        case WaterLevelTrend.largeFall:
          score -= 8;
      }
    }

    // Plovak voli bistru vodu — vidljivost mamca
    switch (forecast.turbidity) {
      case WaterTurbidity.veryTurbid:
        score -= 10;
      case WaterTurbidity.turbid:
        score -= 5;
      case WaterTurbidity.slightlyTurbid:
        break;
      case WaterTurbidity.clear:
        score += 8;
    }

    // Jezero prirodno za plovak
    if (waterBody?.type == 'lake') score += 8;

    return TechniqueScore(
      type: TechniqueType.float,
      score: score.clamp(0, 100),
      rating: _rating(score.clamp(0, 100)),
      targetFish: _floatFish(month),
    );
  }

  static String feederRigRecommendation(
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    double windSpeed,
  ) {
    if (waterBody?.type == 'lake') return 'Method feeder / flat method';
    if (waterLevel?.trend == WaterLevelTrend.largeRise) return 'Teški inline feeder (80–150g)';
    if (windSpeed > 25 || waterLevel?.trend == WaterLevelTrend.slightRise) {
      return 'Cage feeder (50–80g), kraći hooklink';
    }
    return 'Cage feeder standardni (30–60g)';
  }

  static FishingRating _rating(int score) {
    if (score >= 80) return FishingRating.excellent;
    if (score >= 60) return FishingRating.good;
    if (score >= 40) return FishingRating.fair;
    if (score >= 20) return FishingRating.poor;
    return FishingRating.terrible;
  }

  static List<String> _feederFish(int month) {
    if (month >= 3 && month <= 5) return ['Šaran', 'Deverika', 'Bodorka'];
    if (month >= 6 && month <= 8) return ['Šaran', 'Amur', 'Deverika'];
    if (month >= 9 && month <= 11) return ['Šaran', 'Deverika', 'Bodorka'];
    return ['Deverika', 'Bodorka'];
  }

  static List<String> _spinningFish(int month) {
    if (month == 3 || month == 4) return ['Štuka', 'Smuđ', 'Klen'];
    if (month >= 5 && month <= 8) return ['Som', 'Smuđ', 'Klen'];
    if (month >= 9 && month <= 11) return ['Štuka', 'Smuđ'];
    return ['Smuđ'];
  }

  static List<String> _floatFish(int month) {
    if (month >= 3 && month <= 5) return ['Deverika', 'Bodorka', 'Karaš'];
    if (month >= 6 && month <= 9) return ['Amur', 'Karaš', 'Deverika'];
    return ['Deverika', 'Bodorka', 'Karaš'];
  }

  static List<SeasonalFish> _fishForMonth(int month) {
    if (month <= 2) {
      return [
        SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder · Plovak'),
        SeasonalFish(name: 'Bodorka', emoji: '🐟', technique: 'Plovak'),
        SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
      ];
    }
    if (month <= 4) {
      return [
        SeasonalFish(name: 'Štuka', emoji: '🐟', technique: 'Varalicarenje'),
        SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Feeder'),
        SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder · Plovak'),
        SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
      ];
    }
    if (month <= 6) {
      return [
        SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Feeder'),
        SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder · Plovak'),
        SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
        SeasonalFish(name: 'Klen', emoji: '🐟', technique: 'Varalicarenje'),
      ];
    }
    if (month <= 8) {
      return [
        SeasonalFish(name: 'Som', emoji: '🐋', technique: 'Varalicarenje'),
        SeasonalFish(name: 'Amur', emoji: '🐠', technique: 'Plovak · Feeder'),
        SeasonalFish(name: 'Tolstolobik', emoji: '🐟', technique: 'Specijalni rig'),
        SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Feeder'),
        SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
      ];
    }
    if (month <= 10) {
      return [
        SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Feeder'),
        SeasonalFish(name: 'Štuka', emoji: '🐟', technique: 'Varalicarenje'),
        SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
        SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder · Plovak'),
      ];
    }
    return [
      SeasonalFish(name: 'Štuka', emoji: '🐟', technique: 'Varalicarenje'),
      SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Varalicarenje'),
      SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder · Plovak'),
      SeasonalFish(name: 'Bodorka', emoji: '🐟', technique: 'Plovak'),
    ];
  }
}
