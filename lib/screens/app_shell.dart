import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/nav_icons.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'method_screen.dart';
import 'traper_screen.dart';
import 'diary_list_screen.dart';

/// Root okvir sa donjom navigacijom: Početna · Mapa · Method · Traper · Dnevnik.
/// Propisi + detaljni ekrani (Rezultat, Lista voda, Unos) se `push`-uju preko.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Podrazumevani centar (Beograd) za Mapu kad korisnik nije birao lokaciju.
  static const _defLat = 44.7866, _defLon = 20.4489;

  static const _labels = ['Početna', 'Mapa', 'Method', 'Traper', 'Dnevnik'];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          MapScreen(latitude: _defLat, longitude: _defLon, locationName: 'Srbija', showBack: false),
          MethodScreen(),
          TraperScreen(),
          DiaryListScreen(showBack: false),
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
              children: List.generate(_labels.length, (i) {
                final on = i == _index;
                final tint = on ? c.green : c.faint;
                final ico = navIcons[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(
                            on ? ico.filled : ico.outline,
                            width: 23,
                            height: 23,
                            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                          ),
                          const SizedBox(height: 3),
                          Text(_labels[i],
                              style: context.ui(size: 10.5, weight: FontWeight.w700, color: tint)),
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
