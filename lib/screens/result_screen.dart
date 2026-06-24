import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../logic/bait_advisor.dart';
import '../logic/bait_recommender.dart';
import '../logic/technique_advisor.dart';
import '../models/bait_product.dart';
import '../models/feeder_plan.dart';
import '../models/diary_entry.dart';
import '../models/fishing_score.dart';
import '../models/technique_score.dart';
import '../models/weather_data.dart';
import '../services/favorites_service.dart';
import '../services/rhmz_service.dart';
import 'diary_entry_screen.dart';
import '../utils/fish_icons.dart';
import '../utils/moon_calc.dart';
import '../utils/sun_calc.dart';
import '../widgets/score_gauge.dart';
import '../widgets/weather_param_tile.dart';

/// Maps the seasonally-active fish to a feeder-relevant species tag for the
/// bait recommender. Predators (smuđ/štuka/som/tolstolobik) are skipped —
/// they aren't caught on groundbait. Returns the first feeder species, or null.
String? _activeSpeciesTag(List<SeasonalFish> fish) {
  const map = {
    'deverika': 'deverika',
    'šaran': 'saran',
    'amur': 'amur',
    'klen': 'klen',
    'bodorka': 'bodorka',
    'babuška': 'babuska',
    'mrena': 'mrena',
    'skobalj': 'skobalj',
  };
  for (final s in fish) {
    final tag = map[s.name.toLowerCase()];
    if (tag != null) return tag;
  }
  return null;
}

class ResultScreen extends StatefulWidget {
  final FishingScore score;
  final LocationInfo location;
  final WaterLevelForecast? waterLevel;
  final WaterBody? selectedWaterBody;

