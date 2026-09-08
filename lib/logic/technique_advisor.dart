import '../models/fishing_score.dart' show FishingScore, FishingRating;
import '../models/technique_score.dart';
import '../models/weather_data.dart';

class TechniqueAdvisor {
  static List<TechniqueScore> advise(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    DateTime date, {
    double? waterTempC,
    bool floatTrotting = false,
  }) {
    final month = date.month;
    final scores = [
      _scoreFeeder(forecast, waterLevel, waterBody, month,
          waterTempOverride: waterTempC),
      _scoreSpinning(forecast, waterLevel, waterBody, month,
          waterTempOverride: waterTempC),
      _scoreFloat(forecast, waterLevel, waterBody, month,
          waterTempOverride: waterTempC, trotting: floatTrotting),
    ];
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  /// Vrste koje su sada aktivne za datu tehniku — na varalicu idu
  /// grabljivice, ne bela riba.
  static List<SeasonalFish> seasonalFish(
    DateTime date, {
    required TechniqueType type,
    bool floatTrotting = false,
  }) {
    final m = date.month;
    switch (type) {
      case TechniqueType.spinning:
        return _spinningSeasonal(m);
      case TechniqueType.feeder:
        return _feederSeasonal(m);
      case TechniqueType.float:
        return floatTrotting ? _trottingSeasonal(m) : _floatSeasonal(m);
    }
  }

  // Grabljivice na varalicu; podnaslov = klasa pribora.
  static List<SeasonalFish> _spinningSeasonal(int m) {
    const stuka = SeasonalFish(name: 'Štuka', emoji: '🐟', technique: 'Klasik · Teško');
    const smudj = SeasonalFish(name: 'Smuđ', emoji: '🐠', technique: 'Klasik');
    const bandar = SeasonalFish(name: 'Bandar', emoji: '🐟', technique: 'Ultra light');
    const klen = SeasonalFish(name: 'Klen', emoji: '🐟', technique: 'Ultra light');
    const bucov = SeasonalFish(name: 'Bucov', emoji: '🐟', technique: 'UL · Klasik');
    const som = SeasonalFish(name: 'Som', emoji: '🐋', technique: 'Teško');
    const bas = SeasonalFish(name: 'Bas', emoji: '🐟', technique: 'Ultra light');

    if (m <= 2) return const [stuka, smudj, bandar];
    if (m <= 4) return const [smudj, stuka, bandar, klen];
    if (m == 5) return const [smudj, klen, bandar, bucov];
    if (m <= 8) return const [som, bucov, klen, bandar, bas, smudj];
    if (m <= 10) return const [stuka, smudj, bucov, klen];
    return const [stuka, smudj, bandar];
  }

  static List<SeasonalFish> _feederSeasonal(int m) {
    const saran = SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Feeder · Method');
    const deverika = SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Feeder');
    const bodorka = SeasonalFish(name: 'Bodorka', emoji: '🐟', technique: 'Feeder');
    const amur = SeasonalFish(name: 'Amur', emoji: '🐠', technique: 'Method');
    const babuska = SeasonalFish(name: 'Babuška', emoji: '🐟', technique: 'Feeder');
    const mrena = SeasonalFish(name: 'Mrena', emoji: '🐟', technique: 'Rečni feeder');

    if (m <= 2) return const [deverika, bodorka];
    if (m <= 5) return const [saran, deverika, bodorka, babuska];
    if (m <= 8) return const [saran, amur, deverika, mrena, babuska];
    if (m <= 10) return const [saran, deverika, bodorka, babuska];
    return const [deverika, bodorka];
  }

  static List<SeasonalFish> _floatSeasonal(int m) {
    const deverika = SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Plovak');
    const bodorka = SeasonalFish(name: 'Bodorka', emoji: '🐟', technique: 'Plovak');
    const babuska = SeasonalFish(name: 'Babuška', emoji: '🐟', technique: 'Plovak');
    const saran = SeasonalFish(name: 'Šaran', emoji: '🐠', technique: 'Plovak');
    const amur = SeasonalFish(name: 'Amur', emoji: '🐠', technique: 'Plovak');
    const klen = SeasonalFish(name: 'Klen', emoji: '🐟', technique: 'Plovak');

    if (m <= 2) return const [deverika, bodorka];
    if (m <= 5) return const [deverika, bodorka, babuska, saran];
    if (m <= 9) return const [saran, amur, babuska, klen, deverika];
    return const [deverika, bodorka, klen];
  }

  // Otpuštanje — rečne vrste sa šljunkovitih poteza.
  static List<SeasonalFish> _trottingSeasonal(int m) {
    const skobalj = SeasonalFish(name: 'Skobalj', emoji: '🐟', technique: 'Trava · hleb');
    const plotica = SeasonalFish(name: 'Plotica', emoji: '🐟', technique: 'Slobodno puštanje');
    const mrena = SeasonalFish(name: 'Mrena', emoji: '🐟', technique: 'Crv · glista');
    const klen = SeasonalFish(name: 'Klen', emoji: '🐟', technique: 'Hleb · testo');
    const deverika = SeasonalFish(name: 'Deverika', emoji: '🐟', technique: 'Štopovanje');

    if (m <= 2) return const [skobalj, plotica];
    if (m <= 5) return const [skobalj, plotica, klen, mrena];
    if (m <= 8) return const [mrena, klen, skobalj, deverika];
    return const [skobalj, plotica, mrena, klen];
  }

  /// Score a single technique for a forecast (used by per-interval filter).
  static int scoreFor(
    TechniqueType type,
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month, {
    double? waterTempOverride,
    bool floatTrotting = false,
  }) {
    switch (type) {
      case TechniqueType.feeder:
        return _scoreFeeder(forecast, waterLevel, waterBody, month,
                waterTempOverride: waterTempOverride)
            .score;
      case TechniqueType.spinning:
        return _scoreSpinning(forecast, waterLevel, waterBody, month,
                waterTempOverride: waterTempOverride)
            .score;
      case TechniqueType.float:
        return _scoreFloat(forecast, waterLevel, waterBody, month,
                waterTempOverride: waterTempOverride, trotting: floatTrotting)
            .score;
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

    final pos = <String>[], neg = <String>[];
    _tempReason(pos, neg, parts[0][0], waterTemp);
    _pressureReason(pos, neg, forecast.pressureTrendCategory);
    _windReason(pos, neg, wind, calm: true);
    switch (forecast.turbidity) {
      case WaterTurbidity.slightlyTurbid:
        pos.add('Blago mutna voda — bela riba se opušta, primama radi');
      case WaterTurbidity.veryTurbid:
        neg.add('Jako mutna voda — riba teško locira mamac');
      case WaterTurbidity.clear:
      case WaterTurbidity.turbid:
        break;
    }
    _cloudReason(pos, neg, forecast.avgCloudCover, 40, 80);
    _rainReason(pos, neg, forecast.totalPrecipitation);
    if (waterLevel != null) {
      _levelReason(pos, neg, FishingScore.levelSubWhite(waterLevel.trend),
          waterLevel.trendLabel);
    }

    return TechniqueScore(
      type: TechniqueType.feeder,
      score: score,
      rating: _rating(score),
      targetFish: _feederFish(month),
      positives: pos,
      negatives: neg,
    );
  }

  // ── Reason builders (deljeni; tekst se razlikuje po tehnici) ───────────────

  static void _tempReason(
      List<String> pos, List<String> neg, double sub, double t) {
    final v = t.toStringAsFixed(0);
    if (sub >= 82) {
      pos.add('Temperatura vode idealna (~$v°C)');
    } else if (sub <= 42) {
      neg.add('Temperatura vode nepovoljna (~$v°C)');
    }
  }

  static void _pressureReason(
      List<String> pos, List<String> neg, PressureTrendCategory c) {
    switch (c) {
      case PressureTrendCategory.preFront:
        pos.add('⚡ Pre-frontalni prozor — ribe se nabacuju pred promenu');
      case PressureTrendCategory.stable:
        pos.add('Stabilan pritisak — ribe predvidive');
      case PressureTrendCategory.rapidFall:
        neg.add('Brzi pad pritiska — ribe se gase');
      case PressureTrendCategory.rapidRise:
        neg.add('Pritisak naglo raste — ribe se adaptiraju');
      case PressureTrendCategory.slowRise:
        break;
    }
  }

  /// [calm] = tehnika traži mirnu površinu (feeder/plovak);
  /// inače blago talasanje pomaže (varalica).
  static void _windReason(List<String> pos, List<String> neg, double w,
      {required bool calm}) {
    final v = w.toStringAsFixed(0);
    if (calm) {
      if (w < 10) {
        pos.add('Slab vetar ($v km/h) — kontrola štapa i precizan zabačaj');
      } else if (w >= 30) {
        neg.add('Jak vetar ($v km/h) — otežano bacanje i držanje linije');
      }
    } else {
      if (w >= 8 && w <= 22) {
        pos.add('Vetar $v km/h — blago talasanje razbija svetlo, grabljivica smelija');
      } else if (w < 3) {
        neg.add('Bonaca — ogledalo na površini, grabljivica opreznija');
      } else if (w >= 32) {
        neg.add('Jak vetar ($v km/h) — gubi se kontakt sa varalicom');
      }
    }
  }

  static void _cloudReason(
      List<String> pos, List<String> neg, int clouds, int lo, int hi) {
    if (clouds >= lo && clouds <= hi) {
      pos.add('Oblačnost $clouds% — u optimalnom rasponu');
    } else if (clouds == 0) {
      neg.add('Vedro nebo — ribe opreznije');
    } else if (clouds >= 95) {
      neg.add('Potpuno zatvoreno nebo ($clouds%)');
    }
  }

  static void _rainReason(List<String> pos, List<String> neg, double r) {
    if (r >= 8) {
      neg.add('Jaka kiša (${r.toStringAsFixed(1)} mm)');
    } else if (r > 0 && r < 2) {
      pos.add('Lagana kiša — aktivira ribe');
    }
  }

  static void _levelReason(
      List<String> pos, List<String> neg, double sub, String label) {
    if (sub >= 84) {
      pos.add(label);
    } else if (sub <= 44) {
      neg.add(label);
    }
  }

  // Predator (varalica) water-temp sub-score: most active 8–20°C.
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

  // Plovak na otpuštanje: skobalj/plotica/mrena su hladnovodne mete —
  // zima je bolji deo sezone od leta, pa je kriva pomerena naniže.
  static double _trottingTempSub(double t) => (t >= 4 && t <= 14)
      ? 100
      : t > 14 && t <= 18
          ? 78
          : t >= 2 && t < 4
              ? 72
              : t > 18 && t <= 22
                  ? 52
                  : t > 22 && t <= 26
                      ? 32
                      : t < 2
                          ? 40
                          : 20;

  // Otpuštanje trpi jaču i višu vodu bolje od klasičnog plovka —
  // riba se sabije uz obalu i dođe u domet.
  static double _trottingLevelSub(WaterLevelTrend t) => switch (t) {
        WaterLevelTrend.stable => 100,
        WaterLevelTrend.slightRise => 92,
        WaterLevelTrend.slightFall => 76,
        WaterLevelTrend.largeRise => 54,
        WaterLevelTrend.largeFall => 40,
      };

  // Float (plovak) water-temp sub-score: most active 12–22°C.
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
    int month, {
    double? waterTempOverride,
  }) {
    final wind = forecast.avgWindSpeed;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Predatori: lov na vid (voli bistro), blago talasanje, polumrak.
    final windSub = 0.7 * FishingScore.windChopSub(wind) +
        0.3 * FishingScore.windDirSub(forecast.avgWindDirection, wind);
    final parts = <List<double>>[
      [_predatorTempSub(waterTemp), 0.24],
      [FishingScore.pressureSub(forecast.pressureTrendCategory, forecast.avgPressure), 0.15],
      [windSub, 0.18],
      [FishingScore.turbiditySubPredator(forecast.turbidity), 0.20],
      [FishingScore.cloudSub(forecast.avgCloudCover, 20, 60), 0.11],
    ];
    if (waterLevel != null) {
      parts.add([FishingScore.levelSubPredator(waterLevel.trend), 0.12]);
    }

    final score = FishingScore.weightedAverage(parts);

    final pos = <String>[], neg = <String>[];
    _tempReason(pos, neg, parts[0][0], waterTemp);
    _pressureReason(pos, neg, forecast.pressureTrendCategory);
    _windReason(pos, neg, wind, calm: false);
    switch (forecast.turbidity) {
      case WaterTurbidity.clear:
        pos.add('Bistra voda — grabljivica lovi na vid, varalica se vidi izdaleka');
      case WaterTurbidity.turbid:
        neg.add('Mutna voda — smanji domet varalice, idi na vibraciju i zvuk');
      case WaterTurbidity.veryTurbid:
        neg.add('Jako mutna voda — lov na vid ne radi');
      case WaterTurbidity.slightlyTurbid:
        break;
    }
    _cloudReason(pos, neg, forecast.avgCloudCover, 20, 60);
    if (waterLevel != null) {
      _levelReason(pos, neg, FishingScore.levelSubPredator(waterLevel.trend),
          waterLevel.trendLabel);
    }

    return TechniqueScore(
      type: TechniqueType.spinning,
      score: score,
      rating: _rating(score),
      targetFish: _spinningFish(month),
      positives: pos,
      negatives: neg,
    );
  }

  static TechniqueScore _scoreFloat(
    DailyForecast forecast,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    int month, {
    double? waterTempOverride,
    bool trotting = false,
  }) {
    final wind = forecast.avgWindSpeed;
    final waterTemp = waterTempOverride ?? forecast.estimatedWaterTemperature;

    // Plovak: traži mirnu površinu i bistru vodu (vidljivost mamca).
    // Otpuštanje je druga priča — skobalj je zimska riba i trpi jaču vodu.
    final windSub = 0.85 * FishingScore.windCalmSub(wind) +
        0.15 * FishingScore.windDirSub(forecast.avgWindDirection, wind);
    final tempSub =
        trotting ? _trottingTempSub(waterTemp) : _floatTempSub(waterTemp);
    final levelSub = waterLevel == null
        ? null
        : trotting
            ? _trottingLevelSub(waterLevel.trend)
            : FishingScore.levelSubWhite(waterLevel.trend);
    final parts = <List<double>>[
      [tempSub, 0.26],
      [FishingScore.pressureSub(forecast.pressureTrendCategory, forecast.avgPressure), 0.15],
      [windSub, 0.22],
      [FishingScore.turbiditySubClear(forecast.turbidity), 0.12],
      [FishingScore.cloudSub(forecast.avgCloudCover, 30, 70), 0.08],
      [FishingScore.rainSub(forecast.totalPrecipitation), 0.05],
    ];
    if (levelSub != null) parts.add([levelSub, 0.12]);
    final score = FishingScore.weightedAverage(parts);

    final pos = <String>[], neg = <String>[];
    if (trotting) {
      if (tempSub >= 82) {
        pos.add('Temperatura vode (~${waterTemp.toStringAsFixed(0)}°C) '
            'odgovara skobalju — hladnije je bolje');
      } else if (tempSub <= 42) {
        neg.add('Voda pretopla (~${waterTemp.toStringAsFixed(0)}°C) — '
            'skobalj radi samo u zoru i sumrak');
      }
    } else {
      _tempReason(pos, neg, tempSub, waterTemp);
    }
    _pressureReason(pos, neg, forecast.pressureTrendCategory);
    _windReason(pos, neg, wind, calm: true);
    switch (forecast.turbidity) {
      case WaterTurbidity.clear:
        pos.add(trotting
            ? 'Bistra voda — trava radi, ali riba se povlači u maticu'
            : 'Bistra voda — mamac se vidi, plovak radi u punom kapacitetu');
      case WaterTurbidity.turbid:
      case WaterTurbidity.veryTurbid:
        neg.add(trotting
            ? 'Mutna voda — trava slabi, prebaci na crva i kaster'
            : 'Mutna voda — riba teško nalazi mamac pod plovkom');
      case WaterTurbidity.slightlyTurbid:
        break;
    }
    _cloudReason(pos, neg, forecast.avgCloudCover, 30, 70);
    _rainReason(pos, neg, forecast.totalPrecipitation);
    if (waterLevel != null && levelSub != null) {
      _levelReason(pos, neg, levelSub, waterLevel.trendLabel);
    }

    return TechniqueScore(
      type: TechniqueType.float,
      score: score,
      rating: _rating(score),
      targetFish: _floatFish(month),
      positives: pos,
      negatives: neg,
    );
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

}
