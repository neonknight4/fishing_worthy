import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WaterService {
  // Cached offline dataset of named Serbian fishing waters.
  static List<Map<String, dynamic>>? _dataset;

  static Future<List<Map<String, dynamic>>> _loadDataset() async {
    if (_dataset != null) return _dataset!;
    final raw = await rootBundle.loadString('assets/data/serbia_waters.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _dataset = list;
    return list;
  }

  /// Returns named waters within [radiusKm] of (lat, lon) from the bundled
  /// offline dataset. Distance is to the nearest point of each water; the
  /// returned lat/lon is that nearest point.
  Future<List<WaterBody>> fetchNearbyWaterBodies(
    double lat,
    double lon, {
    int radiusKm = 10,
  }) async {
    final maxResults = radiusKm <= 10 ? 30 : radiusKm <= 25 ? 60 : 120;
    final data = await _loadDataset();
    final bodies = <WaterBody>[];

    for (final w in data) {
      final name = w['n'] as String;
      final type = w['t'] as String;
      final points = w['p'] as List;

      double best = double.infinity;
      double bestLat = lat, bestLon = lon;
      for (final p in points) {
        final pLat = (p[0] as num).toDouble();
        final pLon = (p[1] as num).toDouble();
        final d = _haversineKm(lat, lon, pLat, pLon);
        if (d < best) {
          best = d;
          bestLat = pLat;
          bestLon = pLon;
        }
      }

      if (best <= radiusKm) {
        bodies.add(WaterBody(
          name: name,
          type: type,
          distanceKm: best,
          latitude: bestLat,
          longitude: bestLon,
        ));
      }
    }

    bodies.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return bodies.take(maxResults).toList();
  }

  Future<WaterLevelForecast?> fetchWaterLevelForecast(
    double lat,
    double lon, {
    String? waterBodyName,
  }) async {
    final uri = Uri.parse('https://flood-api.open-meteo.com/v1/flood').replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'daily': 'river_discharge',
        'past_days': '3',
        'forecast_days': '7',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>?;
      if (daily == null) return null;

      final times = (daily['time'] as List?)?.cast<String>() ?? [];
      final rawDischarge = daily['river_discharge'] as List? ?? [];
      if (times.isEmpty) return null;

      final discharge = rawDischarge.map((v) => (v as num?)?.toDouble() ?? 0.0).toList();

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final todayIdx = times.indexOf(todayStr);
      if (todayIdx < 0) return null;

      final currentVal = discharge[todayIdx];
      final pastIdx = (todayIdx - 2).clamp(0, discharge.length - 1);
      final pastVal = discharge[pastIdx];

      final trend = _calculateTrend(pastVal, currentVal);
      final weekly = discharge.sublist(todayIdx, (todayIdx + 7).clamp(0, discharge.length));

      return WaterLevelForecast(
        trend: trend,
        currentDischarge: currentVal,
        weeklyDischarge: weekly,
        waterBodyName: waterBodyName,
      );
    } catch (_) {
      return null;
    }
  }

  WaterLevelTrend _calculateTrend(double past, double current) {
    if (past <= 0) return WaterLevelTrend.stable;
    final changePct = (current - past) / past * 100;
    if (changePct > 30) return WaterLevelTrend.largeRise;
    if (changePct > 5) return WaterLevelTrend.slightRise;
    if (changePct < -30) return WaterLevelTrend.largeFall;
    if (changePct < -5) return WaterLevelTrend.slightFall;
    return WaterLevelTrend.stable;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}
