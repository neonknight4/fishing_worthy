import 'package:flutter/material.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
import '../services/favorites_service.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'result_screen.dart';

/// Omiljene vode — sačuvane preko flag-a na Result ekranu.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favService = FavoritesService();
  final _weatherService = WeatherService();
  final _waterService = WaterService();
  List<LocationInfo> _favs = [];
  bool _loading = true;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _favService.load();
    if (mounted) setState(() { _favs = list; _loading = false; });
  }

  Future<void> _open(LocationInfo loc) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final forecasts = await _weatherService.fetchForecast(loc.latitude, loc.longitude);
      if (forecasts.isEmpty) return;
      final wl = await _waterService
          .fetchWaterLevelForecast(loc.latitude, loc.longitude, waterBodyName: loc.name)
          .catchError((_) => null);
      final score = FishingScore.calculate(forecasts.first, waterLevel: wl);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: score, location: loc, waterLevel: wl),
        ),
      );
      _load(); // osveži (možda uklonjena iz omiljenih na Result-u)
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _remove(LocationInfo loc) async {
    await _favService.toggle(loc);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Omiljene vode',
            subtitle: _favs.isEmpty ? null : '${_favs.length} sačuvano',
            showBack: true,
          ),
          if (_opening) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _favs.isEmpty
                    ? _empty(c)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        itemCount: _favs.length,
                        itemBuilder: (_, i) {
                          final f = _favs[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: ListRowCard(
                              onTap: () => _open(f),
                              leading: Icon(Icons.bookmark, color: c.gold, size: 22),
                              title: f.name,
                              subtitle: '${f.latitude.toStringAsFixed(3)}, ${f.longitude.toStringAsFixed(3)}',
                              trailing: IconButton(
                                icon: Icon(Icons.close, size: 20, color: c.faint),
                                onPressed: () => _remove(f),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 56, color: c.faint),
            const SizedBox(height: 14),
            Text('Nema omiljenih voda', style: context.display(size: 18)),
            const SizedBox(height: 6),
            Text('Otvori vodu i tapni 🔖 gore desno da je sačuvaš ovde.',
                textAlign: TextAlign.center,
                style: context.ui(size: 13, weight: FontWeight.w500, color: c.muted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
