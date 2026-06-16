/// Conditions-driven feeder/method plan (bait + groundbait + rig + cadence).
class FeederPlan {
  final String feederType; // Cage / Window / Open-end / Method / Flat method
  final String feederWeight; // "30–60g"
  final String hooklength; // "30–45 cm · 0.16 mm"
  final String hookSize; // "12–14"
  final String cadence; // "svakih 4–6 min"
  final List<String> hookBaits; // ["Kukuruz", "Pelet 6mm"]
  final String groundbait; // mix + GB:pelet ratio
  final String feedAmount; // "Izdašno" / "Minimalno"
  final List<String> notes; // contextual notes

  const FeederPlan({
    required this.feederType,
    required this.feederWeight,
    required this.hooklength,
    required this.hookSize,
    required this.cadence,
    required this.hookBaits,
    required this.groundbait,
    required this.feedAmount,
    required this.notes,
  });
}
