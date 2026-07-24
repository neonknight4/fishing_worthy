import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'diary_list_screen.dart';
import 'regulations_screen.dart';

/// Root okvir sa donjom navigacijom: Početna · Mapa · Dnevnik · Propisi.
/// Detaljni ekrani (Rezultat, Lista voda, Unos) se i dalje `push`-uju preko.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Podrazumevani centar (Beograd) za Mapu kad korisnik nije birao lokaciju.
  static const _defLat = 44.7866, _defLon = 20.4489;

  static const _nav = [
    (Icons.home_outlined, Icons.home, 'Početna'),
    (Icons.map_outlined, Icons.map, 'Mapa'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Dnevnik'),
    (Icons.gavel_outlined, Icons.gavel, 'Propisi'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          MapScreen(latitude: _defLat, longitude: _defLon, locationName: 'Srbija', showBack: false),
          DiaryListScreen(showBack: false),
          RegulationsScreen(showBack: false),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: List.generate(_nav.length, (i) {
                final on = i == _index;
                final item = _nav[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(on ? item.$2 : item.$1, size: 23, color: on ? c.green : c.faint),
                          const SizedBox(height: 3),
                          Text(item.$3,
                              style: context.ui(
                                  size: 10.5, weight: FontWeight.w700, color: on ? c.green : c.faint)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
