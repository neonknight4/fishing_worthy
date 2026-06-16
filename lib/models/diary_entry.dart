import 'dart:convert';

/// A single catch line within a diary entry.
class CatchItem {
  final String species;
  final int count;
  final double? maxWeightKg;
  final double? maxLengthCm;

  const CatchItem({
    required this.species,
    required this.count,
    this.maxWeightKg,
    this.maxLengthCm,
  });

  Map<String, dynamic> toJson() => {
        's': species,
        'c': count,
        if (maxWeightKg != null) 'w': maxWeightKg,
        if (maxLengthCm != null) 'l': maxLengthCm,
      };

  factory CatchItem.fromJson(Map<String, dynamic> j) => CatchItem(
        species: j['s'] as String,
        count: (j['c'] as num).toInt(),
        maxWeightKg: (j['w'] as num?)?.toDouble(),
        maxLengthCm: (j['l'] as num?)?.toDouble(),
      );
}

class DiaryEntry {
  final int? id;
  final DateTime date;
  final String location;
  final String? water;
  final double? lat, lon;
  // Auto-captured conditions
  final double? airTemp, pressure, windSpeed;
  final double? waterTempReal; // real RHMZ temp at logging time
  final String? waterTrend;
  final double? moonPhase;
  // User input
  final String? technique, bait, notes;
  final List<CatchItem> catches;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.location,
    this.water,
    this.lat,
    this.lon,
    this.airTemp,
    this.pressure,
    this.windSpeed,
    this.waterTempReal,
    this.waterTrend,
    this.moonPhase,
    this.technique,
    this.bait,
    this.notes,
    this.catches = const [],
  });

  int get totalCatch => catches.fold(0, (s, c) => s + c.count);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'location': location,
        'water': water,
        'lat': lat,
        'lon': lon,
        'air_temp': airTemp,
        'pressure': pressure,
        'wind': windSpeed,
        'water_temp': waterTempReal,
        'water_trend': waterTrend,
        'moon_phase': moonPhase,
        'technique': technique,
        'bait': bait,
        'notes': notes,
        'catches': jsonEncode(catches.map((c) => c.toJson()).toList()),
        'created_at': date.millisecondsSinceEpoch,
      };

  factory DiaryEntry.fromMap(Map<String, dynamic> m) {
    final rawCatches = (m['catches'] as String?) ?? '[]';
    final list = (jsonDecode(rawCatches) as List)
        .map((e) => CatchItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return DiaryEntry(
      id: m['id'] as int?,
      date: DateTime.parse(m['date'] as String),
      location: m['location'] as String,
      water: m['water'] as String?,
      lat: (m['lat'] as num?)?.toDouble(),
      lon: (m['lon'] as num?)?.toDouble(),
      airTemp: (m['air_temp'] as num?)?.toDouble(),
      pressure: (m['pressure'] as num?)?.toDouble(),
      windSpeed: (m['wind'] as num?)?.toDouble(),
      waterTempReal: (m['water_temp'] as num?)?.toDouble(),
      waterTrend: m['water_trend'] as String?,
      moonPhase: (m['moon_phase'] as num?)?.toDouble(),
      technique: m['technique'] as String?,
      bait: m['bait'] as String?,
      notes: m['notes'] as String?,
      catches: list,
    );
  }

  DiaryEntry copyWith({
    int? id,
    List<CatchItem>? catches,
    String? technique,
    String? bait,
    String? notes,
  }) =>
      DiaryEntry(
        id: id ?? this.id,
        date: date,
        location: location,
        water: water,
        lat: lat,
        lon: lon,
        airTemp: airTemp,
        pressure: pressure,
        windSpeed: windSpeed,
        waterTempReal: waterTempReal,
        waterTrend: waterTrend,
        moonPhase: moonPhase,
        technique: technique ?? this.technique,
        bait: bait ?? this.bait,
        notes: notes ?? this.notes,
        catches: catches ?? this.catches,
      );
}
