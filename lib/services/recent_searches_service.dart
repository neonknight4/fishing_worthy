import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class RecentSearchesService {
  static const _key = 'recent_searches';
  static const _max = 8;

  Future<List<LocationInfo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return LocationInfo(
        name: m['name'] as String,
        latitude: (m['lat'] as num).toDouble(),
        longitude: (m['lon'] as num).toDouble(),
      );
    }).toList();
  }

  Future<void> save(LocationInfo loc) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    list.removeWhere((l) =>
        l.name == loc.name ||
        ((l.latitude - loc.latitude).abs() < 0.01 &&
            (l.longitude - loc.longitude).abs() < 0.01));
    list.insert(0, loc);
    if (list.length > _max) list.removeLast();
    await prefs.setStringList(
      _key,
      list
          .map((l) => jsonEncode({'name': l.name, 'lat': l.latitude, 'lon': l.longitude}))
          .toList(),
    );
  }
}
