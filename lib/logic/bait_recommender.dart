import '../models/bait_product.dart';
import '../models/weather_data.dart';
import '../data/traper_baits.dart';

/// A recommended Traper combination tuned to live conditions:
/// a groundbait base (optionally mixed with a second groundbait at a ratio)
/// + optional pellet and additive, each with a short Serbian rationale.
class BaitCombo {
  final BaitProduct groundbait; // base
  final BaitProduct? secondGroundbait; // mixed into the base
  final String? mixRatio; // "60 : 40" (base : second)
  final BaitProduct? pellet;
  final BaitProduct? additive;
  final List<String> reasons;

  const BaitCombo({
    required this.groundbait,
    this.secondGroundbait,
    this.mixRatio,
    this.pellet,
    this.additive,
    required this.reasons,
  });

  List<BaitProduct> get all => [groundbait, ?secondGroundbait, ?pellet, ?additive];
}

/// Picks concrete Traper products to match the conditions-driven feeder plan.
///
/// Inputs: real/estimated water temp (band), turbidity, water type (river/lake),
/// river size (from discharge), and the active/target species. The 2-bait mix
/// ratio is a practical heuristic (base/binding vs species-pull role + temp +
/// river size) — Traper publishes no official ratios, so this is meant to be
/// refined as we gather more field data.
class BaitRecommender {
  /// [discharge] = river discharge in m³/s (river size proxy). Null for lakes.
  static BaitCombo? recommend({
    required double waterTempC,
    required WaterTurbidity turbidity,
    WaterBody? waterBody,
    String? targetSpecies,
    double? discharge,
  }) {
    final band = _band(waterTempC);
    final isLake = waterBody?.type == 'lake';
    final water = isLake ? 'lake' : 'river';
    final feeder = isLake ? 'method' : 'cage';
    final coloured =
        turbidity == WaterTurbidity.turbid || turbidity == WaterTurbidity.veryTurbid;
    final clear = turbidity == WaterTurbidity.clear;
    final bigRiver = !isLake && discharge != null && discharge >= 150;

    bool fishy(BaitProduct p) {
      final f = p.flavorColor.toLowerCase();
      return f.contains('ribl') || f.contains('halibut') || f.contains('protein') || f.contains('jak');
    }

    bool sweet(BaitProduct p) {
      final f = p.flavorColor.toLowerCase();
      return f.contains('slatk') ||
          f.contains('melasa') ||
          f.contains('jagoda') ||
          f.contains('marcipan') ||
          f.contains('tigrov') ||
          f.contains('vanil');
    }

    bool dark(BaitProduct p) {
      final f = p.flavorColor.toLowerCase();
      return f.contains('taman') || f.contains('tamn') || f.contains('crn') || f.contains('prirod');
    }

    // Base/primary score: water + feeder + band + clarity + (big-river binding).
    int baseScore(BaitProduct p) {
      var s = 0;
      if (p.waters.contains(water)) s += 4;
      if (p.feeders.contains(feeder)) s += 4;
      if (p.tempBands.contains(band)) s += 3;
      if (p.flagship) s += 1;
      if (coloured && fishy(p)) s += 2;
      if (clear && dark(p)) s += 2;
      final f = p.flavorColor.toLowerCase();
      if (bigRiver && (f.contains('teška') || f.contains('vezivanje') || f.contains('rečn'))) s += 3;
      return s;
    }

    BaitProduct? bestGroundbait() {
      final list = traperBaits.where((b) => b.category == BaitCategory.groundbait).toList()
        ..sort((a, b) => baseScore(b).compareTo(baseScore(a)));
      return list.isEmpty ? null : list.first;
    }

    final groundbait = bestGroundbait();
    if (groundbait == null) return null;

    // Second groundbait: a complementary mix-in. Prefers the target species the
    // base doesn't already cover; otherwise a flavour contrast to the base.
    BaitProduct? pickSecond() {
      final candidates = traperBaits
          .where((b) =>
              b.category == BaitCategory.groundbait &&
              b.id != groundbait.id &&
              (b.tempBands.contains(band) || band == BaitTempBand.warm))
          .toList();
      int secondScore(BaitProduct p) {
        var s = 0;
        // species pull the base lacks
        if (targetSpecies != null && p.species.contains(targetSpecies)) {
          s += 6;
          if (!groundbait.species.contains(targetSpecies)) s += 4;
        }
        // flavour contrast vs base
        if (fishy(groundbait) && sweet(p)) s += 3;
        if (sweet(groundbait) && fishy(p)) s += 3;
        if (coloured && fishy(p)) s += 2;
        if (clear && (sweet(p) || dark(p))) s += 1;
        return s;
      }

      candidates.sort((a, b) => secondScore(b).compareTo(secondScore(a)));
      if (candidates.isEmpty) return null;
      final top = candidates.first;
      // Only mix if the second actually adds something.
      return secondScore(top) >= 4 ? top : null;
    }

    final second = pickSecond();

    // Mix ratio (base : second) — base-dominant; colder/clearer ⇒ more base.
    String? ratio;
    if (second != null) {
      int baseShare;
      switch (band) {
        case BaitTempBand.cold:
          baseShare = 70;
        case BaitTempBand.cool:
          baseShare = 65;
        case BaitTempBand.mild:
          baseShare = 60;
        case BaitTempBand.warm:
          baseShare = isLake ? 50 : 60;
      }
      ratio = '$baseShare : ${100 - baseShare}';
    }

    // Complementary pellet (warmer water) + additive.
    int suppScore(BaitProduct p) {
      var s = 0;
      if (p.waters.contains(water)) s += 3;
      if (p.feeders.contains(feeder)) s += 3;
      if (p.tempBands.contains(band)) s += 2;
      if (targetSpecies != null && p.species.contains(targetSpecies)) s += 4;
      if (coloured && fishy(p)) s += 2;
      if (clear && sweet(p)) s += 1;
      return s;
    }

    BaitProduct? best(BaitCategory cat) {
      final list = traperBaits.where((b) => b.category == cat).toList()
        ..sort((a, b) => suppScore(b).compareTo(suppScore(a)));
      return list.isEmpty ? null : list.first;
    }

    final pellet = (band == BaitTempBand.mild || band == BaitTempBand.warm) ? best(BaitCategory.pellet) : null;
    final additive = best(BaitCategory.additive);

    // ── Reasons ──
    final reasons = <String>[];
    final riverLabel = isLake ? 'jezero' : (bigRiver ? 'velika reka' : 'manja reka');
    if (second != null && ratio != null) {
      reasons.add('$riverLabel + ${_bandLabel(band)} voda → miks ${groundbait.name} + ${second.name} u odnosu $ratio.');
      final pull = targetSpecies != null ? ' za ${_speciesLabel(targetSpecies)}.' : '.';
      reasons.add('${groundbait.name} je baza (struktura/voda), ${second.name} dodaje privlačnost$pull');
    } else {
      reasons.add(isLake
          ? 'Jezero + ${_bandLabel(band)} voda → ${groundbait.name} kao baza za method/flat feeder.'
          : '$riverLabel + ${_bandLabel(band)} voda → ${groundbait.name} kao baza za cage feeder.');
    }
    if (bigRiver) {
      reasons.add('Jak protok — drži tešku, dobro vezanu primamu da ostane u zoni.');
    }
    if (coloured) {
      reasons.add('Mutna voda — pojačaj jakim/ribljim mirisom i krupnijim česticama.');
    } else if (clear) {
      reasons.add('Bistra voda — tamna, fina primama i diskretan miris.');
    }
    if (targetSpecies != null) {
      reasons.add('Aktivna vrsta: ${_speciesLabel(targetSpecies)} — preporuka prilagođena toj ribi.');
    }
    if (pellet != null) reasons.add('Topla voda — dodaj ${pellet.name} za zadržavanje krupnije ribe.');
    if (additive != null) reasons.add('${additive.name} pojačava trag mirisa kroz vodu.');

    return BaitCombo(
      groundbait: groundbait,
      secondGroundbait: second,
      mixRatio: ratio,
      pellet: pellet,
      additive: additive,
      reasons: reasons,
    );
  }

  static BaitTempBand _band(double t) {
    if (t < 8) return BaitTempBand.cold;
    if (t < 14) return BaitTempBand.cool;
    if (t <= 20) return BaitTempBand.mild;
    return BaitTempBand.warm;
  }

  static String _bandLabel(BaitTempBand b) {
    switch (b) {
      case BaitTempBand.cold:
        return 'hladna';
      case BaitTempBand.cool:
        return 'sveža';
      case BaitTempBand.mild:
        return 'umerena';
      case BaitTempBand.warm:
        return 'topla';
    }
  }

  /// Maps a lowercase species tag to a Serbian display label.
  static String _speciesLabel(String tag) {
    switch (tag) {
      case 'saran':
        return 'šaran';
      case 'babuska':
        return 'babuška';
      case 'deverika':
        return 'deverika';
      case 'bodorka':
        return 'bodorka';
      case 'mrena':
        return 'mrena';
      case 'klen':
        return 'klen';
      case 'amur':
        return 'amur';
      case 'skobalj':
        return 'skobalj';
      default:
        return tag;
    }
  }
}
