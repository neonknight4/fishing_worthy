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
    final wind = forecast.avgWindSpeed;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Feeder: mir za kontrolu štapa; toleriše blago mutnu vodu (mirisni mamac).
    final windSub = 0.75 * FishingScore.windCalmSub(wind) +
        0.25 * FishingScore.windDirSub(forecast.avgWindDirection, wind);
    final parts = <List<double>>[
      [FishingScore.waterTempScore(waterTemp).toDouble(), 0.28],
      [FishingScore.pressureSub(forecast.pressureTrendCategory, forecast.avgPressure), 0.17],
      [windSub, 0.15],
      [FishingScore.turbiditySubWhite(forecast.turbidity), 0.12],
      [FishingScore.cloudSub(forecast.avgCloudCover, 40, 80), 0.09],
      [FishingScore.rainSub(forecast.totalPrecipitation), 0.07],
    ];
    if (waterLevel != null) {
      parts.add([FishingScore.levelSubWhite(waterLevel.trend), 0.12]);
    }

    int score = FishingScore.weightedAverage(parts);
    if (waterTemp < 4) score = score.clamp(0, 18);
    if (waterTemp > 30) score = score.clamp(0, 25);

    return TechniqueScore(
      type: TechniqueType.feeder,
      score: score,
      rating: _rating(score),
      targetFish: _feederFish(month),
    );
  }

  // Predator (varalica) air-temp sub-score: most active 8–20°C.
  static double _predatorTempSub(double t) => (t >= 8 && t <= 20)
      ? 100
      : t >= 20 && t <= 24
          ? 72
          : t >= 5 && t < 8
              ? 62
              : t > 24 && t <= 26
                  ? 50
                  : t < 5
                      ? 14
                      : 32;

  // Float (plovak) air-temp sub-score: most active 12–22°C.
  static double _floatTempSub(double t) => (t >= 12 && t <= 22)
      ? 100
      : t >= 8 && t < 12
          ? 70
          : t > 22 && t <= 25
              ? 72
              : t >= 5 && t < 8
                  ? 42
                  : t > 25 && t <= 28
                      ? 48
                      : t < 5
                          ? 18
                          : 30;

  static TechniqueScore _scoreSpinning(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month,
  ) {
    final wind = forecast.avgWindSpeed;

    // Predatori: lov na vid (voli bistro), blago talasanje, polumrak.
    final windSub = 0.7 * FishingScore.windChopSub(wind) +
        0.3 * FishingScore.windDirSub(forecast.avgWindDirection, wind);
    final parts = <List<double>>[
      [_predatorTempSub(forecast.avgTemperature), 0.24],
      [FishingScore.pressureSub(forecast.pressureTrendCategory, forecast.avgPressure), 0.15],
      [windSub, 0.18],
      [FishingScore.turbiditySubPredator(forecast.turbidity), 0.20],
      [FishingScore.cloudSub(forecast.avgCloudCover, 20, 60), 0.11],
    ];
    if (waterLevel != null) {
      parts.add([FishingScore.levelSubPredator(waterLevel.trend), 0.12]);
    }

    final score = FishingScore.weightedAverage(parts);
    return TechniqueScore(
      type: TechniqueType.spinning,
      score: score,
      rating: _rating(score),
      targetFish: _spinningFish(month),
    );
  }

  static TechniqueScore _scoreFloat(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month,
  ) {
    final wind = forecast.avgWindSpeed;

    // Plovak: traži mirnu površinu i bistru vodu (vidljivost mamca).
    final windSub = 0.85 * FishingScore.windCalmSub(wind) +
        0.15 * FishingScore.windDirSub(forecast.avgWindDirection, wind);
    final parts = <List<double>>[
      [_floatTempSub(forecast.avgTemperature), 0.26],
      [FishingScore.pressureSub(forecast.pressureTrendCategory, forecast.avgPressure), 0.15],
      [windSub, 0.22],
      [FishingScore.turbiditySubClear(forecast.turbidity), 0.12],
      [FishingScore.cloudSub(forecast.avgCloudCover, 30, 70), 0.08],
      [FishingScore.rainSub(forecast.totalPrecipitation), 0.05],
    ];
    if (waterLevel != null) {
      parts.add([FishingScore.levelSubWhite(waterLevel.trend), 0.12]);
    }
    final score = FishingScore.weightedAverage(parts);

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
