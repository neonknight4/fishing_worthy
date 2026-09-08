import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Otvaranje m-fishing linkova iz app-a.
///
/// Sve prolazi kroz jedno mesto da bi svaki klik nosio UTM oznake — bez njih
/// m-fishing ne može da vidi koliko prometa dolazi iz app-a, a to je jedini
/// merljiv argument za deal.
///
/// Ako je stranica proizvoda uklonjena (404/410), vodi na prodavnicu.
class ShopLink {
  static const _shopFallback = 'https://www.m-fishing.rs/shop/';
  static const _source = 'upecaj';
  static const _medium = 'app';
  static const _campaign = 'traper';

  /// Dodaje UTM na postojeći query (ne gazi ga). [placement] je mesto klika
  /// u app-u — npr. `katalog`, `recept`.
  static Uri tag(String url, String placement) {
    final u = Uri.parse(url);
    return u.replace(queryParameters: {
      ...u.queryParameters,
      'utm_source': _source,
      'utm_medium': _medium,
      'utm_campaign': _campaign,
      'utm_content': placement,
    });
  }

  /// Otvara stranicu proizvoda u browseru. Na 404/410 pada na `/shop/`;
  /// mreža/timeout ostavlja originalni link (možda samo nema signala).
  static Future<void> open(String? url, {required String placement}) async {
    if (url == null) return;
    var target = tag(url, placement);
    try {
      final resp = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 404 || resp.statusCode == 410) {
        target = tag(_shopFallback, '$placement-fallback');
      }
    } catch (_) {
      // Mreža/timeout/HEAD nedozvoljen — probaj originalni link.
    }
    await launchUrl(target, mode: LaunchMode.externalApplication);
  }
}
