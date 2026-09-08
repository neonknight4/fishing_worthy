import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bumpuje se kad lekcija bude pročitana — lista u tabu je živa u IndexedStack-u
/// pa se ne rebuild-uje sama.
final schoolProgressRevision = ValueNotifier<int>(0);

/// Koje su lekcije pročitane. Beleži se kad korisnik stigne do dna lekcije,
/// ne na otvaranje — „pročitano" posle jednog tapa bila bi laž.
class SchoolProgressService {
  static const _key = 'school_read_lessons';

  static Future<Set<String>> read() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_key) ?? const []).toSet();
  }

  static Future<void> markRead(String id) async {
    final p = await SharedPreferences.getInstance();
    final ids = (p.getStringList(_key) ?? const <String>[]).toSet();
    if (ids.add(id)) {
      await p.setStringList(_key, ids.toList());
      schoolProgressRevision.value++;
    }
  }
}
