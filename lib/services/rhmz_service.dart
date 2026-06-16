import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Real water temperature from the nearest RHMZ hydrological station.
class WaterTempReading {
  final double tempC;
  final String station;
  final String river;
  final double distanceKm;

  const WaterTempReading({
    required this.tempC,
    required this.station,
    required this.river,
    required this.distanceKm,
  });
}

/// RHMZ 1–4 day water-level forecast for a big-river station.
class LevelForecastReading {
  final String station;
  final String river;
  final int todayCm;
  final int forecastCm; // last available forecast day
  final String trend; // 'raste' | 'pada' | 'stabilan'
  final double distanceKm;

  const LevelForecastReading({
    required this.station,
    required this.river,
    required this.todayCm,
    required this.forecastCm,
    required this.trend,
    required this.distanceKm,
  });

  int get deltaCm => forecastCm - todayCm;
}

class RhmzService {
  static const _url = 'https://www.hidmet.gov.rs/ciril/osmotreni/stanje_voda.php';
  static const _forecastUrl =
      'https://www.hidmet.gov.rs/ciril/prognoza/prognoza_voda.php';

  // Cyrillic→Latin for matching forecast station names to the bundle.
  static const _cyr2lat = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'ђ': 'đ', 'е': 'e',
    'ж': 'ž', 'з': 'z', 'и': 'i', 'ј': 'j', 'к': 'k', 'л': 'l', 'љ': 'lj',
    'м': 'm', 'н': 'n', 'њ': 'nj', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's',
    'т': 't', 'ћ': 'ć', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'c', 'ч': 'č',
    'џ': 'dž', 'ш': 'š',
  };

  static String _translit(String s) {
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      b.write(_cyr2lat[ch] ?? ch);
    }
    return b.toString().trim();
  }

  static Map<String, ({String river, int today, int forecast, String trend})>?
      _levelCache;
  static DateTime? _levelFetchedAt;

  // Bundled station coordinates (hm_id -> {river, station, lat, lon}).
  static List<Map<String, dynamic>>? _stations;
  // Cached live temps (hm_id -> °C) + fetch time.
  static Map<String, double>? _tempCache;
  static DateTime? _tempFetchedAt;

  static Future<List<Map<String, dynamic>>> _loadStations() async {
    if (_stations != null) return _stations!;
    final raw = await rootBundle.loadString('assets/data/rhmz_stations.json');
    _stations = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return _stations!;
  }

  http.Client _client() {
    // RHMZ serves an incomplete TLS chain — accept its cert for this host only.
    final inner = HttpClient()
      ..badCertificateCallback =
          (cert, host, port) => host == 'www.hidmet.gov.rs';
    return IOClient(inner);
  }

  Future<Map<String, double>> _fetchTemps() async {
    final now = DateTime.now();
    if (_tempCache != null &&
        _tempFetchedAt != null &&
        now.difference(_tempFetchedAt!).inMinutes < 30) {
      return _tempCache!;
    }

    final client = _client();
    try {
      final resp = await client
          .get(Uri.parse(_url), headers: {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return _tempCache ?? {};
      final temps = _parseTemps(resp.body);
      _tempCache = temps;
      _tempFetchedAt = now;
      return temps;
    } finally {
      client.close();
    }
  }

  Map<String, double> _parseTemps(String htmlBody) {
    final temps = <String, double>{};
    final rows = htmlBody.split('<tr');
    final tdRe = RegExp(r'<td.*?</td>', dotAll: true);
    final hmRe = RegExp(r'hm_id=(\d+)');
    final tagRe = RegExp(r'<[^>]+>');

    for (final row in rows) {
      final hm = hmRe.firstMatch(row)?.group(1);
      if (hm == null) continue;
      final tds = tdRe.allMatches(row).map((m) => m.group(0)!).toList();
      // 'tendencije/' appears in several cells (defense level, hourly/yearly
      // link icons, water-level tendency). The water-level tendency icon is the
      // last; the temperature value sits in the cell right before it.
      final tendIdx = <int>[];
      for (var i = 0; i < tds.length; i++) {
        if (tds[i].contains('tendencije/')) tendIdx.add(i);
      }
      if (tendIdx.length < 2) continue;
      final text = tds[tendIdx.last - 1]
          .replaceAll(tagRe, '')
          .replaceAll('&nbsp;', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'\s'), '');
      final v = double.tryParse(text);
      if (v != null && v > -5 && v < 40) temps[hm] = v;
    }
    return temps;
  }

  /// Nearest station that has a live water temperature, within [maxKm].
  Future<WaterTempReading?> nearestWaterTemp(
    double lat,
    double lon, {
    double maxKm = 70,
  }) async {
    final stations = await _loadStations();
    final temps = await _fetchTemps();
    if (temps.isEmpty) return null;

    WaterTempReading? best;
    double bestDist = double.infinity;
    for (final st in stations) {
      final hm = st['hm'] as String;
      final temp = temps[hm];
      if (temp == null) continue;
      final d = _haversineKm(
          lat, lon, (st['lat'] as num).toDouble(), (st['lon'] as num).toDouble());
      if (d < bestDist && d <= maxKm) {
        bestDist = d;
        best = WaterTempReading(
          tempC: temp,
          station: st['s'] as String,
          river: st['r'] as String,
          distanceKm: d,
        );
      }
    }
    return best;
  }

  // station(Latin) -> {river, today, forecast, trend}
  Future<Map<String, ({String river, int today, int forecast, String trend})>>
      _fetchLevels() async {
    final now = DateTime.now();
    if (_levelCache != null &&
        _levelFetchedAt != null &&
        now.difference(_levelFetchedAt!).inMinutes < 60) {
      return _levelCache!;
    }
    final client = _client();
    try {
      final resp = await client
          .get(Uri.parse(_forecastUrl), headers: {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return _levelCache ?? {};
      final parsed = _parseLevels(resp.body);
      _levelCache = parsed;
      _levelFetchedAt = now;
      return parsed;
    } finally {
      client.close();
    }
  }

  Map<String, ({String river, int today, int forecast, String trend})>
      _parseLevels(String htmlBody) {
    final out = <String, ({String river, int today, int forecast, String trend})>{};
    final tagRe = RegExp(r'<[^>]+>');
    final cellRe = RegExp(r'<t[dh][^>]*>(.*?)</t[dh]>', dotAll: true);
    final rowRe = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true);

    String clean(String c) => c
        .replaceAll(tagRe, '')
        .replaceAll('&nbsp;', '')
        .replaceAll(RegExp(r'\s'), '')
        .trim();

    for (final m in rowRe.allMatches(htmlBody)) {
      final cells =
          cellRe.allMatches(m.group(1)!).map((c) => clean(c.group(1)!)).toList();
      // [river, station, today, fc1..fc4, defReg, defExtra] == 9
      if (cells.length != 9) continue;
      final river = cells[0];
      final station = cells[1];
      if (river.isEmpty || station.isEmpty) continue;
      final today = int.tryParse(cells[2]);
      if (today == null) continue;
      // forecast days = indices 3..6; take last valid
      int? lastFc;
      for (var i = 3; i <= 6; i++) {
        final v = int.tryParse(cells[i]);
        if (v != null) lastFc = v;
      }
      if (lastFc == null) continue;
      final delta = lastFc - today;
      final trend = delta > 5 ? 'raste' : (delta < -5 ? 'pada' : 'stabilan');
      out[_translit(station)] = (
        river: _capitalize(_translit(river)),
        today: today,
        forecast: lastFc,
        trend: trend,
      );
    }
    return out;
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// All big rivers with a level forecast within [maxKm], one (nearest)
  /// station per river, sorted by distance.
  Future<List<LevelForecastReading>> levelForecastsWithin(
    double lat,
    double lon, {
    double maxKm = 60,
  }) async {
    final stations = await _loadStations();
    final levels = await _fetchLevels();
    if (levels.isEmpty) return [];

    // river -> best (nearest) reading
    final byRiver = <String, LevelForecastReading>{};
    for (final st in stations) {
      final key = _translit(st['s'] as String);
      final fc = levels[key];
      if (fc == null) continue;
      final d = _haversineKm(lat, lon, (st['lat'] as num).toDouble(),
          (st['lon'] as num).toDouble());
      if (d > maxKm) continue;
      final existing = byRiver[fc.river];
      if (existing == null || d < existing.distanceKm) {
        byRiver[fc.river] = LevelForecastReading(
          station: st['s'] as String,
          river: fc.river,
          todayCm: fc.today,
          forecastCm: fc.forecast,
          trend: fc.trend,
          distanceKm: d,
        );
      }
    }
    final list = byRiver.values.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
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
