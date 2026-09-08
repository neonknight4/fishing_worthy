/// Dva bitno različita plovkarenja na našim vodama.
enum FloatMode {
  /// Klasičan plovak — stajaća voda i spori tokovi, hranjeno mesto,
  /// waggler/bolonjez, deverika · bodorka · šaran · karaš.
  standard,

  /// Plovak na otpuštanje — rečno vođenje postavke niz maticu,
  /// šljunkoviti tereni, skobalj · mrena · plotica · klen. Trava (kladofora)
  /// je ovde glavni mamac.
  trotting,
}

extension FloatModeX on FloatMode {
  String get label => switch (this) {
        FloatMode.standard => 'Klasičan plovak',
        FloatMode.trotting => 'Na otpuštanje',
      };
}

/// Jedan način vođenja plovka niz vodu (samo za [FloatMode.trotting]).
class FloatGuide {
  final String name; // Štopovanje / Španovanje / Zadržavanje / Slobodno puštanje
  final String when; // kad se koristi
  final String how; // šta radiš štapom i kako je postavka olovljena

  const FloatGuide({required this.name, required this.when, required this.how});
}

/// Conditions-driven plan za plovkarenje.
class FloatPlan {
  final FloatMode mode;
  final String rod; // dužina i tip štapa
  final String floatType; // 'Waggler 3+2 g', 'Bolonjez 4–8 g'
  final String shotting; // raspored olova
  final String depth; // gde držati mamac
  final String hooklength; // predvez: dužina · debljina
  final String hookSize;
  final List<String> hookBaits;
  final String feeding; // šta i kojim ritmom (ili da se uopšte ne hrani)
  final List<String> targetFish;
  final List<String> notes;

  /// Načini vođenja — popunjeno samo za [FloatMode.trotting].
  final List<FloatGuide> guides;

  /// Ime vođenja koje danas prvo probati (iz [guides]), ili null.
  final String? recommendedGuide;

  const FloatPlan({
    required this.mode,
    required this.rod,
    required this.floatType,
    required this.shotting,
    required this.depth,
    required this.hooklength,
    required this.hookSize,
    required this.hookBaits,
    required this.feeding,
    required this.targetFish,
    required this.notes,
    this.guides = const [],
    this.recommendedGuide,
  });
}
