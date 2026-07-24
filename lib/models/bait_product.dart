/// A single Traper product in the branded catalog (groundbait, pellet,
/// additive or particle). Used by the bait recommender to suggest concrete
/// products tuned to live conditions.
enum BaitCategory { groundbait, pellet, additive, partikl }

/// Coarse water-temperature bands — mirror BaitAdvisor's internal bands so the
/// recommender can align product picks with the conditions-driven feeder plan.
enum BaitTempBand { cold, cool, mild, warm }

class BaitProduct {
  final String id; // stable slug, also the asset basename
  final String name; // exact product name as sold
  final String line; // Traper series (Sekret, Expert, Champion, ...)
  final BaitCategory category;
  final String imageAsset; // assets/bait/<id>.<ext>
  final String flavorColor; // "slatka, tamno braon" / "halibut/riba"
  final String shortDesc; // one-line: what it is / when to use
  final String? productUrl; // official Traper page

  /// Tags the recommender scores against.
  final Set<String> species; // 'deverika','mrena','skobalj','klen','bodorka','saran','amur','babuska'
  final Set<String> waters; // 'river','lake'
  final Set<String> feeders; // 'cage','method'
  final Set<BaitTempBand> tempBands; // bands where this shines

  final bool flagship; // best-seller / hero product for the pitch

  const BaitProduct({
    required this.id,
    required this.name,
    required this.line,
    required this.category,
    required this.imageAsset,
    required this.flavorColor,
    required this.shortDesc,
    this.productUrl,
    required this.species,
    required this.waters,
    required this.feeders,
    required this.tempBands,
    this.flagship = false,
  });
}