  const ResultScreen({
    super.key,
    required this.score,
    required this.location,
    this.waterLevel,
    this.selectedWaterBody,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _favService = FavoritesService();
  final _rhmzService = RhmzService();
  bool _isFavorite = false;
  WaterTempReading? _waterTemp;
  List<LevelForecastReading> _levelForecasts = [];
  late FishingScore _score;
  TechniqueType _intervalTech = TechniqueType.feeder;

  @override
  void initState() {
    super.initState();
    _score = widget.score;
    _favService.isFavorite(widget.location).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
    _rhmzService
        .nearestWaterTemp(widget.location.latitude, widget.location.longitude)
        .then((r) {
      if (!mounted) return;
      setState(() {
        _waterTemp = r;
        // Recompute headline score with the real water temperature.
        if (r != null) {
          _score = FishingScore.calculate(
            widget.score.forecast,
            waterLevel: widget.waterLevel,
            waterTempOverride: r.tempC,
          );
        }
      });
    }).catchError((_) {});
    _rhmzService
        .levelForecastsWithin(widget.location.latitude, widget.location.longitude)
        .then((r) {
      if (mounted) setState(() => _levelForecasts = r);
    }).catchError((_) {});
  }

  Future<void> _toggleFavorite() async {
    final added = await _favService.toggle(widget.location);
    setState(() => _isFavorite = added);
  }

  Color get _gradientStart {
    final s = widget.score.score;
    if (s >= 80) return const Color(0xFF1B5E20);
    if (s >= 60) return const Color(0xFF33691E);
    if (s >= 40) return const Color(0xFFE65100);
    if (s >= 20) return const Color(0xFFBF360C);
    return const Color(0xFFB71C1C);
  }

  Color get _gradientEnd {
    final s = widget.score.score;
    if (s >= 80) return const Color(0xFF00695C);
    if (s >= 60) return const Color(0xFF2E7D32);
    if (s >= 40) return const Color(0xFFF9A825);
    if (s >= 20) return const Color(0xFFE64A19);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final location = widget.location;
    final waterLevel = widget.waterLevel;
    final selectedWaterBody = widget.selectedWaterBody;

    final f = score.forecast;
    final now = DateTime.now();
    final techniques = TechniqueAdvisor.advise(f, waterLevel, selectedWaterBody, now);
    final seasonal = TechniqueAdvisor.seasonalFish(now);
    final feederRig = TechniqueAdvisor.feederRigRecommendation(waterLevel, selectedWaterBody, f.avgWindSpeed);
    final sunrise = SunCalc.sunriseTime(location.latitude, location.longitude, f.date);
    final sunset = SunCalc.sunsetTime(location.latitude, location.longitude, f.date);
    final moonPhaseVal = MoonCalc.phase(f.date);
    final solunarWindows = MoonCalc.windows(f.date, location.longitude);
    final closedNow = fishingClosedSeasons.where((s) => s.isClosedOn(f.date)).toList();
    final protectedArea = matchProtectedArea(selectedWaterBody?.name, location.name);
    final feederPlan = BaitAdvisor.plan(
      waterTempC: _waterTemp?.tempC ?? f.estimatedWaterTemperature,
      turbidity: f.turbidity,
      waterLevel: waterLevel,
      waterBody: selectedWaterBody,
      windSpeed: f.avgWindSpeed,
    );
    final baitCombo = BaitRecommender.recommend(
      waterTempC: _waterTemp?.tempC ?? f.estimatedWaterTemperature,
      turbidity: f.turbidity,
      waterBody: selectedWaterBody,
      targetSpecies: _activeSpeciesTag(seasonal),
      discharge: waterLevel?.currentDischarge,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: _gradientStart,
            foregroundColor: Colors.white,
            title: Text(
              selectedWaterBody?.name ?? location.name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                tooltip: _isFavorite ? 'Ukloni iz omiljenih' : 'Dodaj u omiljene',
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_gradientStart, _gradientEnd],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScoreGauge(score: score, dark: true),
                        const SizedBox(height: 8),
                        Text(
                          selectedWaterBody != null
                              ? '${selectedWaterBody.name} · ${location.name}'
                              : location.name,
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🌅 ${_fmtTime(sunrise)}   🌇 ${_fmtTime(sunset)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (protectedArea != null) ...[
                  _ProtectedAreaCard(area: protectedArea),
                  const SizedBox(height: 10),
                ],
                if (closedNow.isNotEmpty) ...[
                  _ClosedSeasonsCard(seasons: closedNow),
                  const SizedBox(height: 10),
                ],
                if (protectedArea != null || closedNow.isNotEmpty) const SizedBox(height: 6),
                const _Label('VREMENSKE PRILIKE'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  children: [
                    WeatherParamTile(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      value: '${f.avgTemperature.toStringAsFixed(1)}°C',
                      color: const Color(0xFFE53935),
                    ),
                    WeatherParamTile(
                      icon: Icons.air,
                      label: 'Vetar · ${_windDirLabel(f.avgWindDirection)}',
                      value: '${f.avgWindSpeed.toStringAsFixed(1)} km/h',
                      color: const Color(0xFF039BE5),
                    ),
                    WeatherParamTile(
                      icon: Icons.water_drop,
                      label: 'Padavine',
                      value: '${f.totalPrecipitation.toStringAsFixed(1)} mm',
                      color: const Color(0xFF1E88E5),
                    ),
                    WeatherParamTile(
                      icon: Icons.speed,
                      label: 'Pritisak',
                      value: '${f.avgPressure.toStringAsFixed(0)} mbar',
                      color: const Color(0xFF8E24AA),
                    ),
                    WeatherParamTile(
                      icon: Icons.cloud,
                      label: 'Oblačnost',
                      value: '${f.avgCloudCover}%',
                      color: const Color(0xFF546E7A),
                    ),
                    WeatherParamTile(
                      icon: Icons.water,
                      label: _waterTemp != null
                          ? 'Temp. vode · ${_waterTemp!.station}'
                          : 'Temp. vode (proc.)',
                      value: _waterTemp != null
                          ? '${_waterTemp!.tempC.toStringAsFixed(1)}°C'
                          : '~${f.estimatedWaterTemperature.toStringAsFixed(0)}°C',
                      color: const Color(0xFF00838F),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _PressureTrendCard(
                  category: f.pressureTrendCategory,
                  trendPer3h: f.pressureTrendPer3h,
                ),
                const SizedBox(height: 10),
                _MoonSolunarCard(phase: moonPhaseVal, windows: solunarWindows),
                // Vodostaj nema smisla za stajaće vode (jezera/bare) — samo reke.
                if (selectedWaterBody?.type != 'lake' &&
                    (waterLevel != null || _levelForecasts.isNotEmpty)) ...[
                  const SizedBox(height: 24),
                  const _Label('VODOSTAJ'),
                  const SizedBox(height: 10),
                  if (waterLevel != null)
                    _WaterLevelTile(
                      waterLevel: waterLevel,
                      waterBodyName: waterLevel.waterBodyName ?? selectedWaterBody?.name,
                    ),
                  if (_levelForecasts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'RHMZ prognoza nivoa — reke u blizini',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ..._levelForecasts.map((fc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LevelForecastTile(forecast: fc),
                        )),
                  ],
                ],
                const SizedBox(height: 24),
                const _Label('PROGNOZA PO INTERVALIMA'),
                const SizedBox(height: 10),
                _TechniqueFilter(
                  selected: _intervalTech,
                  onChanged: (t) => setState(() => _intervalTech = t),
                ),
                const SizedBox(height: 10),
                _ThreeHourSlots(
                  forecast: f,
                  waterLevel: waterLevel,
                  solunarWindows: solunarWindows,
                  technique: _intervalTech,
                  waterBody: selectedWaterBody,
                  waterTemp: _waterTemp?.tempC,
                  sunrise: sunrise,
                  sunset: sunset,
                ),
                if (score.positives.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _Label('POVOLJNO'),
                  const SizedBox(height: 10),
                  ...score.positives.map((p) => _FactorTile(text: p, positive: true)),
                ],
                if (score.negatives.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _Label('NEPOVOLJNO'),
                  const SizedBox(height: 10),
                  ...score.negatives.map((n) => _FactorTile(text: n, positive: false)),
                ],
                const SizedBox(height: 24),
                const _Label('TEHNIKE ZA DANAS'),
                const SizedBox(height: 10),
                _TechniqueSection(techniques: techniques, feederRig: feederRig),
                const SizedBox(height: 24),
                _Label(selectedWaterBody?.type == 'lake'
                    ? 'METHOD PLAN ZA DANAS'
                    : 'FEEDER PLAN ZA DANAS'),
                const SizedBox(height: 10),
                _FeederPlanCard(
                  plan: feederPlan,
                  realTemp: _waterTemp != null,
                ),
                if (baitCombo != null) ...[
                  const SizedBox(height: 24),
                  const _Label('PREPORUČENE TRAPER PRIMAME'),
                  const SizedBox(height: 10),
                  _TraperComboCard(combo: baitCombo),
                ],
                const SizedBox(height: 24),
                const _Label('AKTIVNE VRSTE'),
                const SizedBox(height: 10),
                _SeasonalFishSection(fish: seasonal),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final entry = DiaryEntry(
                        date: f.date,
                        location: location.name,
                        water: selectedWaterBody?.name,
                        lat: location.latitude,
                        lon: location.longitude,
                        airTemp: f.avgTemperature,
                        pressure: f.avgPressure,
                        windSpeed: f.avgWindSpeed,
                        waterTempReal: _waterTemp?.tempC,
                        waterTrend: waterLevel?.trendLabel,
                        moonPhase: moonPhaseVal,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DiaryEntryScreen(entry: entry, isNew: true),
                        ),
                      );
                    },
                    icon: const Text('📖', style: TextStyle(fontSize: 16)),
                    label: const Text(
                      'Zabeleži u dnevnik',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

String _fmtTime(DateTime? t) => t == null
    ? '--:--'
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _windDirLabel(double degrees) {
  const dirs = ['S', 'SI', 'I', 'JI', 'J', 'JZ', 'Z', 'SZ'];
  return dirs[((degrees + 22.5) / 45).floor() % 8];
}

// ── widgets ──────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Color(0xFF546E7A),
      ),
    );
  }
}

class _LevelForecastTile extends StatelessWidget {
  final LevelForecastReading forecast;
  const _LevelForecastTile({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final up = forecast.trend == 'raste';
    final down = forecast.trend == 'pada';
    final color = up
        ? const Color(0xFF0277BD)
        : (down ? const Color(0xFFE65100) : const Color(0xFF2E7D32));
    final icon = up ? '↗' : (down ? '↘' : '→');
    final sign = forecast.deltaCm >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 22, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${forecast.river} · ${forecast.station}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${forecast.todayCm} → ${forecast.forecastCm} cm  ($sign${forecast.deltaCm} cm, ${forecast.trend})',
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                ),
                Text(
                  'stanica ${forecast.distanceKm.toStringAsFixed(0)} km · narednih 3–4 dana',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeederPlanCard extends StatelessWidget {
  final FeederPlan plan;
  final bool realTemp;
  const _FeederPlanCard({required this.plan, required this.realTemp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hook baits
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🪱', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mamac na udici',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF546E7A))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: plan.hookBaits
                          .map((b) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(b,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          _row('🧺', 'Primama', plan.groundbait),
          const SizedBox(height: 10),
          _row('⚖️', 'Količina hrane', plan.feedAmount),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(child: _miniStat('Hranilica', plan.feederType)),
              Expanded(child: _miniStat('Težina', plan.feederWeight)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniStat('Podvez', plan.hooklength)),
              Expanded(child: _miniStat('Udica', plan.hookSize)),
            ],
          ),
          const SizedBox(height: 12),
          _miniStat('Kadenca zabacivanja', plan.cadence),
          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...plan.notes.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(n,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.35)),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 10),
          Text(
            realTemp
                ? 'Plan prema pravoj temp. vode (RHMZ), bistrini i vodostaju.'
                : 'Plan prema proceni temp. vode, bistrini i vodostaju.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _row(String icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF546E7A))),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A237E), height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF90A4AE))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
      ],
    );
  }
}

/// Branded Traper combo recommendation — concrete products tuned to conditions.
class _TraperComboCard extends StatelessWidget {
  final BaitCombo combo;
  const _TraperComboCard({required this.combo});

  static const _traperGreen = Color(0xFF1D5A33);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _traperGreen.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: _traperGreen,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Text('TRAPER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('predlog kombinacije',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                ),
                const Text('🎣', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (combo.secondGroundbait != null) ...[
                  Row(
                    children: [
                      const _MiniLabel('MIKS PRIMAME'),
                      const Spacer(),
                      if (combo.mixRatio != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _traperGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('ODNOS  ${combo.mixRatio}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ProductRow(product: combo.groundbait, roleBadge: 'BAZA'),
                  const SizedBox(height: 10),
                  _ProductRow(product: combo.secondGroundbait!, roleBadge: 'DODATAK'),
                  if (combo.pellet != null || combo.additive != null) ...[
                    const Divider(height: 22),
                    const Align(alignment: Alignment.centerLeft, child: _MiniLabel('UZ MIKS')),
                    const SizedBox(height: 8),
                  ],
                  for (final p in [if (combo.pellet != null) combo.pellet!, if (combo.additive != null) combo.additive!]) ...[
                    _ProductRow(product: p),
                    const SizedBox(height: 10),
                  ],
                ] else
                  for (final p in combo.all) ...[
                    _ProductRow(product: p),
                    if (p != combo.all.last) const SizedBox(height: 10),
                  ],
                if (combo.reasons.isNotEmpty) ...[
                  const Divider(height: 22),
                  ...combo.reasons.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(r,
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.35)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF546E7A), letterSpacing: 0.8));
  }
}

class _ProductRow extends StatelessWidget {
  final BaitProduct product;
  final String? roleBadge;
  const _ProductRow({required this.product, this.roleBadge});

  String get _categoryLabel {
    switch (product.category) {
      case BaitCategory.groundbait:
        return 'PRIMAMA';
      case BaitCategory.pellet:
        return 'PELET';
      case BaitCategory.additive:
        return 'ADITIV';
      case BaitCategory.partikl:
        return 'PARTIKL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(product.imageAsset, width: 64, height: 64, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                  width: 64, height: 64, child: Icon(Icons.image_not_supported, size: 28))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(_categoryLabel,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                  ),
                  if (roleBadge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D5A33),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(roleBadge!,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                  if (product.flagship) ...[
                    const SizedBox(width: 6),
                    const Text('⭐', style: TextStyle(fontSize: 11)),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(product.name,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
              Text('${product.line} · ${product.flavorColor}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(product.shortDesc,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClosedSeasonsCard extends StatelessWidget {
  final List<ClosedSeason> seasons;
  const _ClosedSeasonsCard({required this.seasons});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🚫', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Lovostaj — zaštitni period',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...seasons.map((s) {
            final icon = fishIconAsset(s.species);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  if (icon != null)
                    Image.asset(icon, width: 28, height: 28, fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(width: 28))
                  else
                    const SizedBox(width: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.species,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ),
                  if (s.minSizeCm != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0277BD).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'min ${s.minSizeCm} cm',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF0277BD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    s.dateRange,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          const Text(
            'Lokalni propisi mogu se razlikovati od republičkih.',
            style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _ProtectedAreaCard extends StatelessWidget {
  final ProtectedArea area;
  const _ProtectedAreaCard({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🔒', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Zaštićeno područje — posebna dozvola',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            area.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A148C)),
          ),
          const SizedBox(height: 3),
          Text(
            'Godišnja dozvola: ~${area.permitPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} din',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Opšta ribarska dozvola ne važi — proverite kod upravljača područja.',
            style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _MoonSolunarCard extends StatelessWidget {
  final double phase;
  final List<SolunarWindow> windows;

  const _MoonSolunarCard({required this.phase, required this.windows});

  @override
  Widget build(BuildContext context) {
    final emoji = MoonCalc.phaseEmoji(phase);
    final name = MoonCalc.phaseName(phase);
    final pct = (phase <= 0.5 ? phase * 2 : (1 - phase) * 2) * 100;
    final illumination = phase < 0.5
        ? '${pct.round()}% osvetljenosti (raste)'
        : '${pct.round()}% osvetljenosti (opada)';

    final sorted = [...windows]..sort((a, b) => a.start.compareTo(b.start));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    Text(
                      illumination,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Text(
                'SOLUNAR',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: sorted.map((w) {
              final s = '${w.start.hour.toString().padLeft(2, '0')}:${w.start.minute.toString().padLeft(2, '0')}';
              final e = '${w.end.hour.toString().padLeft(2, '0')}:${w.end.minute.toString().padLeft(2, '0')}';
              final color = w.isMajor ? const Color(0xFF1A237E) : const Color(0xFF455A64);
              final bg = w.isMajor
                  ? const Color(0xFF1A237E).withValues(alpha: 0.10)
                  : Colors.grey.withValues(alpha: 0.08);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(w.isMajor ? '🌙' : '🌛', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      '$s–$e',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: w.isMajor ? FontWeight.w700 : FontWeight.normal,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      w.isMajor ? 'MAJOR' : 'minor',
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FactorTile extends StatelessWidget {
  final String text;
  final bool positive;

  const _FactorTile({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bgColor = positive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(
            positive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterLevelTile extends StatelessWidget {
  final WaterLevelForecast waterLevel;
  final String? waterBodyName;

  const _WaterLevelTile({required this.waterLevel, this.waterBodyName});

  Color get _trendColor {
    switch (waterLevel.trend) {
      case WaterLevelTrend.slightRise:
        return const Color(0xFF2E7D32);
      case WaterLevelTrend.stable:
        return const Color(0xFF0277BD);
      case WaterLevelTrend.slightFall:
        return const Color(0xFFE65100);
      case WaterLevelTrend.largeRise:
      case WaterLevelTrend.largeFall:
        return const Color(0xFFC62828);
    }
  }

  Color get _bgColor {
    switch (waterLevel.trend) {
      case WaterLevelTrend.slightRise:
        return const Color(0xFFE8F5E9);
      case WaterLevelTrend.stable:
        return const Color(0xFFE3F2FD);
      case WaterLevelTrend.slightFall:
        return const Color(0xFFFFF3E0);
      case WaterLevelTrend.largeRise:
      case WaterLevelTrend.largeFall:
        return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _trendColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(waterLevel.trendIcon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waterLevel.trendLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _trendColor,
                  ),
                ),
                Text(
                  waterBodyName ?? 'Obližnja voda',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _trendColor,
                  ),
                ),
                Text(
                  'Protok: ${waterLevel.currentDischarge.toStringAsFixed(1)} m³/s',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechniqueFilter extends StatelessWidget {
  final TechniqueType selected;
  final ValueChanged<TechniqueType> onChanged;
  const _TechniqueFilter({required this.selected, required this.onChanged});

  static const _opts = [
    (TechniqueType.feeder, '🎣', 'Feeder'),
    (TechniqueType.float, '🎏', 'Plovak'),
    (TechniqueType.spinning, '🐟', 'Varalica'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _opts.map((o) {
        final sel = o.$1 == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF0277BD) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? const Color(0xFF0277BD) : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(o.$2, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      o.$3,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : const Color(0xFF546E7A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThreeHourSlots extends StatelessWidget {
  final DailyForecast forecast;
  final WaterLevelForecast? waterLevel;
  final List<SolunarWindow> solunarWindows;
  final TechniqueType technique;
  final WaterBody? waterBody;
  final double? waterTemp;
  final DateTime? sunrise;
  final DateTime? sunset;

  const _ThreeHourSlots({
    required this.forecast,
    this.waterLevel,
    required this.solunarWindows,
    required this.technique,
    this.waterBody,
    this.waterTemp,
    this.sunrise,
    this.sunset,
  });

  // Crepuscular bonus: predators feed hard at dawn/dusk; white fish milder.
  int _crepBonus(DateTime start) {
    if (sunrise == null && sunset == null) return 0;
    final end = start.add(const Duration(hours: 3));
    bool hits(DateTime? t) {
      if (t == null) return false;
      return t.isAfter(start.subtract(const Duration(minutes: 30))) &&
          t.isBefore(end.add(const Duration(minutes: 30)));
    }
    if (!hits(sunrise) && !hits(sunset)) return 0;
    switch (technique) {
      case TechniqueType.spinning:
        return 12;
      case TechniqueType.feeder:
        return 6;
      case TechniqueType.float:
        return 5;
    }
  }

  int _slotScore(List<HourlyWeather> hours) {
    final base = TechniqueAdvisor.scoreFor(
      technique,
      DailyForecast(date: forecast.date, hours: hours),
      waterLevel,
      waterBody,
      forecast.date.month,
      waterTempOverride: waterTemp,
    );
    return (base + _crepBonus(hours.first.time)).clamp(0, 100);
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF1B5E20);
    if (score >= 60) return const Color(0xFF2E7D32);
    if (score >= 40) return const Color(0xFFE65100);
    if (score >= 20) return const Color(0xFFBF360C);
    return const Color(0xFFB71C1C);
  }

  SolunarWindow? _solunarForSlot(DateTime start) {
    final end = start.add(const Duration(hours: 3));
    for (final w in solunarWindows) {
      if (start.isBefore(w.end) && end.isAfter(w.start)) return w;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSummer = forecast.date.month >= 6 && forecast.date.month <= 8;
    final slots = forecast.getThreeHourSlots();
    final scores = slots.map((h) => h.isEmpty ? 0 : _slotScore(h)).toList();
    final maxScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(slots.length, (idx) {
        final hours = slots[idx];
        if (hours.isEmpty) return const SizedBox.shrink();
        final slotHour = hours.first.time.hour;
        if (!isSummer && (slotHour == 0 || slotHour == 3)) return const SizedBox.shrink();

        final slotScoreVal = _slotScore(hours);
        final isGolden = maxScore >= 60 && slotScoreVal >= maxScore - 5;
        final start = hours.first.time;
        final endHour = (start.hour + 3) % 24;
        final timeLabel =
            '${start.hour.toString().padLeft(2, '0')}:00–${endHour.toString().padLeft(2, '0')}:00';
        final temp = hours.map((h) => h.temperature).reduce((a, b) => a + b) / hours.length;
        final wind = hours.map((h) => h.windSpeed).reduce((a, b) => a + b) / hours.length;
        final solunar = _solunarForSlot(start);
        final scoreColor = _scoreColor(slotScoreVal);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isGolden ? const Color(0xFFFFFDE7) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isGolden ? Border.all(color: const Color(0xFFFFB300), width: 1.5) : null,
            boxShadow: [
              BoxShadow(
                color: isGolden
                    ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isGolden ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                child: Row(
                  children: [
                    if (isGolden) const Text('⭐', style: TextStyle(fontSize: 10)),
                    if (isGolden) const SizedBox(width: 2),
                    if (solunar != null) ...[
                      Text(
                        solunar.isMajor ? '🌙' : '🌛',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 2),
                    ],
                    Expanded(
                      child: Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 26,
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$slotScoreVal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.thermostat, size: 14, color: Color(0xFFE53935)),
              Text(
                '${temp.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 12, color: Color(0xFF37474F)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.air, size: 14, color: Color(0xFF039BE5)),
              Text(
                wind.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12, color: Color(0xFF37474F)),
              ),
              const Spacer(),
              Text(
                slotScoreVal >= 80
                    ? '🎣'
                    : slotScoreVal >= 60
                        ? '👍'
                        : slotScoreVal >= 40
                            ? '😐'
                            : '👎',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TechniqueSection extends StatelessWidget {
  final List<TechniqueScore> techniques;
  final String feederRig;
  const _TechniqueSection({required this.techniques, required this.feederRig});

  Color _color(TechniqueType type) {
    switch (type) {
      case TechniqueType.feeder:
        return const Color(0xFF0277BD);
      case TechniqueType.spinning:
        return const Color(0xFF6A1B9A);
      case TechniqueType.float:
        return const Color(0xFF00695C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: techniques.map((t) {
        final color = _color(t.type);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Text(t.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.targetFish.join(' · '),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (t.type == TechniqueType.feeder) ...[
                      const SizedBox(height: 3),
                      Text(
                        '🎣 $feederRig',
                        style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SeasonalFishSection extends StatelessWidget {
  final List<SeasonalFish> fish;
  const _SeasonalFishSection({required this.fish});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fish.map((f) {
        final icon = fishIconAsset(f.name);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Image.asset(icon, width: 36, height: 36, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        Text(f.emoji, style: const TextStyle(fontSize: 22)))
              else
                Text(f.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  Text(
                    f.technique,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PressureTrendCard extends StatelessWidget {
  final PressureTrendCategory category;
  final double trendPer3h;

  const _PressureTrendCard({required this.category, required this.trendPer3h});

  String get _icon {
    switch (category) {
      case PressureTrendCategory.stable:
        return '✓';
      case PressureTrendCategory.preFront:
        return '⚡';
      case PressureTrendCategory.slowRise:
        return '↗';
      case PressureTrendCategory.rapidFall:
        return '⚠';
      case PressureTrendCategory.rapidRise:
        return '↑↑';
    }
  }

  String get _label {
    switch (category) {
      case PressureTrendCategory.stable:
        return 'Stabilan pritisak — ribe predvidive';
      case PressureTrendCategory.preFront:
        return 'Pre-frontalni prozor — ribe aktivne!';
      case PressureTrendCategory.slowRise:
        return 'Pritisak raste — uslovi se poboljšavaju';
      case PressureTrendCategory.rapidFall:
        return 'Brzi pad pritiska — ribe se gase';
      case PressureTrendCategory.rapidRise:
        return 'Pritisak naglo raste — ribe se adaptiraju';
    }
  }

  Color get _color {
    switch (category) {
      case PressureTrendCategory.stable:
        return const Color(0xFF2E7D32);
      case PressureTrendCategory.preFront:
        return const Color(0xFFE65100);
      case PressureTrendCategory.slowRise:
        return const Color(0xFF0277BD);
      case PressureTrendCategory.rapidFall:
        return const Color(0xFFC62828);
      case PressureTrendCategory.rapidRise:
        return const Color(0xFFE65100);
    }
  }

  Color get _bgColor {
    switch (category) {
      case PressureTrendCategory.stable:
        return const Color(0xFFE8F5E9);
      case PressureTrendCategory.preFront:
        return const Color(0xFFFFF3E0);
      case PressureTrendCategory.slowRise:
        return const Color(0xFFE3F2FD);
      case PressureTrendCategory.rapidFall:
        return const Color(0xFFFFEBEE);
      case PressureTrendCategory.rapidRise:
        return const Color(0xFFFFF3E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sign = trendPer3h >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(_icon, style: TextStyle(fontSize: 20, color: _color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _color),
                ),
                Text(
                  'Trend pritiska: $sign${trendPer3h.toStringAsFixed(1)} mbar/3h',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
