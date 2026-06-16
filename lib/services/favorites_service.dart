import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_data.dart';

class FavoritesService {
  static const _key = 'favorites';

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

  Future<bool> isFavorite(LocationInfo loc) async {
    final list = await load();
    return list.any((l) => _same(l, loc));
  }

  // Returns true if added, false if removed
  Future<bool> toggle(LocationInfo loc) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    final idx = list.indexWhere((l) => _same(l, loc));
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.insert(0, loc);
    }
    await prefs.setStringList(
      _key,
      list
          .map((l) => jsonEncode({'name': l.name, 'lat': l.latitude, 'lon': l.longitude}))
          .toList(),
    );
    return idx < 0;
  }

  bool _same(LocationInfo a, LocationInfo b) =>
      a.name == b.name ||
      ((a.latitude - b.latitude).abs() < 0.01 && (a.longitude - b.longitude).abs() < 0.01);
}
