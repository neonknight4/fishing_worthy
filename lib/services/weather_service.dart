import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import 'api_cache.dart';

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Vreme upisa keša kad je poslednji `fetchForecast` posluženo sa diska
  /// (nema mreže); `null` = podaci su sveži. UI odavde vadi „podaci od HH:mm".
  DateTime? servedFromCacheAt;

  /// 7-dnevna prognoza. Uspešan odgovor ide u disk keš; ako mreže nema,
  /// servira se keširani odgovor za istu lokaciju (do 3 dana star).
  Future<List<DailyForecast>> fetchForecast(double lat, double lon) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'hourly': 'temperature_2m,precipitation,cloudcover,windspeed_10m,winddirection_10m,pressure_msl,weathercode',
      'forecast_days': '7',
      'timezone': 'auto',
      'windspeed_unit': 'kmh',
    });

    final key = ApiCache.coordKey('wx', lat, lon);
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Weather API error: ${response.statusCode}');
      }
      final days = _parse(jsonDecode(response.body) as Map<String, dynamic>);
      await ApiCache.put(key, response.body);
      servedFromCacheAt = null;
      return days;
    } catch (_) {
      final cached = await ApiCache.get(key);
      if (cached == null) throw Exception('Nema prognoze ni na mreži ni u kešu');
      // Keširan prozor je počeo u prošlosti — prošli dani se odbacuju da
      // „Danas" ne bi pokazivalo juče.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final days = _parse(jsonDecode(cached.body) as Map<String, dynamic>)
          .where((d) => !d.date.isBefore(today))
          .toList();
      if (days.isEmpty) throw Exception('Keširana prognoza je istekla');
      servedFromCacheAt = cached.savedAt;
      return days;
    }
  }

  /// Uslovi za jedan (prošli) dan — za dnevnik unos sa promenjenim datumom.
  /// Vraća `null` ako datum nije dostupan (prestar) ili greška.
  Future<DailyForecast?> fetchDay(double lat, double lon, DateTime day) async {
    final d = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'hourly': 'temperature_2m,precipitation,cloudcover,windspeed_10m,winddirection_10m,pressure_msl,weathercode',
      'start_date': d,
      'end_date': d,
      'timezone': 'auto',
      'windspeed_unit': 'kmh',
    });
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final days = _parse(data);
      return days.isEmpty ? null : days.first;
    } catch (_) {
      return null;
    }
  }

  List<DailyForecast> _parse(Map<String, dynamic> data) {
    final hourly = data['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final precip = (hourly['precipitation'] as List).cast<num>();
    final clouds = (hourly['cloudcover'] as List).cast<num>();
    final wind = (hourly['windspeed_10m'] as List).cast<num>();
    final windDir = (hourly['winddirection_10m'] as List).cast<num>();
    final pressure = (hourly['pressure_msl'] as List).cast<num>();
    final codes = (hourly['weathercode'] as List).cast<num>();

    final Map<String, List<HourlyWeather>> byDay = {};

    for (int i = 0; i < times.length; i++) {
      final dt = DateTime.parse(times[i]);
      final dayKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

      byDay.putIfAbsent(dayKey, () => []);
      byDay[dayKey]!.add(HourlyWeather(
        time: dt,
        temperature: temps[i].toDouble(),
        precipitation: precip[i].toDouble(),
        cloudCover: clouds[i].toInt(),
        windSpeed: wind[i].toDouble(),
        windDirection: windDir[i].toDouble(),
        pressureMsl: pressure[i].toDouble(),
        weatherCode: codes[i].toInt(),
      ));
    }

    return byDay.entries.map((e) {
      final date = DateTime.parse(e.key);
      return DailyForecast(date: date, hours: e.value);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
