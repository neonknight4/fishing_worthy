import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class LocationService {
  Future<LocationInfo> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Lokacijski servis isključen');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Lokacijska dozvola odbijena');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Lokacijska dozvola trajno odbijena — uključi u podešavanjima');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );

    final name = await _reverseGeocode(pos.latitude, pos.longitude);
    return LocationInfo(name: name, latitude: pos.latitude, longitude: pos.longitude);
  }

  Future<List<LocationInfo>> searchLocation(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('https://geocoding-api.open-meteo.com/v1/search').replace(
      queryParameters: {'name': query, 'count': '20', 'language': 'sr-Latn', 'format': 'json'},
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List? ?? [];

    return results.where((r) => r['country_code'] == 'RS').map((r) {
      final admin = r['admin1'] ?? '';
      final label = admin.isNotEmpty ? '${r['name']}, $admin' : '${r['name']}';
      return LocationInfo(
        name: label,
        latitude: (r['latitude'] as num).toDouble(),
        longitude: (r['longitude'] as num).toDouble(),
      );
    }).take(8).toList();
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'accept-language': 'sr-Latn',
        },
      );
      final response = await http.get(uri, headers: {'User-Agent': 'FishingWorthy/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        return address['city'] ?? address['town'] ?? address['village'] ?? 'Moja lokacija';
      }
    } catch (_) {}
    return 'Moja lokacija';
  }
}
