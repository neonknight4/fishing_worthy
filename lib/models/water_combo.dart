import 'bait_product.dart';
import '../data/traper_baits.dart';

/// Godišnja doba koja menjaju izbor primame/mixa.
enum Season { prolece, leto, jesen, zima }

/// Procenjena aktivnost ribe — modifikator količine/finoće hranjenja,
/// ne zaseban recept (vidi [activityMod]).
enum FishActivity { niska, umerena, visoka }

/// Kuriran Traper combo (recept) za konkretnu vodu + sezonu.
///
/// Combo bira baznu hranu (+ opcioni miks, pelet, aditive, hookbait) iz
/// `traperBaits` po `id`-ju. Aktivnost ribe se primenjuje kao modifikator
/// preko [activityMod] (manje/finije kad je riba pasivna, više/krupnije kad
/// je aktivna), pa je broj kuriranih combo-a = vode × sezone (ne × aktivnost).
class WaterCombo {
  final String waterName; // poklapa se sa serbia_waters.json 'n'
  final String waterType; // 'river' | 'lake'
  final Season season;
  final Set<String> species; // ciljne vrste za ovaj combo

  // ── Recept (reference na traperBaits.id) ──
  final String baseFoodId; // bazna primama
  final String? secondFoodId; // miks-in primama
  final String? mixRatio; // "70 : 30" (baza : drugo)
  final String? pelletId;
  final List<String> additiveIds;
  final String? hookbait; // mamac na udici (slobodan tekst)

  final String prep; // priprema smeše (voda:smesa, odmaranje, seckanje)
  final String loading; // početno punjenje + dopuna ritam

  const WaterCombo({
    required this.waterName,
    required this.waterType,
    required this.season,
    required this.species,
    required this.baseFoodId,
    this.secondFoodId,
    this.mixRatio,
    this.pelletId,
    this.additiveIds = const [],
    this.hookbait,
    required this.prep,
    required this.loading,
  });

  BaitProduct get base => baitById(baseFoodId)!;
  BaitProduct? get second => secondFoodId == null ? null : baitById(secondFoodId!);
  BaitProduct? get pellet => pelletId == null ? null : baitById(pelletId!);
  List<BaitProduct> get additives =>
      additiveIds.map(baitById).whereType<BaitProduct>().toList();

  /// Svi proizvodi u receptu (za prikaz + m-fishing linkove).
  List<BaitProduct> get products =>
      [base, ?second, ?pellet, ...additives];
}

/// Kako aktivnost ribe menja primenu recepta (isto za sve combo-e).
/// Prikaz ide uz combo; ne pravi nove unose.
String activityMod(FishActivity a) {
  switch (a) {
    case FishActivity.niska:
      return 'Pasivna riba: ~30% manje smeše, finije mlevenje, ređe punjenje, '
          'lakši aditiv. Mamac sitniji i diskretniji.';
    case FishActivity.umerena:
      return 'Standardno punjenje i konzistencija po receptu.';
    case FishActivity.visoka:
      return 'Aktivna riba: dodaj pelet/partikl, krupnije čestice, češće '
          'punjenje, jači aditiv/aroma.';
  }
}

String seasonLabel(Season s) {
  switch (s) {
    case Season.prolece:
      return 'Proleće';
    case Season.leto:
      return 'Leto';
    case Season.jesen:
      return 'Jesen';
    case Season.zima:
      return 'Zima';
  }
}
