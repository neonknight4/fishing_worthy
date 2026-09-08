import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Keširano telo odgovora + vreme kad je upisano.
class CachedBody {
  final String body;
  final DateTime savedAt;
  const CachedBody(this.body, this.savedAt);
}

/// Disk keš odgovora eksternih servisa — da app radi na vodi bez signala.
///
/// Čuva se sirovo telo odgovora (ili kompaktan izvod, kod RHMZ-a), pa parsiranje
/// ostaje na servisu. Uz telo ide i timestamp, da UI može da kaže „podaci od 08:15".
/// Ključ za prognozu nosi zaokružene koordinate — isti kraj deli keš.
class ApiCache {
  static const _prefix = 'apicache:';

  /// ~1 km granularnost; dovoljno za prognozu, a ne pravi ključ po metru.
  static String coordKey(String tag, double lat, double lon) =>
      '$tag:${lat.toStringAsFixed(2)}:${lon.toStringAsFixed(2)}';

  static Future<void> put(String key, String body) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      '$_prefix$key',
      jsonEncode({'t': DateTime.now().millisecondsSinceEpoch, 'b': body}),
    );
  }

  /// Vraća keš samo ako nije stariji od [maxAge]. Prognoza starija od 3 dana
  /// je beskorisna (7-dnevni prozor je već istekao), pa se ne servira.
  static Future<CachedBody?> get(
    String key, {
    Duration maxAge = const Duration(days: 3),
  }) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.fromMillisecondsSinceEpoch(m['t'] as int);
      if (DateTime.now().difference(at) > maxAge) return null;
      return CachedBody(m['b'] as String, at);
    } catch (_) {
      return null;
    }
  }
}
