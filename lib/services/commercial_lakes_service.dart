import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/commercial_lake.dart';

/// Učitava komercijalne revire iz bundlovanog JSON-a.
class CommercialLakesService {
  static const _asset = 'assets/data/commercial_lakes.json';
  List<CommercialLake>? _cache;

  Future<List<CommercialLake>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_asset);
    final list = (jsonDecode(raw) as List)
        .map((e) => CommercialLake.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }
}
