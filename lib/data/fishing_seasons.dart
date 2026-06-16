// Source: Serbian fishing law & RIPS regulations 2026
// Dates may vary slightly by water body — verify with local fishing association

class ClosedSeason {
  final String species;
  final int fromMonth, fromDay, toMonth, toDay;
  final int? minSizeCm;

  const ClosedSeason({
    required this.species,
    required this.fromMonth,
    required this.fromDay,
    required this.toMonth,
    required this.toDay,
    this.minSizeCm,
  });

  bool isClosedOn(DateTime date) {
    final md = date.month * 100 + date.day;
    final from = fromMonth * 100 + fromDay;
    final to = toMonth * 100 + toDay;
    if (from <= to) return md >= from && md <= to;
    return md >= from || md <= to;
  }

  String get dateRange => '$fromDay.$fromMonth. – $toDay.$toMonth.';
}

const fishingClosedSeasons = [
  ClosedSeason(species: 'Štuka', fromMonth: 2, fromDay: 1, toMonth: 3, toDay: 31, minSizeCm: 40),
  ClosedSeason(species: 'Smuđ', fromMonth: 3, fromDay: 1, toMonth: 4, toDay: 30, minSizeCm: 40),
  ClosedSeason(species: 'Smuđ kamenjar', fromMonth: 3, fromDay: 1, toMonth: 4, toDay: 30, minSizeCm: 25),
  ClosedSeason(species: 'Šaran', fromMonth: 4, fromDay: 1, toMonth: 5, toDay: 31, minSizeCm: 30),
  ClosedSeason(species: 'Mrena', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 25),
  ClosedSeason(species: 'Plotica / Klen', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  ClosedSeason(species: 'Deverika / Jaz', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  ClosedSeason(species: 'Skobalj', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  ClosedSeason(species: 'Bucov', fromMonth: 4, fromDay: 15, toMonth: 6, toDay: 15, minSizeCm: 30),
  ClosedSeason(species: 'Som', fromMonth: 5, fromDay: 1, toMonth: 6, toDay: 15, minSizeCm: 60),
];

// Minimum sizes only (no closed season)
const minSizeOnly = [
  (species: 'Som', cm: 60),
  (species: 'Rečna školjka', cm: 8),
  (species: 'Bandar / Krkuša', cm: 10),
  (species: 'Šljivar', cm: 15),
  (species: 'Potočna mrena', cm: 15),
  (species: 'Manić', cm: 25),
];

// Permanently banned — never fish these
const permanentlyBanned = [
  'Kečiga i jeseterske vrste',
  'Zlatni karaš',
  'Linjak',
  'Čikov',
  'Jegulja',
  'Mali i veliki vretenar',
  'Belka',
  'Crnka',
  'Rečni rak',
  'Pegunica',
  'Vijunica',
  'Belonijev balavac',
  'Istočna mrena',
];

// No restrictions
const noRestrictions = [
  'Američki somić', 'Tolstolobik', 'Amur', 'Bas', 'Babuška', 'Sunčica', 'Američki rak',
];

// ── Per-fish regulations (only species we have icons for) ────────────────────

class FishReg {
  final String name;
  final int? fromMonth, fromDay, toMonth, toDay; // null = no closed season
  final int? minSizeCm;
  final String? note;

  const FishReg({
    required this.name,
    this.fromMonth,
    this.fromDay,
    this.toMonth,
    this.toDay,
    this.minSizeCm,
    this.note,
  });

  bool get hasClosedSeason => fromMonth != null;

  bool isClosedOn(DateTime date) {
    if (!hasClosedSeason) return false;
    final md = date.month * 100 + date.day;
    final from = fromMonth! * 100 + fromDay!;
    final to = toMonth! * 100 + toDay!;
    if (from <= to) return md >= from && md <= to;
    return md >= from || md <= to;
  }

  String? get dateRange =>
      hasClosedSeason ? '$fromDay.$fromMonth. – $toDay.$toMonth.' : null;
}

const iconFishRegulations = [
  FishReg(name: 'Som', fromMonth: 5, fromDay: 1, toMonth: 6, toDay: 15, minSizeCm: 60),
  FishReg(name: 'Smuđ', fromMonth: 3, fromDay: 1, toMonth: 4, toDay: 30, minSizeCm: 40),
  FishReg(name: 'Šaran', fromMonth: 4, fromDay: 1, toMonth: 5, toDay: 31, minSizeCm: 30),
  FishReg(name: 'Štuka', fromMonth: 2, fromDay: 1, toMonth: 3, toDay: 31, minSizeCm: 40),
  FishReg(name: 'Mrena', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 25),
  FishReg(name: 'Skobalj', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  FishReg(name: 'Klen', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  FishReg(name: 'Plotica', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  FishReg(name: 'Deverika', fromMonth: 4, fromDay: 15, toMonth: 5, toDay: 31, minSizeCm: 20),
  FishReg(name: 'Bucov', fromMonth: 4, fromDay: 15, toMonth: 6, toDay: 15, minSizeCm: 30),
  FishReg(name: 'Amur', note: 'Bez lovostaja'),
  FishReg(name: 'Bodorka', note: 'Bez lovostaja'),
  FishReg(name: 'Babuška', note: 'Invazivna — slobodan izlov, bez ograničenja'),
];

// ── Protected areas ──────────────────────────────────────────────────────────

class ProtectedArea {
  final String name;
  final int permitPrice;
  final List<String> keywords;

  const ProtectedArea({
    required this.name,
    required this.permitPrice,
    required this.keywords,
  });

  bool matches(String? text) {
    if (text == null || text.isEmpty) return false;
    final lower = text.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }
}

const protectedAreas = [
  ProtectedArea(name: 'Sićevačka klisura', permitPrice: 3000, keywords: ['sićevačka', 'sicevacka', 'sićevo']),
  ProtectedArea(name: 'Rezervat Jerma', permitPrice: 3000, keywords: ['jerma']),
  ProtectedArea(name: 'Karaš-Nera', permitPrice: 3000, keywords: ['karaš', 'karas', 'nera']),
  ProtectedArea(name: 'Park prirode Zlatibor', permitPrice: 3500, keywords: ['zlatibor']),
  ProtectedArea(name: 'Begečka jama', permitPrice: 4000, keywords: ['begečka', 'begecka']),
  ProtectedArea(name: 'Jegrička', permitPrice: 4000, keywords: ['jegrička', 'jegricka']),
  ProtectedArea(name: 'Beljanska bara', permitPrice: 4000, keywords: ['beljanska']),
  ProtectedArea(name: 'Palić', permitPrice: 4500, keywords: ['palić', 'palic']),
  ProtectedArea(name: 'Ludaško jezero', permitPrice: 4500, keywords: ['ludaško', 'ludas']),
  ProtectedArea(name: 'Vlasina', permitPrice: 5000, keywords: ['vlasina']),
  ProtectedArea(name: 'Carska bara', permitPrice: 5000, keywords: ['carska bara', 'carska']),
  ProtectedArea(name: 'Tikvara', permitPrice: 5000, keywords: ['tikvara']),
  ProtectedArea(name: 'Labudovo okno', permitPrice: 6000, keywords: ['labudovo']),
  ProtectedArea(name: 'Karađorđevo', permitPrice: 6000, keywords: ['karađorđevo', 'karadjordevo']),
  ProtectedArea(name: 'Mali Bosut', permitPrice: 6000, keywords: ['bosut']),
  ProtectedArea(name: 'Stara Tisa / Biserno ostrvo', permitPrice: 6500, keywords: ['biserno', 'stara tisa']),
  ProtectedArea(name: 'Đerdap', permitPrice: 7000, keywords: ['đerdap', 'djerdap']),
  ProtectedArea(name: 'Uvac', permitPrice: 7000, keywords: ['uvac']),
  ProtectedArea(name: 'Obedska bara', permitPrice: 7000, keywords: ['obedska']),
  ProtectedArea(name: 'Gornje Podunavlje', permitPrice: 7000, keywords: ['podunavlje']),
  ProtectedArea(name: 'Stara planina', permitPrice: 7000, keywords: ['stara planina', 'temštica', 'visočica']),
  ProtectedArea(name: 'Klisura reke Gradac', permitPrice: 10000, keywords: ['gradac']),
];

ProtectedArea? matchProtectedArea(String? waterBodyName, String? locationName) {
  for (final area in protectedAreas) {
    if (area.matches(waterBodyName) || area.matches(locationName)) return area;
  }
  return null;
}
