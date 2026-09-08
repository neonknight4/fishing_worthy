import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../logic/bait_advisor.dart';
import '../logic/bait_recommender.dart';
import '../logic/float_advisor.dart';
import '../logic/lure_advisor.dart';
import '../logic/technique_advisor.dart';
import '../data/traper_combos.dart';
import '../models/bait_product.dart';
import '../models/water_combo.dart';
import '../models/feeder_plan.dart';
import '../models/float_plan.dart';
import '../models/lure_plan.dart';
import '../models/diary_entry.dart';
import '../models/fishing_score.dart';
import '../models/technique_score.dart';
import '../models/weather_data.dart';
import '../services/shop_link.dart';
import '../services/favorites_service.dart';
import '../services/rhmz_service.dart';
import 'diary_entry_screen.dart';
import '../utils/fish_icons.dart';
import '../utils/moon_calc.dart';
import '../utils/sun_calc.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

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

/// Grubo preslikavanje dnevnog skora (0–100) na procenu aktivnosti ribe —
/// modifikator količine/finoće hranjenja u kuriranom combo-u.
FishActivity _activityFromScore(int score) {
  if (score >= 65) return FishActivity.visoka;
  if (score >= 40) return FishActivity.umerena;
  return FishActivity.niska;
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
  /// Izabrana tehnika — vodi i skor u heru i sve preporuke ispod njega.
  TechniqueType _technique = TechniqueType.feeder;

  /// Pod-režim plovkarenja. Otpuštanje ima smisla samo na rekama.
  FloatMode _floatMode = FloatMode.standard;

  @override
  void initState() {
    super.initState();
    _favService.isFavorite(_favLoc).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
    _rhmzService
        .nearestWaterTemp(widget.location.latitude, widget.location.longitude)
        .then((r) {
      // Prava temp. vode ulazi u sve tehničke skorove kroz rebuild.
      if (mounted) setState(() => _waterTemp = r);
    }).catchError((_) {});
    _rhmzService
        .levelForecastsWithin(widget.location.latitude, widget.location.longitude)
        .then((r) {
      if (mounted) setState(() => _levelForecasts = r);
    }).catchError((_) {});
  }

  /// Omiljena stavka = izabrana voda (ako je birana), inače lokacija.
  LocationInfo get _favLoc => widget.selectedWaterBody != null
      ? LocationInfo(
          name: widget.selectedWaterBody!.name,
          latitude: widget.selectedWaterBody!.latitude,
          longitude: widget.selectedWaterBody!.longitude,
        )
      : widget.location;

  Future<void> _toggleFavorite() async {
    final added = await _favService.toggle(_favLoc);
    if (!mounted) return;
    setState(() => _isFavorite = added);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added
            ? '${_favLoc.name} dodata u omiljene'
            : '${_favLoc.name} uklonjena iz omiljenih'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final location = widget.location;
    final waterLevel = widget.waterLevel;
    final selectedWaterBody = widget.selectedWaterBody;

    final f = widget.score.forecast;
    final now = DateTime.now();
    final waterTempC = _waterTemp?.tempC ?? f.estimatedWaterTemperature;
    final trottingOk = FloatAdvisor.trottingApplies(selectedWaterBody);
    final floatMode = trottingOk ? _floatMode : FloatMode.standard;
    final techniques = TechniqueAdvisor.advise(f, waterLevel, selectedWaterBody, now,
        waterTempC: waterTempC, floatTrotting: floatMode == FloatMode.trotting);
    // Skor i razlozi u heru pripadaju IZABRANOJ tehnici, ne opštoj oceni.
    final active = techniques.firstWhere((t) => t.type == _technique);
    // Aktivne vrste prate izabrani tab — na varalicu idu grabljivice.
    final seasonal = TechniqueAdvisor.seasonalFish(now,
        type: _technique, floatTrotting: floatMode == FloatMode.trotting);
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
      targetSpecies: _activeSpeciesTag(
          TechniqueAdvisor.seasonalFish(now, type: TechniqueType.feeder)),
      discharge: waterLevel?.currentDischarge,
    );
    // Hibrid: ekspertski kurirani recept ako voda ima combo za tekuću sezonu;
    // inače (775 nepokrivenih voda) fallback na algoritamski baitCombo.
    final curatedCombo = comboFor(selectedWaterBody?.name, seasonForMonth(now.month));
    final fishActivity = _activityFromScore(active.score);
    final lurePlan = LureAdvisor.plan(
      waterTempC: waterTempC,
      turbidity: f.turbidity,
      windSpeed: f.avgWindSpeed,
      month: now.month,
      waterLevel: waterLevel,
      waterBody: selectedWaterBody,
    );
    final floatPlan = FloatAdvisor.plan(
      waterTempC: waterTempC,
      turbidity: f.turbidity,
      windSpeed: f.avgWindSpeed,
      month: now.month,
      mode: floatMode,
      waterLevel: waterLevel,
      waterBody: selectedWaterBody,
    );

    final c = context.c;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: c.green2,
            foregroundColor: c.onGreen,
            leading: const BackButton(),
            title: Text(
              selectedWaterBody?.name ?? location.name,
              style: context.display(size: 17, color: c.onGreen),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.bookmark : Icons.bookmark_border, color: c.onGreen),
                tooltip: _isFavorite ? 'Ukloni iz omiljenih' : 'Dodaj u omiljene',
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _TechniqueTabs(
                  techniques: techniques,
                  selected: _technique,
                  onChanged: (t) => setState(() => _technique = t),
                ),
                const SizedBox(height: 12),
                _ScoreHero(
                  value: active.score,
                  techniqueName: active.name,
                  waterName: selectedWaterBody?.name ?? location.name,
                  place: selectedWaterBody != null ? location.name : null,
                  sunrise: _fmtTime(sunrise),
                  sunset: _fmtTime(sunset),
                ),
                if (protectedArea != null) ...[
                  const SizedBox(height: 12),
                  _ProtectedAreaCard(area: protectedArea),
                ],
                if (closedNow.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ClosedSeasonsCard(seasons: closedNow),
                ],
                const SectionHeader('Uslovi'),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.92,
                  children: [
                    ConditionTile(
                      icon: Icons.thermostat,
                      value: f.avgTemperature.toStringAsFixed(1),
                      unit: '°C',
                      label: 'Vazduh',
                    ),
                    ConditionTile(
                      icon: Icons.air,
                      value: f.avgWindSpeed.toStringAsFixed(0),
                      unit: 'km/h',
                      label: 'Vetar ${_windDirLabel(f.avgWindDirection)}',
                    ),
                    ConditionTile(
                      icon: Icons.speed,
                      value: f.avgPressure.toStringAsFixed(0),
                      unit: 'mbar',
                      label: 'Pritisak',
                    ),
                    ConditionTile(
                      icon: Icons.water_drop,
                      value: f.totalPrecipitation.toStringAsFixed(1),
                      unit: 'mm',
                      label: 'Padavine',
                    ),
                    ConditionTile(
                      icon: Icons.cloud,
                      value: '${f.avgCloudCover}',
                      unit: '%',
                      label: 'Oblačnost',
                    ),
                    ConditionTile(
                      icon: Icons.water,
                      value: _waterTemp != null
                          ? _waterTemp!.tempC.toStringAsFixed(1)
                          : '~${f.estimatedWaterTemperature.toStringAsFixed(0)}',
                      unit: '°C',
                      label: _waterTemp != null ? 'Voda' : 'Voda (proc.)',
                    ),
                  ],
                ),
                if (active.positives.isNotEmpty || active.negatives.isNotEmpty) ...[
                  SectionHeader('Zašto ovaj skor — ${active.name.toLowerCase()}'),
                  FactorList([
                    for (final p in active.positives) FactorItem(positive: true, title: p),
                    for (final n in active.negatives) FactorItem(positive: false, title: n),
                  ]),
                ],
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
                  const SectionHeader('Vodostaj'),
                  if (waterLevel != null)
                    _WaterLevelTile(
                      waterLevel: waterLevel,
                      waterBodyName: waterLevel.waterBodyName ?? selectedWaterBody?.name,
                    ),
                  if (_levelForecasts.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'RHMZ prognoza nivoa — reke u blizini',
                      style: context.ui(size: 11, weight: FontWeight.w600, color: c.muted),
                    ),
                    const SizedBox(height: 6),
                    ..._levelForecasts.map((fc) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LevelForecastTile(forecast: fc),
                        )),
                  ],
                ],
                SectionHeader('Prognoza po intervalima — ${active.name.toLowerCase()}'),
                _ThreeHourSlots(
                  forecast: f,
                  waterLevel: waterLevel,
                  solunarWindows: solunarWindows,
                  technique: _technique,
                  floatTrotting: floatMode == FloatMode.trotting,
                  waterBody: selectedWaterBody,
                  waterTemp: _waterTemp?.tempC,
                  sunrise: sunrise,
                  sunset: sunset,
                ),
                // ── Sadržaj po izabranoj tehnici ────────────────────────
                if (_technique == TechniqueType.feeder) ...[
                  SectionHeader(selectedWaterBody?.type == 'lake'
                      ? 'Method plan za danas'
                      : 'Feeder plan za danas'),
                  _FeederPlanCard(
                    plan: feederPlan,
                    realTemp: _waterTemp != null,
                  ),
                  if (curatedCombo != null) ...[
                    const SectionHeader('Traper kombinacija'),
                    _CuratedComboCard(combo: curatedCombo, activity: fishActivity),
                  ] else if (baitCombo != null) ...[
                    const SectionHeader('Preporučene Traper primame'),
                    _TraperComboCard(combo: baitCombo),
                  ],
                ] else if (_technique == TechniqueType.spinning) ...[
                  const SectionHeader('Plan varaličarenja'),
                  _LurePlanCard(plan: lurePlan, realTemp: _waterTemp != null),
                ] else ...[
                  const SectionHeader('Plan plovkarenja'),
                  if (trottingOk) ...[
                    _FloatModeToggle(
                      selected: floatMode,
                      onChanged: (m) => setState(() => _floatMode = m),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _FloatPlanCard(plan: floatPlan, realTemp: _waterTemp != null),
                ],
                SectionHeader('Aktivne vrste — ${active.name.toLowerCase()}'),
                _SeasonalFishSection(fish: seasonal),
                const SizedBox(height: 24),
                AppButton(
                  'Zabeleži u dnevnik',
                  icon: Icons.menu_book_outlined,
                  block: true,
                  large: true,
                  onTap: () {
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

String _verdict(int s) => s >= 80
    ? 'Odlično'
    : s >= 60
        ? 'Dobro'
        : s >= 40
            ? 'Osrednje'
            : s >= 20
                ? 'Slabo'
                : 'Loše';

String _verdictSub(int s) => s >= 60
    ? 'Uslovi rade u tvoju korist — iskoristi dan.'
    : s >= 40
        ? 'Promenljivo — cilja se pravi prozor u danu.'
        : 'Teški uslovi — strpljenje i fino hranjenje.';

/// Score hero: tamno zeleni gradijent + poluluk merač + verdikt (light + dark).
class _ScoreHero extends StatelessWidget {
  final int value;
  final String techniqueName;
  final String waterName;
  final String? place;
  final String sunrise, sunset;
  const _ScoreHero({
    required this.value,
    required this.techniqueName,
    required this.waterName,
    this.place,
    required this.sunrise,
    required this.sunset,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final v = value;
    final numColor = c.score(v);
    const onHero = Color(0xFFF4EFE1);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: c.shadowLg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.green2, c.greenInk],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(waterName, style: context.display(size: 18, color: onHero), overflow: TextOverflow.ellipsis),
                    if (place != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 13, color: onHero),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(place!,
                                  style: context.ui(size: 12.5, weight: FontWeight.w600, color: onHero.withValues(alpha: 0.8)),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              AppChip('🌅 $sunrise  🌇 $sunset', tone: ChipTone.gold, small: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 138,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    HalfGauge(value: v.toDouble(), width: 138, color: numColor, trackColor: Colors.white.withValues(alpha: 0.18)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          text: '$v',
                          style: context.display(size: 34, weight: FontWeight.w800, color: onHero),
                          children: [
                            TextSpan(text: '/100', style: context.display(size: 13, color: onHero.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(techniqueName.toUpperCase(),
                        style: context.ui(
                            size: 10,
                            weight: FontWeight.w800,
                            color: onHero.withValues(alpha: 0.65))),
                    const SizedBox(height: 2),
                    Text(_verdict(v), style: context.display(size: 20, color: onHero)),
                    const SizedBox(height: 3),
                    Text(_verdictSub(v),
                        style: context.ui(size: 12.5, weight: FontWeight.w600, color: onHero.withValues(alpha: 0.82))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelForecastTile extends StatelessWidget {
  final LevelForecastReading forecast;
  const _LevelForecastTile({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final up = forecast.trend == 'raste';
    final down = forecast.trend == 'pada';
    final color = up ? c.good : (down ? c.gold : c.muted);
    final icon = up ? Icons.trending_up : (down ? Icons.trending_down : Icons.trending_flat);
    final sign = forecast.deltaCm >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${forecast.river} · ${forecast.station}',
                    style: context.ui(size: 13, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${forecast.todayCm} → ${forecast.forecastCm} cm  ($sign${forecast.deltaCm} cm, ${forecast.trend})',
                  style: context.ui(size: 12, weight: FontWeight.w700, color: color),
                ),
                Text('stanica ${forecast.distanceKm.toStringAsFixed(0)} km · narednih 3–4 dana',
                    style: context.ui(size: 10, weight: FontWeight.w500, color: c.faint)),
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
        color: context.c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.c.green.withValues(alpha: 0.4)),
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
                    Text('Mamac na udici',
                        style: context.ui(size: 11, weight: FontWeight.w700, color: context.c.muted)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: plan.hookBaits
                          .map((b) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.c.green.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(b,
                                    style: context.ui(size: 12, weight: FontWeight.w600, color: context.c.green)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          _row(context, '🧺', 'Primama', plan.groundbait),
          const SizedBox(height: 10),
          _row(context, '⚖️', 'Količina hrane', plan.feedAmount),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(child: _miniStat(context, 'Hranilica', plan.feederType)),
              Expanded(child: _miniStat(context, 'Težina', plan.feederWeight)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _miniStat(context, 'Podvez', plan.hooklength)),
              Expanded(child: _miniStat(context, 'Udica', plan.hookSize)),
            ],
          ),
          const SizedBox(height: 12),
          _miniStat(context, 'Kadenca zabacivanja', plan.cadence),
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
                            style: context.ui(size: 11.5, weight: FontWeight.w500, color: context.c.muted, height: 1.35)),
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
            style: context.ui(size: 10, weight: FontWeight.w500, color: context.c.faint)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String icon, String label, String value) {
    final c = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.ui(size: 11, weight: FontWeight.w700, color: c.muted)),
              const SizedBox(height: 3),
              Text(value, style: context.ui(size: 13, weight: FontWeight.w600, color: c.ink, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(BuildContext context, String label, String value) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.ui(size: 10, weight: FontWeight.w700, color: c.muted)),
        const SizedBox(height: 2),
        Text(value, style: context.ui(size: 13, weight: FontWeight.w600, color: c.ink)),
      ],
    );
  }
}

/// Plan varaličarenja — klasa pribora, varalice, vođenje, mesta.
class _LurePlanCard extends StatelessWidget {
  final LurePlan plan;
  final bool realTemp;
  const _LurePlanCard({required this.plan, required this.realTemp});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.gold.withValues(alpha: 0.45)),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Klasa pribora + ciljne vrste
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${plan.lureClass.label} · ${plan.lureClass.castRange}',
                  style: context.ui(size: 12, weight: FontWeight.w800, color: c.gold),
                ),
              ),
            ],
          ),
          if (plan.targetFish.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final fish in plan.targetFish)
                  AppChip(fish, tone: ChipTone.neutral, small: true),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _label(context, '🎣', 'Varalice'),
          const SizedBox(height: 6),
          for (final l in plan.lures)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(l.type,
                            style: context.ui(size: 13, weight: FontWeight.w700, color: c.ink)),
                      ),
                      const SizedBox(width: 8),
                      Text(l.size,
                          style: context.ui(size: 11.5, weight: FontWeight.w700, color: c.gold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(l.detail,
                      style: context.ui(
                          size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          _stat(context, 'Vođenje', plan.retrieve),
          const SizedBox(height: 10),
          _stat(context, 'Dubina', plan.depth),
          const SizedBox(height: 10),
          _stat(context, 'Boje', plan.colors),
          const SizedBox(height: 10),
          _stat(context, 'Struna i predvez', plan.line),
          if (plan.spots.isNotEmpty) ...[
            const SizedBox(height: 14),
            _label(context, '📍', 'Gde tražiti'),
            const SizedBox(height: 6),
            for (final s in plan.spots)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('· ', style: context.ui(size: 12, color: c.muted)),
                    Expanded(
                      child: Text(s,
                          style: context.ui(
                              size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final n in plan.notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(n,
                          style: context.ui(
                              size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
          if (plan.alternative != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.surface3,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Text('↔ ${plan.alternative}',
                  style: context.ui(
                      size: 11.5, weight: FontWeight.w600, color: c.muted, height: 1.35)),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            realTemp
                ? 'Plan prema pravoj temp. vode (RHMZ), bistrini, vetru i vodostaju.'
                : 'Plan prema proceni temp. vode, bistrini, vetru i vodostaju.',
            style: context.ui(size: 10, weight: FontWeight.w500, color: c.faint)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

/// Prekidač između klasičnog plovka i plovka na otpuštanje (samo reke).
class _FloatModeToggle extends StatelessWidget {
  final FloatMode selected;
  final ValueChanged<FloatMode> onChanged;
  const _FloatModeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final m in FloatMode.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: m == selected ? c.water : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    m.label,
                    style: context.ui(
                        size: 12.5,
                        weight: FontWeight.w700,
                        color: m == selected ? Colors.white : c.muted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Plan plovkarenja — plovak, olovljavanje, dubina, mamci, ritam hranjenja.
/// Za režim „na otpuštanje" dodaje i četiri načina vođenja niz vodu.
class _FloatPlanCard extends StatelessWidget {
  final FloatPlan plan;
  final bool realTemp;
  const _FloatPlanCard({required this.plan, required this.realTemp});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.water.withValues(alpha: 0.45)),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.targetFish.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final fish in plan.targetFish)
                  AppChip(fish, tone: ChipTone.neutral, small: true),
              ],
            ),
            const SizedBox(height: 14),
          ],
          _label(context, '🪱', 'Mamac na udici'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in plan.hookBaits)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.water.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(b,
                      style: context.ui(size: 12, weight: FontWeight.w700, color: c.water)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _stat(context, 'Štap', plan.rod),
          const SizedBox(height: 10),
          _stat(context, 'Plovak', plan.floatType),
          const SizedBox(height: 10),
          _stat(context, 'Olovljavanje', plan.shotting),
          const SizedBox(height: 10),
          _stat(context, 'Dubina', plan.depth),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _mini(context, 'Predvez', plan.hooklength)),
              Expanded(child: _mini(context, 'Udica', plan.hookSize)),
            ],
          ),
          const SizedBox(height: 12),
          _stat(context, 'Hranjenje', plan.feeding),
          if (plan.guides.isNotEmpty) ...[
            const SizedBox(height: 16),
            _label(context, '🎯', 'Vođenje niz vodu'),
            const SizedBox(height: 8),
            for (final g in plan.guides)
              Builder(builder: (context) {
                final rec = g.name == plan.recommendedGuide;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: rec ? c.water.withValues(alpha: 0.10) : c.surface3,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                    border: rec
                        ? Border.all(color: c.water.withValues(alpha: 0.55))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(g.name,
                                style: context.ui(
                                    size: 13, weight: FontWeight.w800, color: c.ink)),
                          ),
                          if (rec)
                            AppChip('Probaj prvo', tone: ChipTone.green, small: true),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(g.when,
                          style: context.ui(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: c.water,
                              height: 1.3)),
                      const SizedBox(height: 3),
                      Text(g.how,
                          style: context.ui(
                              size: 11.5,
                              weight: FontWeight.w500,
                              color: c.muted,
                              height: 1.35)),
                    ],
                  ),
                );
              }),
          ],
          if (plan.notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final n in plan.notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(n,
                          style: context.ui(
                              size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35)),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 10),
          Text(
            realTemp
                ? 'Plan prema pravoj temp. vode (RHMZ), bistrini, vetru i vodostaju.'
                : 'Plan prema proceni temp. vode, bistrini, vetru i vodostaju.',
            style: context.ui(size: 10, weight: FontWeight.w500, color: c.faint)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// Deljeni sitni gradivni blokovi za _LurePlanCard / _FloatPlanCard.
Widget _label(BuildContext context, String icon, String text) => Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(text,
            style: context.ui(size: 11, weight: FontWeight.w700, color: context.c.muted)),
      ],
    );

Widget _stat(BuildContext context, String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.ui(size: 10, weight: FontWeight.w700, color: context.c.muted)),
        const SizedBox(height: 3),
        Text(value,
            style: context.ui(
                size: 12.5, weight: FontWeight.w600, color: context.c.ink, height: 1.35)),
      ],
    );

Widget _mini(BuildContext context, String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.ui(size: 10, weight: FontWeight.w700, color: context.c.muted)),
        const SizedBox(height: 2),
        Text(value, style: context.ui(size: 13, weight: FontWeight.w600, color: context.c.ink)),
      ],
    );

/// Branded Traper combo recommendation — concrete products tuned to conditions.
class _TraperComboCard extends StatelessWidget {
  final BaitCombo combo;
  const _TraperComboCard({required this.combo});

  static const _traperGreen = Color(0xFF1D5A33);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _traperGreen.withValues(alpha: 0.35)),
        boxShadow: context.c.shadow,
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
                                  style: context.ui(size: 11.5, weight: FontWeight.w500, color: context.c.muted, height: 1.35)),
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

/// Kurirani, ekspertski Traper recept za konkretnu vodu + sezonu.
/// Reuse `_ProductRow`/`_MiniLabel`; dodaje collapsible "Kako pripremiti"
/// (priprema + hranjenje + modifikator po aktivnosti ribe).
class _CuratedComboCard extends StatefulWidget {
  final WaterCombo combo;
  final FishActivity activity;
  const _CuratedComboCard({required this.combo, required this.activity});

  @override
  State<_CuratedComboCard> createState() => _CuratedComboCardState();
}

class _CuratedComboCardState extends State<_CuratedComboCard> {
  static const _traperGreen = Color(0xFF1D5A33);
  bool _prepOpen = false;

  @override
  Widget build(BuildContext context) {
    final combo = widget.combo;
    final extras = <Widget>[
      if (combo.pellet != null) _ProductRow(product: combo.pellet!),
      for (final a in combo.additives) _ProductRow(product: a),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _traperGreen.withValues(alpha: 0.35)),
        boxShadow: context.c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header + sezona
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
                  child: Text('ekspertski recept za ovu vodu',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(seasonLabel(combo.season).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (combo.species.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: combo.species
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: context.c.green.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
                              child: Text(s,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (combo.second != null) ...[
                  Row(
                    children: [
                      const _MiniLabel('MIKS PRIMAME'),
                      const Spacer(),
                      if (combo.mixRatio != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _traperGreen, borderRadius: BorderRadius.circular(8)),
                          child: Text('ODNOS  ${combo.mixRatio}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ProductRow(product: combo.base, roleBadge: 'BAZA'),
                  const SizedBox(height: 10),
                  _ProductRow(product: combo.second!, roleBadge: 'DODATAK'),
                ] else
                  _ProductRow(product: combo.base, roleBadge: 'BAZA'),
                if (extras.isNotEmpty) ...[
                  const Divider(height: 22),
                  const Align(alignment: Alignment.centerLeft, child: _MiniLabel('UZ SMEŠU')),
                  const SizedBox(height: 8),
                  for (final w in extras) ...[w, const SizedBox(height: 10)],
                ],
                if (combo.hookbait != null) ...[
                  const Divider(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🪝 ', style: TextStyle(fontSize: 13)),
                      const _MiniLabel('MAMAC'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(combo.hookbait!,
                            style: context.ui(size: 11.5, weight: FontWeight.w500, color: context.c.ink, height: 1.35)),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐟 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(activityMod(widget.activity),
                          style: context.ui(size: 11.5, weight: FontWeight.w500, color: context.c.muted, height: 1.35)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => setState(() => _prepOpen = !_prepOpen),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.c.surface3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _traperGreen.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Text('🥣 ', style: TextStyle(fontSize: 14)),
                        const Expanded(
                          child: Text('Kako pripremiti i hraniti',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _traperGreen)),
                        ),
                        Icon(_prepOpen ? Icons.expand_less : Icons.expand_more, color: _traperGreen, size: 20),
                      ],
                    ),
                  ),
                ),
                if (_prepOpen) ...[
                  const SizedBox(height: 10),
                  _PrepBlock(label: 'PRIPREMA SMEŠE', text: combo.prep),
                  const SizedBox(height: 10),
                  _PrepBlock(label: 'HRANJENJE', text: combo.loading),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Jedan blok teksta unutar "Kako pripremiti" sekcije.
class _PrepBlock extends StatelessWidget {
  final String label;
  final String text;
  const _PrepBlock({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniLabel(label),
        const SizedBox(height: 4),
        Text(text, style: context.ui(size: 12, weight: FontWeight.w500, color: context.c.ink, height: 1.4)),
      ],
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: context.ui(size: 10, weight: FontWeight.w800, color: context.c.muted, letterSpacing: 0.8));
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

  Future<void> _openProduct() => ShopLink.open(product.productUrl, placement: 'recept');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasShop = product.productUrl != null;
    return InkWell(
      onTap: hasShop ? _openProduct : null,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(product.imageAsset, width: 64, height: 64, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(Icons.image_not_supported, size: 28, color: c.faint))),
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
                        color: c.green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_categoryLabel,
                          style: context.ui(size: 9, weight: FontWeight.w800, color: c.green)),
                    ),
                    if (roleBadge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(roleBadge!,
                            style: context.ui(size: 9, weight: FontWeight.w800, color: c.onBrand)),
                      ),
                    ],
                    if (product.flagship) ...[
                      const SizedBox(width: 6),
                      const Text('⭐', style: TextStyle(fontSize: 11)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(product.name, style: context.ui(size: 13.5, weight: FontWeight.w700, color: c.ink)),
                Text('${product.line} · ${product.flavorColor}',
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted)),
                const SizedBox(height: 2),
                Text(product.shortDesc,
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted, height: 1.3)),
                if (hasShop) ...[
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, size: 13, color: c.green),
                      const SizedBox(width: 4),
                      Text('Kupi na m-fishing.rs',
                          style: context.ui(
                              size: 10.5,
                              weight: FontWeight.w700,
                              color: c.green,
                              letterSpacing: 0)
                              .copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: c.green.withValues(alpha: 0.4))),
                      const SizedBox(width: 3),
                      Icon(Icons.open_in_new, size: 12, color: c.green),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedSeasonsCard extends StatelessWidget {
  final List<ClosedSeason> seasons;
  const _ClosedSeasonsCard({required this.seasons});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
        border: Border(left: BorderSide(color: c.coral, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.block, size: 16, color: c.coral),
              const SizedBox(width: 8),
              Text('Lovostaj — zaštitni period',
                  style: context.ui(size: 13, weight: FontWeight.w700, color: c.coral)),
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
                    child: Text(s.species, style: context.ui(size: 12, weight: FontWeight.w600, color: c.ink)),
                  ),
                  if (s.minSizeCm != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('min ${s.minSizeCm} cm',
                          style: context.ui(size: 10, weight: FontWeight.w700, color: c.green)),
                    ),
                  Text(s.dateRange, style: context.ui(size: 11, weight: FontWeight.w600, color: c.coral)),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Text('Lokalni propisi mogu se razlikovati od republičkih.',
              style: context.ui(size: 10, weight: FontWeight.w500, color: c.faint).copyWith(fontStyle: FontStyle.italic)),
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
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
        border: Border(left: BorderSide(color: c.gold, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, size: 16, color: c.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Zaštićeno područje — posebna dozvola',
                    style: context.ui(size: 13, weight: FontWeight.w700, color: c.gold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(area.name, style: context.ui(size: 13, weight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 3),
          Text(
            'Godišnja dozvola: ~${area.permitPrice.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} din',
            style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted),
          ),
          const SizedBox(height: 4),
          Text('Opšta ribarska dozvola ne važi — proverite kod upravljača područja.',
              style: context.ui(size: 10, weight: FontWeight.w500, color: c.faint).copyWith(fontStyle: FontStyle.italic)),
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
    final c = context.c;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
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
                    Text(name, style: context.ui(size: 13, weight: FontWeight.w700, color: c.ink)),
                    Text(illumination, style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted)),
                  ],
                ),
              ),
              Text('SOLUNAR',
                  style: context.ui(size: 9, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: sorted.map((w) {
              final s = '${w.start.hour.toString().padLeft(2, '0')}:${w.start.minute.toString().padLeft(2, '0')}';
              final e = '${w.end.hour.toString().padLeft(2, '0')}:${w.end.minute.toString().padLeft(2, '0')}';
              final color = w.isMajor ? c.gold : c.muted;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: w.isMajor ? c.gold.withValues(alpha: 0.16) : c.surface3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(w.isMajor ? '🌙' : '🌛', style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text('$s–$e',
                        style: context.ui(
                            size: 11, weight: w.isMajor ? FontWeight.w700 : FontWeight.w500, color: color)),
                    const SizedBox(width: 3),
                    Text(w.isMajor ? 'MAJOR' : 'minor',
                        style: context.ui(size: 9, weight: FontWeight.w600, color: color, letterSpacing: 0.4)),
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

class _WaterLevelTile extends StatelessWidget {
  final WaterLevelForecast waterLevel;
  final String? waterBodyName;

  const _WaterLevelTile({required this.waterLevel, this.waterBodyName});

  Color _trendColor(AppColors c) {
    switch (waterLevel.trend) {
      case WaterLevelTrend.slightRise:
        return c.good;
      case WaterLevelTrend.stable:
        return c.muted;
      case WaterLevelTrend.slightFall:
        return c.gold;
      case WaterLevelTrend.largeRise:
      case WaterLevelTrend.largeFall:
        return c.coral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tc = _trendColor(c);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
        border: Border(left: BorderSide(color: tc, width: 4)),
      ),
      child: Row(
        children: [
          Text(waterLevel.trendIcon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(waterLevel.trendLabel, style: context.ui(size: 14, weight: FontWeight.w700, color: tc)),
                Text(waterBodyName ?? 'Obližnja voda', style: context.ui(size: 13, weight: FontWeight.w700, color: c.ink)),
                Text('Protok: ${waterLevel.currentDischarge.toStringAsFixed(1)} m³/s',
                    style: context.ui(size: 12, weight: FontWeight.w500, color: c.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Svetla pločica ispod fotografije pribora — ista u obe teme, da tamni
/// feeder ostane čitljiv i na dark pozadini i na zelenom izabranom tabu.
const _techTile = Color(0xFFF6F1E4);

/// Tabovi tehnike iznad hero boxa — biraju i skor i sve preporuke ispod.
/// Redosled je fiksan (Feeder · Varaličarenje · Plovkarenje), a ne po skoru,
/// da tab ne skakuće ispod prsta kad se uslovi promene.
class _TechniqueTabs extends StatelessWidget {
  final List<TechniqueScore> techniques;
  final TechniqueType selected;
  final ValueChanged<TechniqueType> onChanged;
  const _TechniqueTabs({
    required this.techniques,
    required this.selected,
    required this.onChanged,
  });

  static const _order = [
    TechniqueType.feeder,
    TechniqueType.spinning,
    TechniqueType.float,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        for (final type in _order) ...[
          Builder(builder: (context) {
            final t = techniques.firstWhere((x) => x.type == type);
            final sel = type == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                  decoration: BoxDecoration(
                    color: sel ? c.green : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? c.green : c.line),
                    boxShadow: sel ? c.shadow : null,
                  ),
                  child: Column(
                    children: [
                      // Fotografije pribora stoje na svetloj pločici — crni
                      // feeder bi se inače izgubio na tamnoj temi.
                      Container(
                        width: 34,
                        height: 34,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _techTile,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Image.asset(
                          t.iconAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, _, _) =>
                              Text(t.icon, style: const TextStyle(fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          t.name,
                          maxLines: 1,
                          style: context.ui(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: sel ? c.onBrand : c.muted),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.white.withValues(alpha: 0.22)
                              : c.score(t.score).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${t.score}',
                          style: context.ui(
                              size: 11,
                              weight: FontWeight.w800,
                              color: sel ? c.onBrand : c.score(t.score)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (type != _order.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ThreeHourSlots extends StatelessWidget {
  final DailyForecast forecast;
  final WaterLevelForecast? waterLevel;
  final List<SolunarWindow> solunarWindows;
  final TechniqueType technique;
  final bool floatTrotting;
  final WaterBody? waterBody;
  final double? waterTemp;
  final DateTime? sunrise;
  final DateTime? sunset;

  const _ThreeHourSlots({
    required this.forecast,
    this.waterLevel,
    required this.solunarWindows,
    required this.technique,
    this.floatTrotting = false,
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
      floatTrotting: floatTrotting,
    );
    return (base + _crepBonus(hours.first.time)).clamp(0, 100);
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
    final c = context.c;
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
        final scoreColor = c.score(slotScoreVal);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isGolden ? Color.alphaBlend(c.gold.withValues(alpha: 0.14), c.surface) : c.surface,
            borderRadius: BorderRadius.circular(12),
            border: isGolden ? Border.all(color: c.gold, width: 1.5) : null,
            boxShadow: c.shadow,
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
                      Text(solunar.isMajor ? '🌙' : '🌛', style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                    ],
                    Expanded(
                      child: Text(timeLabel, style: context.ui(size: 12, weight: FontWeight.w700, color: c.ink)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 26,
                decoration: BoxDecoration(color: scoreColor, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text('$slotScoreVal',
                    style: context.ui(size: 13, weight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Icon(Icons.thermostat, size: 14, color: c.coral),
              Text('${temp.toStringAsFixed(0)}°', style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted)),
              const SizedBox(width: 8),
              Icon(Icons.air, size: 14, color: c.water),
              Text(wind.toStringAsFixed(0), style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted)),
              const Spacer(),
              Text(
                slotScoreVal >= 80 ? '🎣' : slotScoreVal >= 60 ? '👍' : slotScoreVal >= 40 ? '😐' : '👎',
                style: const TextStyle(fontSize: 16),
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
            color: context.c.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: context.c.shadow,
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
                  Text(f.name, style: context.ui(size: 13, weight: FontWeight.w700, color: context.c.ink)),
                  Text(f.technique, style: context.ui(size: 11, weight: FontWeight.w500, color: context.c.muted)),
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

  Color _accent(AppColors c) {
    switch (category) {
      case PressureTrendCategory.stable:
        return c.good;
      case PressureTrendCategory.preFront:
        return c.gold;
      case PressureTrendCategory.slowRise:
        return c.green;
      case PressureTrendCategory.rapidFall:
        return c.coral;
      case PressureTrendCategory.rapidRise:
        return c.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = _accent(c);
    final sign = trendPer3h >= 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: c.shadow,
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        children: [
          Text(_icon, style: TextStyle(fontSize: 20, color: accent)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_label, style: context.ui(size: 13, weight: FontWeight.w700, color: accent)),
                Text('Trend pritiska: $sign${trendPer3h.toStringAsFixed(1)} mbar/3h',
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
