import 'package:shared_preferences/shared_preferences.dart';

/// Pamti koje su sekcije sklopljene. Korisnik sklopi npr. solunar jednom i
/// ostaje sklopljen na svakom sledećem otvaranju ekrana.
///
/// Vrednosti se učitaju jednom u `main()` i drže u memoriji, pa `Collapsible`
/// može da ih pročita SINHRONO pri gradnji. Async čitanje bi dalo treperenje —
/// sekcija bi se prvo iscrtala otvorena pa se sklopila.
class SectionPrefs {
  static const _prefix = 'section_open:';
  static final Map<String, bool> _open = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    for (final k in p.getKeys()) {
      if (k.startsWith(_prefix)) {
        final v = p.getBool(k);
        if (v != null) _open[k.substring(_prefix.length)] = v;
      }
    }
    _loaded = true;
  }

  /// `fallback` je podrazumevano stanje dok korisnik ništa nije dirao.
  static bool isOpen(String key, bool fallback) => _open[key] ?? fallback;

  static Future<void> setOpen(String key, bool value) async {
    _open[key] = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool('$_prefix$key', value);
  }
}
