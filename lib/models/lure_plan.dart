/// Klasa pribora za varaličarenje.
/// Granice su praksa na srpskim vodama (vidi docs/research/2026-09-07-varalicarenje-research.md),
/// šire od američke podele gde je UL 0.9–3.5 g.
enum LureClass { ul, classic, heavy }

extension LureClassX on LureClass {
  String get label => switch (this) {
        LureClass.ul => 'Ultra light',
        LureClass.classic => 'Klasik',
        LureClass.heavy => 'Teško',
      };

  String get castRange => switch (this) {
        LureClass.ul => '1–10 g',
        LureClass.classic => '10–40 g',
        LureClass.heavy => '40 g+',
      };
}

/// Jedna preporučena varalica u planu.
class LurePick {
  final String type; // 'Shad na jig glavi', 'Suspending mino', 'Kašika'…
  final String size; // '8–10 cm · 14–21 g glava'
  final String detail; // kako je voditi / kad je koristiti

  const LurePick({required this.type, required this.size, required this.detail});
}

/// Conditions-driven plan za varaličarenje.
class LurePlan {
  final LureClass lureClass;
  final List<String> targetFish;
  final List<LurePick> lures;
  final String colors;
  final String retrieve;
  final String depth;
  final String line;
  final List<String> spots; // gde tražiti ribu na ovakvoj vodi
  final List<String> notes;

  /// Kratak red o drugoj klasi pribora koja danas takođe ima smisla (ili null).
  final String? alternative;

  const LurePlan({
    required this.lureClass,
    required this.targetFish,
    required this.lures,
    required this.colors,
    required this.retrieve,
    required this.depth,
    required this.line,
    required this.spots,
    required this.notes,
    this.alternative,
  });
}
