import 'fishing_score.dart';

enum TechniqueType { feeder, spinning, float }

class TechniqueScore {
  final TechniqueType type;
  final int score;
  final FishingRating rating;
  final List<String> targetFish;

  /// Razlozi izvedeni iz sub-skorova BAŠ ove tehnike — isti faktor može biti
  /// plus za jednu, a minus za drugu (npr. mutna voda: feeder da, varalica ne).
  final List<String> positives;
  final List<String> negatives;

  const TechniqueScore({
    required this.type,
    required this.score,
    required this.rating,
    required this.targetFish,
    this.positives = const [],
    this.negatives = const [],
  });

  String get name {
    switch (type) {
      case TechniqueType.feeder:
        return 'Feeder';
      case TechniqueType.spinning:
        return 'Varaličarenje';
      case TechniqueType.float:
        return 'Plovkarenje';
    }
  }

  /// Fotografija pribora — glavna ikonica tehnike.
  String get iconAsset {
    switch (type) {
      case TechniqueType.feeder:
        return 'assets/icons/tech_feeder.png';
      case TechniqueType.spinning:
        return 'assets/icons/tech_varalica.png';
      case TechniqueType.float:
        return 'assets/icons/tech_plovak.png';
    }
  }

  /// Fallback ako asset ne uspe da se učita.
  String get icon {
    switch (type) {
      case TechniqueType.feeder:
        return '🎯';
      case TechniqueType.spinning:
        return '🌀';
      case TechniqueType.float:
        return '🪄';
    }
  }
}

class SeasonalFish {
  final String name;
  final String emoji;
  final String technique;

  const SeasonalFish({
    required this.name,
    required this.emoji,
    required this.technique,
  });
}
