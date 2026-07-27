/// Komercijalni (plaćeni/privatni) method/šaranski revir.
/// Poseban tip vode; podaci u `assets/data/commercial_lakes.json`.
class CommercialLake {
  final String name;
  final String city;
  final double lat;
  final double lon;
  final List<String> species;
  final bool method; // da li je method/feeder dozvoljen
  final String? permit; // cena dozvole (slobodan tekst, npr "1.500 RSD/12h")
  final String? hours;
  final String? rules;
  final String? contact;
  final String? link;
  final bool approxCoords; // koordinate su procena, ne tačne
  final String confidence; // 'verified' | 'single' | 'unsure'

  const CommercialLake({
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
    this.species = const [],
    this.method = true,
    this.permit,
    this.hours,
    this.rules,
    this.contact,
    this.link,
    this.approxCoords = false,
    this.confidence = 'single',
  });

  factory CommercialLake.fromJson(Map<String, dynamic> j) => CommercialLake(
        name: j['name'] as String,
        city: (j['city'] ?? '') as String,
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        species: (j['species'] as List?)?.cast<String>() ?? const [],
        method: (j['method'] ?? true) as bool,
        permit: j['permit'] as String?,
        hours: j['hours'] as String?,
        rules: j['rules'] as String?,
        contact: j['contact'] as String?,
        link: j['link'] as String?,
        approxCoords: (j['approxCoords'] ?? false) as bool,
        confidence: (j['confidence'] ?? 'single') as String,
      );
}
