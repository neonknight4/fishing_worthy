import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<List<DailyForecast>> fetchForecast(double lat, double lon) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'hourly': 'temperature_2m,precipitation,cloudcover,windspeed_10m,winddirection_10m,pressure_msl,weathercode',
      'forecast_days': '7',
      'timezone': 'auto',
      'windspeed_unit': 'kmh',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _parse(data);
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
