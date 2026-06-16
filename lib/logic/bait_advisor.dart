import '../models/feeder_plan.dart';
import '../models/weather_data.dart';

/// Builds a feeder/method plan from live conditions.
/// Rules synthesised from match-pro sources (Preston/Guru/Dynamite/Angling Times)
/// and the Balkan big-river context — see docs/UPGRADE_IDEAS.md §2, §4.
class BaitAdvisor {
  /// [waterTempC] should be the real RHMZ temp when available, else estimate.
  static FeederPlan plan({
    required double waterTempC,
    required WaterTurbidity turbidity,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
    required double windSpeed,
  }) {
    final isLake = waterBody?.type == 'lake';
    final band = _tempBand(waterTempC);
    final notes = <String>[];

    // ── Hook baits + groundbait + feed amount by temperature band ──
    final List<String> baits;
    final String groundbait;
    final String feedAmount;
    switch (band) {
      case _Band.cold:
        baits = isLake
            ? ['Mrtav crv', 'Wafter 5mm', 'Zrno kukuruza']
            : ['Crv', 'Kaster', 'Mikropelet 2mm', 'Zrno kukuruza'];
        groundbait = 'Tamna, fina, low-feed primama (umešena suvlje). Primama:pelet ≈ 80:20';
        feedAmount = 'Minimalno — ne prehrani jato';
      case _Band.cool:
        baits = ['Crv', 'Kaster', 'Pelet', 'Kukuruz'];
        groundbait = 'Slatka braon primama, umereno. Primama:pelet ≈ 70:30';
        feedAmount = 'Umereno, gradi polako';
      case _Band.mild:
        baits = isLake
            ? ['Wafter 8mm', 'Banded pelet', 'Kukuruz', 'Crv']
            : ['Kukuruz', 'Pelet 6mm', 'Boila', 'Crv'];
        groundbait = 'Primama + partikl (konoplja, kukuruz). Primama:pelet ≈ 50:50';
        feedAmount = 'Izdašno';
      case _Band.warm:
        baits = isLake
            ? ['Wafter 8–10mm', 'Banded pelet', 'Boila', 'Kukuruz']
            : ['Halibut pelet 10–16mm', 'Meso', 'Boila', 'Kukuruz'];
        groundbait = 'Pelet-vođeno; primama za brzo privlačenje. Više hrane';
        feedAmount = 'Obilno i često';
    }

    // ── Feeder type + weight ──
    final String feederType;
    final String feederWeight;
    if (isLake) {
      feederType = 'Method / flat method';
      feederWeight = band == _Band.cold ? '20–30 g' : '25–40 g';
      notes.add('Method radi do ~1.8 m dubine — dublje koristi cage feeder ili PVA.');
    } else {
      final trend = waterLevel?.trend;
      if (trend == WaterLevelTrend.largeRise) {
        feederType = 'Teški inline / open-end';
        feederWeight = '80–150 g';
        notes.add('Velika/mutna voda — drži tešku hranilicu uz inside liniju i slakove.');
      } else if (trend == WaterLevelTrend.slightRise || windSpeed > 25) {
        feederType = 'Cage feeder';
        feederWeight = '50–80 g';
      } else {
        feederType = 'Cage → window';
        feederWeight = '30–60 g';
        notes.add('Privuci cage-om; pređi na window kad riba digne sa dna.');
      }
    }

    // ── Hooklength (length · diameter) + hook size ──
    final clear = turbidity == WaterTurbidity.clear;
    final coloured = turbidity == WaterTurbidity.turbid ||
        turbidity == WaterTurbidity.veryTurbid;
    final String hooklength;
    final String hookSize;
    if (isLake) {
      final cold = band == _Band.cold;
      hooklength = cold ? '8 cm (3") · 0.15 mm' : '10 cm (4") · 0.18–0.22 mm';
      hookSize = cold ? '14–16' : '10–12';
    } else {
      if (band == _Band.cold || clear) {
        hooklength = '45–60 cm · 0.12–0.15 mm';
        hookSize = '14–16';
      } else if (coloured || waterLevel?.trend == WaterLevelTrend.slightRise) {
        hooklength = '25–30 cm · 0.18–0.20 mm';
        hookSize = band == _Band.warm ? '12–14' : '14';
      } else {
        hooklength = '30–45 cm · 0.16 mm';
        hookSize = '12–14';
      }
    }

    // ── Casting cadence ──
    final cadence = (band == _Band.cold || band == _Band.cool)
        ? 'svakih 8–15 min'
        : 'svakih 4–6 min';

    // ── Turbidity / clarity notes ──
    if (coloured) {
      notes.add('Mutna voda — jači miris i svetliji/krupniji mamac, kraći podvez OK.');
    } else if (clear) {
      notes.add('Bistra voda — prirodne boje, tamna low-feed primama, duži i finiji podvez.');
    }

    return FeederPlan(
      feederType: feederType,
      feederWeight: feederWeight,
      hooklength: hooklength,
      hookSize: hookSize,
      cadence: cadence,
      hookBaits: baits,
      groundbait: groundbait,
      feedAmount: feedAmount,
      notes: notes,
    );
  }

  static _Band _tempBand(double t) {
    if (t < 8) return _Band.cold;
    if (t < 14) return _Band.cool;
    if (t <= 20) return _Band.mild;
    return _Band.warm;
  }
}

enum _Band { cold, cool, mild, warm }
