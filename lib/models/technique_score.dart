import 'fishing_score.dart';

enum TechniqueType { feeder, spinning, float }

class TechniqueScore {
  final TechniqueType type;
  final int score;
  final FishingRating rating;
  final List<String> targetFish;

  const TechniqueScore({
    required this.type,
    required this.score,
    required this.rating,
    required this.targetFish,
  });

  String get name {
    switch (type) {
      case TechniqueType.feeder:
        return 'Feeder';
      case TechniqueType.spinning:
        return 'Varalicarenje';
      case TechniqueType.float:
        return 'Plovak';
    }
  }

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
