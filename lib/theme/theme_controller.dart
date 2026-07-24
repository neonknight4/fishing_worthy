import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drži izabranu temu (system/light/dark) i pamti je u shared_preferences.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_key)) {
      case 'light':
        _mode = ThemeMode.light;
      case 'dark':
        _mode = ThemeMode.dark;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  bool isDark(BuildContext context) => _mode == ThemeMode.dark ||
      (_mode == ThemeMode.system &&
          MediaQuery.platformBrightnessOf(context) == Brightness.dark);

  /// Toggle svetlo↔tamno (uzima trenutni efektivni prikaz kao osnov).
  Future<void> toggle(BuildContext context) async {
    _mode = isDark(context) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

/// Globalna instanca (app je jednostavan, nema DI kontejner).
final themeController = ThemeController();
