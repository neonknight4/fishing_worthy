import 'dart:math';

enum PressureTrendCategory { rapidRise, slowRise, stable, preFront, rapidFall }

enum WaterTurbidity { clear, slightlyTurbid, turbid, veryTurbid }

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double precipitation;
  final int cloudCover;
  final double windSpeed;
  final double windDirection;
  final double pressureMsl;
  final int weatherCode;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitation,
    required this.cloudCover,
    required this.windSpeed,
    required this.windDirection,
    required this.pressureMsl,
    required this.weatherCode,
  });
}

class DailyForecast {
  final DateTime date;
  final List<HourlyWeather> hours;

  const DailyForecast({required this.date, required this.hours});

  double get avgTemperature =>
      hours.isEmpty ? 0 : hours.map((h) => h.temperature).reduce((a, b) => a + b) / hours.length;

  double get totalPrecipitation =>
      hours.isEmpty ? 0 : hours.map((h) => h.precipitation).reduce((a, b) => a + b);

  double get avgWindSpeed =>
      hours.isEmpty ? 0 : hours.map((h) => h.windSpeed).reduce((a, b) => a + b) / hours.length;

  double get avgWindDirection {
    if (hours.isEmpty) return 0;
    double sinSum = 0, cosSum = 0;
    for (final h in hours) {
      final rad = h.windDirection * pi / 180;
      sinSum += sin(rad);
      cosSum += cos(rad);
    }
    return (atan2(sinSum, cosSum) * 180 / pi + 360) % 360;
  }

  double get avgPressure =>
      hours.isEmpty ? 0 : hours.map((h) => h.pressureMsl).reduce((a, b) => a + b) / hours.length;

  int get avgCloudCover =>
      hours.isEmpty ? 0 : (hours.map((h) => h.cloudCover).reduce((a, b) => a + b) / hours.length).round();

  double get pressureTrendPer3h {
    if (hours.length < 6) return 0;
    final hoursSpan = hours.last.time.difference(hours.first.time).inHours;
    if (hoursSpan == 0) return 0;
    return (hours.last.pressureMsl - hours.first.pressureMsl) / hoursSpan * 3;
  }

  PressureTrendCategory get pressureTrendCategory {
    final t = pressureTrendPer3h;
    if (t > 2.0) return PressureTrendCategory.rapidRise;
    if (t > 0.5) return PressureTrendCategory.slowRise;
    if (t < -2.0) return PressureTrendCategory.rapidFall;
    if (t < -0.5) return PressureTrendCategory.preFront;
    return PressureTrendCategory.stable;
  }

  WaterTurbidity get turbidity {
    final rain = totalPrecipitation;
    if (rain >= 20) return WaterTurbidity.veryTurbid;
    if (rain >= 8) return WaterTurbidity.turbid;
    if (rain >= 2) return WaterTurbidity.slightlyTurbid;
    return WaterTurbidity.clear;
  }

  double get estimatedWaterTemperature {
    final air = avgTemperature;
    final m = date.month;
    if (m >= 4 && m <= 5) return air - 3;
    if (m >= 6 && m <= 8) return air - 5;
    if (m >= 9 && m <= 10) return air - 3;
    return air - 1;
  }

  List<List<HourlyWeather>> getThreeHourSlots() {
    final slots = <List<HourlyWeather>>[];
    for (int i = 0; i < hours.length; i += 3) {
      slots.add(hours.sublist(i, (i + 3).clamp(0, hours.length)));
    }
    return slots;
  }
}

class LocationInfo {
  final String name;
  final double latitude;
  final double longitude;

  const LocationInfo({required this.name, required this.latitude, required this.longitude});
}

enum WaterLevelTrend { largeRise, slightRise, stable, slightFall, largeFall }

class WaterBody {
  final String name;
  final String type; // 'river' | 'lake'
  final double distanceKm;
  final double latitude;
  final double longitude;

  const WaterBody({
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
  });
}

class WaterLevelForecast {
  final WaterLevelTrend trend;
  final double currentDischarge;
  final List<double> weeklyDischarge;
  final String? waterBodyName;

  const WaterLevelForecast({
    required this.trend,
    required this.currentDischarge,
    required this.weeklyDischarge,
    this.waterBodyName,
  });

  String get trendLabel {
    switch (trend) {
      case WaterLevelTrend.largeRise:
        return 'Veliki porast vodostaja — loše za pecanje';
      case WaterLevelTrend.slightRise:
        return 'Blagi porast vodostaja — idealno za pecanje';
      case WaterLevelTrend.stable:
        return 'Stabilan vodostaj';
      case WaterLevelTrend.slightFall:
        return 'Blagi pad vodostaja';
      case WaterLevelTrend.largeFall:
        return 'Veliki pad vodostaja — loše za pecanje';
    }
  }

  String get trendIcon {
    switch (trend) {
      case WaterLevelTrend.largeRise:
        return '📈';
      case WaterLevelTrend.slightRise:
        return '↗';
      case WaterLevelTrend.stable:
        return '→';
      case WaterLevelTrend.slightFall:
        return '↘';
      case WaterLevelTrend.largeFall:
        return '📉';
    }
  }

  int get scoreAdjustment {
    switch (trend) {
      case WaterLevelTrend.slightRise:
        return 15;
      case WaterLevelTrend.stable:
        return 5;
      case WaterLevelTrend.slightFall:
        return -5;
      case WaterLevelTrend.largeRise:
        return -20;
      case WaterLevelTrend.largeFall:
        return -20;
    }
  }
}
