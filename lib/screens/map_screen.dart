import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/fishing_seasons.dart';
import '../models/commercial_lake.dart';
import '../models/diary_entry.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
import '../services/commercial_lakes_service.dart';
import '../services/diary_service.dart';
import '../services/location_service.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/moon_calc.dart';
import '../widgets/components.dart';
import 'diary_entry_screen.dart';
import 'result_screen.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final bool showBack;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.showBack = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _waterService = WaterService();
  final _weatherService = WeatherService();
  final _locationService = LocationService();
  final _diaryService = DiaryService();
  final _lakesService = CommercialLakesService();
  final _mapController = MapController();
  List<WaterBody> _waters = [];
  List<CommercialLake> _lakes = []; // komercijalni method reviri (cela Srbija)
  List<DiaryEntry> _catches = []; // zabeleženi ulovi sa koordinatama
  WaterBody? _selected;
  LatLng? _customPoint; // korisnikova izabrana tačka (long-press)
  String? _customName;
  bool _loading = true;
  bool _choosing = false;
  bool _showCatches = false;
  String _filter = 'sve'; // 'sve' | 'reka' | 'jezero' | 'method'

  // Centar Srbije — na „Method" kamera se odmiče da uhvati sve revire.
  static final _serbiaCenter = LatLng(44.1, 20.8);

  List<WaterBody> get _filtered => switch (_filter) {
        'sve' => _waters,
        'reka' => _waters.where((w) => w.type == 'river').toList(),
        'jezero' => _waters.where((w) => w.type != 'river').toList(),
        _ => const <WaterBody>[], // 'method' — samo reviri na mapi
      };

  /// Reviri stoje na celokupnoj mapi (uz reke i jezera) dok se ne filtrira
  /// na reke/jezera; „Method" ih ostavlja same.
  bool get _showLakes => _filter == 'sve' || _filter == 'method';

  @override
  void initState() {
    super.initState();
    _load();
    _loadCatches();
    diaryRevision.addListener(_loadCatches);
  }

  @override
  void dispose() {
    diaryRevision.removeListener(_loadCatches);
    super.dispose();
  }

  Future<void> _loadCatches() async {
    final all = await _diaryService.all().catchError((_) => <DiaryEntry>[]);
    final withCoords = all.where((e) => e.lat != null && e.lon != null).toList();
    if (mounted) setState(() => _catches = withCoords);
  }

  /// Izbor vode: u push modu (iz Home) vrati [WaterBody]; u tab modu
  /// učitaj prognozu i otvori Result direktno.
  Future<void> _chooseWater(WaterBody w) async {
    if (widget.showBack) {
      Navigator.pop(context, w);
      return;
    }
    setState(() => _choosing = true);
    try {
      final forecasts = await _weatherService.fetchForecast(w.latitude, w.longitude);
      if (forecasts.isEmpty) return;
      final isLake = w.type != 'river';
      final wl = isLake
          ? null
          : await _waterService.fetchWaterLevelForecast(w.latitude, w.longitude, waterBodyName: w.name);
      final score = FishingScore.calculate(forecasts.first, waterLevel: wl);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            location: LocationInfo(name: w.name, latitude: w.latitude, longitude: w.longitude),
            waterLevel: wl,
            selectedWaterBody: w,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  Future<void> _load() async {
    final list = await _waterService
        .fetchNearbyWaterBodies(widget.latitude, widget.longitude, radiusKm: 50)
        .catchError((_) => <WaterBody>[]);
    final lakes = await _lakesService.load().catchError((_) => <CommercialLake>[]);
    if (mounted) setState(() { _waters = list; _lakes = lakes; _loading = false; });
  }

  /// Promena filtera. „Method" odmiče kameru na celu Srbiju (reviri su rasuti
  /// po zemlji, a mapa startuje zumirana na korisnikov kraj); „Sve" je vraća.
  void _setFilter(String f) {
    if (f == _filter) return;
    setState(() { _filter = f; _selected = null; _customPoint = null; });
    if (f == 'method') {
      _mapController.move(_serbiaCenter, 6.6);
    } else if (f == 'sve') {
      _mapController.move(LatLng(widget.latitude, widget.longitude), 11);
    }
  }

  /// Detalj revira u bottom sheet-u.
  void _openLake(CommercialLake l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LakeSheet(lake: l),
    );
  }

  /// Korisnik dugim pritiskom bira proizvoljnu tačku na vodi.
  Future<void> _dropCustom(LatLng p) async {
    setState(() { _customPoint = p; _customName = null; _selected = null; });
    final name = await _locationService.placeName(p.latitude, p.longitude).catchError((_) => 'Izabrana tačka');
    if (mounted && _customPoint == p) setState(() => _customName = name);
  }

  /// Zabeleži ulov na izabranoj tački → kreira unos + otvori editor.
  Future<void> _logAt(LatLng p) async {
    setState(() => _choosing = true);
    double? air, pressure, wind;
    try {
      final f = await _weatherService.fetchForecast(p.latitude, p.longitude);
      if (f.isNotEmpty) { air = f.first.avgTemperature; pressure = f.first.avgPressure; wind = f.first.avgWindSpeed; }
    } catch (_) {}
    if (!mounted) return;
    final now = DateTime.now();
    final entry = DiaryEntry(
      date: now,
      location: _customName ?? 'Izabrana tačka',
      lat: p.latitude,
      lon: p.longitude,
      airTemp: air,
      pressure: pressure,
      windSpeed: wind,
      moonPhase: MoonCalc.phase(now),
    );
    setState(() { _choosing = false; _customPoint = null; });
    Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryEntryScreen(entry: entry, isNew: true)));
  }

  Future<void> _openCatch(DiaryEntry e) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryEntryScreen(entry: e, isNew: false)));
  }

  /// Proveri stanje (skor + uslovi) na custom tački — koristi isti engine
  /// (vreme za tačku + najbliža RHMZ stanica za temp vode + GloFAS protok).
  Future<void> _checkCustom(LatLng p) async {
    setState(() => _choosing = true);
    try {
      final forecasts = await _weatherService.fetchForecast(p.latitude, p.longitude);
      if (forecasts.isEmpty) return;
      final wl = await _waterService
          .fetchWaterLevelForecast(p.latitude, p.longitude, waterBodyName: _customName)
          .catchError((_) => null);
      final score = FishingScore.calculate(forecasts.first, waterLevel: wl);
      if (!mounted) return;
      final name = _customName ?? 'Izabrana tačka';
      setState(() { _choosing = false; _customPoint = null; });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            location: LocationInfo(name: name, latitude: p.latitude, longitude: p.longitude),
            waterLevel: wl,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _choosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Mapa voda',
            subtitle: _loading
                ? widget.locationName
                : _filter == 'method'
                    ? '${_lakes.length} komercijalnih revira'
                    : '${_filtered.length} voda u krugu 50 km',
            showBack: widget.showBack,
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 11,
                    minZoom: 6,
                    maxZoom: 17,
                    onTap: (_, _) => setState(() { _selected = null; _customPoint = null; }),
                    onLongPress: (_, p) => _dropCustom(p),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'rs.upecaj.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.my_location, color: context.c.coral, size: 28),
                        ),
                        for (final w in _filtered) _waterMarker(w),
                        if (_showLakes)
                          for (final l in _lakes) _lakeMarker(l),
                        if (_showCatches)
                          for (final e in _catches) _catchMarker(e),
                        if (_customPoint != null)
                          Marker(
                            point: _customPoint!,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.place, color: context.c.gold, size: 38),
                          ),
                      ],
                    ),
                  ],
                ),
                const OsmAttribution(),
                // filter čipovi
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Row(
                    children: [
                      // Četiri filtera + Ulovi ne staju na uži ekran — filteri skroluju.
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final f in const [
                                ('sve', 'Sve'),
                                ('reka', 'Reke'),
                                ('jezero', 'Jezera'),
                                ('method', 'Method'),
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _setFilter(f.$1),
                                    child: AppChip(f.$2,
                                        tone: _filter == f.$1 ? ChipTone.green : ChipTone.neutral),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _showCatches = !_showCatches),
                        child: AppChip('🎣 Ulovi ${_catches.isEmpty ? '' : '(${_catches.length})'}',
                            tone: _showCatches ? ChipTone.gold : ChipTone.neutral),
                      ),
                    ],
                  ),
                ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                Positioned(
                  right: 12,
                  bottom: (_selected != null || _customPoint != null) ? 170 : 24,
                  child: Column(
                    children: [
                      _zoomBtn(Icons.add, () => _zoom(1)),
                      const SizedBox(height: 8),
                      _zoomBtn(Icons.remove, () => _zoom(-1)),
                      const SizedBox(height: 8),
                      _zoomBtn(Icons.my_location, () => _mapController.move(center, 12)),
                    ],
                  ),
                ),
                if (_customPoint == null && _selected == null) _hintBar(),
                if (_selected != null) _infoCard(_selected!),
                if (_customPoint != null) _customCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBar() {
    final c = context.c;
    return Positioned(
      left: 12, right: 12, bottom: 24,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              boxShadow: c.shadow,
            ),
            child: Text('Drži prst na mapi da zabeležiš ulov',
                style: context.ui(size: 12, weight: FontWeight.w700, color: c.muted)),
          ),
        ),
      ),
    );
  }

  Marker _catchMarker(DiaryEntry e) {
    final c = context.c;
    return Marker(
      point: LatLng(e.lat!, e.lon!),
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () => _openCatch(e),
        child: Container(
          decoration: BoxDecoration(
            color: c.gold,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: const Icon(Icons.set_meal, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _customCard() {
    final c = context.c;
    final p = _customPoint!;
    return Positioned(
      left: 12, right: 12, bottom: 24,
      child: AppCard(
        radius: AppRadius.l,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: c.gold, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_customName ?? 'Učitavam mesto…', style: context.display(size: 16)),
                      Text('${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}',
                          style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted)),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.close, color: c.muted), onPressed: () => setState(() => _customPoint = null)),
              ],
            ),
            const SizedBox(height: 10),
            AppButton(_choosing ? 'Učitavam…' : 'Proveri stanje ovde',
                icon: Icons.assessment_outlined, block: true,
                onTap: _choosing ? null : () => _checkCustom(p)),
            const SizedBox(height: 8),
            AppButton('Zabeleži ulov ovde',
                icon: Icons.menu_book_outlined, kind: BtnKind.outline, block: true,
                onTap: _choosing ? null : () => _logAt(p)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 13, color: c.faint),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Tvoja mesta ostaju na telefonu — drugi ih ne vide.',
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.faint, height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Marker _waterMarker(WaterBody w) {
    final c = context.c;
    final isRiver = w.type == 'river';
    final color = isRiver ? c.water : c.green;
    final selected = _selected?.name == w.name;
    return Marker(
      point: LatLng(w.latitude, w.longitude),
      width: selected ? 40 : 30,
      height: selected ? 40 : 30,
      child: GestureDetector(
        onTap: () => setState(() => _selected = w),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: selected ? 3 : 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: Icon(isRiver ? Icons.waves : Icons.water, color: Colors.white, size: selected ? 20 : 15),
        ),
      ),
    );
  }

  /// Pin komercijalnog revira. Zelen = method dozvoljen, koralna = nije.
  Marker _lakeMarker(CommercialLake l) {
    final c = context.c;
    final col = l.method ? c.green : c.coral;
    return Marker(
      point: LatLng(l.lat, l.lon),
      width: 34,
      height: 34,
      child: GestureDetector(
        onTap: () => _openLake(l),
        child: Container(
          decoration: BoxDecoration(
            color: col,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
          ),
          child: Icon(l.method ? Icons.set_meal : Icons.block, color: Colors.white, size: 17),
        ),
      ),
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    final c = context.c;
    return Material(
      color: c.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: c.green, size: 22),
        ),
      ),
    );
  }

  void _zoom(double delta) {
    final cam = _mapController.camera;
    _mapController.move(cam.center, (cam.zoom + delta).clamp(6, 17));
  }

  Widget _infoCard(WaterBody w) {
    final c = context.c;
    final isRiver = w.type == 'river';
    final protected = matchProtectedArea(w.name, null);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 24,
      child: AppCard(
        radius: AppRadius.l,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.surface3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isRiver ? Icons.waves : Icons.water, color: c.water),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name, style: context.display(size: 17)),
                      Text('${isRiver ? "Reka / kanal" : "Jezero / bara"} · ${w.distanceKm.toStringAsFixed(1)} km',
                          style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: c.muted),
                  onPressed: () => setState(() => _selected = null),
                ),
              ],
            ),
            if (protected != null) ...[
              const SizedBox(height: 8),
              AppChip('🔒 ${protected.name} · ~${protected.permitPrice} din/god.',
                  tone: ChipTone.gold, small: true),
            ],
            const SizedBox(height: 12),
            AppButton(_choosing ? 'Učitavam…' : 'Izaberi ovu vodu',
                icon: Icons.check, block: true, onTap: _choosing ? null : () => _chooseWater(w)),
          ],
        ),
      ),
    );
  }
}

/// Detalj komercijalnog revira. Prenet sa nekadašnjeg Method taba (mapa revira
/// je spojena sa glavnom mapom), uz „Proveri stanje" — isti skor engine kao
/// za ostale vode.
class _LakeSheet extends StatefulWidget {
  final CommercialLake lake;
  const _LakeSheet({required this.lake});

  @override
  State<_LakeSheet> createState() => _LakeSheetState();
}

class _LakeSheetState extends State<_LakeSheet> {
  bool _busy = false;

  /// Skor + uslovi za koordinate revira. Reviri su stajaće vode → vodostaj
  /// (protok) ne ulazi u ocenu.
  Future<void> _check() async {
    final lake = widget.lake;
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final f = await WeatherService().fetchForecast(lake.lat, lake.lon);
      if (f.isEmpty) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final score = FishingScore.calculate(f.first);
      if (!mounted) return;
      nav.pop();
      nav.push(MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          location: LocationInfo(name: lake.name, latitude: lake.lat, longitude: lake.lon),
          selectedWaterBody: WaterBody(
            name: lake.name,
            type: 'lake',
            distanceKm: 0,
            latitude: lake.lat,
            longitude: lake.lon,
          ),
        ),
      ));
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Zabeleži izlazak na ovaj revir u dnevnik — povuče današnje uslove
  /// za koordinate revira, pa otvori editor unosa.
  Future<void> _logTrip() async {
    final lake = widget.lake;
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    double? air, pressure, wind;
    try {
      final f = await WeatherService().fetchForecast(lake.lat, lake.lon);
      if (f.isNotEmpty) {
        air = f.first.avgTemperature;
        pressure = f.first.avgPressure;
        wind = f.first.avgWindSpeed;
      }
    } catch (_) {}
    if (!mounted) return;
    final now = DateTime.now();
    final entry = DiaryEntry(
      date: now,
      location: lake.city,
      water: lake.name,
      lat: lake.lat,
      lon: lake.lon,
      airTemp: air,
      pressure: pressure,
      windSpeed: wind,
      moonPhase: MoonCalc.phase(now),
      technique: 'Method',
    );
    nav.pop(); // zatvori sheet
    nav.push(MaterialPageRoute(builder: (_) => DiaryEntryScreen(entry: entry, isNew: true)));
  }

  Future<void> _openContact(String v) async {
    Uri? uri;
    if (v.startsWith('http')) {
      uri = Uri.parse(v);
    } else if (RegExp(r'[0-9]').hasMatch(v)) {
      uri = Uri.parse('tel:${v.replaceAll(RegExp(r'[^0-9+]'), '')}');
    }
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lake = widget.lake;
    // Pravila revira su slobodan tekst i mogu biti dugačka — telo skroluje,
    // akcije ostaju prikovane u podnožju.
    return AppSheet(
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            _busy ? 'Učitavam…' : 'Proveri stanje ovde',
            icon: Icons.assessment_outlined,
            block: true,
            onTap: _busy ? null : _check,
          ),
          const SizedBox(height: 8),
          AppButton(
            'Zabeleži izlazak',
            icon: Icons.menu_book_outlined,
            kind: BtnKind.outline,
            block: true,
            onTap: _busy ? null : _logTrip,
          ),
          if (lake.contact != null) ...[
            const SizedBox(height: 8),
            AppButton('Kontakt', icon: Icons.call, kind: BtnKind.outline, block: true,
                onTap: () => _openContact(lake.contact!)),
          ] else if (lake.link != null) ...[
            const SizedBox(height: 8),
            AppButton('Otvori', icon: Icons.open_in_new, kind: BtnKind.outline, block: true,
                onTap: () => _openContact(lake.link!)),
          ],
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lake.name, style: context.display(size: 19)),
                    Text(lake.city, style: context.ui(size: 12.5, weight: FontWeight.w600, color: c.muted)),
                  ],
                ),
              ),
              AppChip(
                lake.method ? 'Method OK' : 'Bez method-a',
                tone: lake.method ? ChipTone.green : ChipTone.warn,
                small: true,
              ),
            ],
          ),
          if (lake.species.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final s in lake.species) AppChip(s, tone: ChipTone.neutral, small: true)],
            ),
          ],
          const SizedBox(height: 12),
          if (lake.permit != null) _row(context, Icons.confirmation_number_outlined, 'Dozvola', lake.permit!),
          if (lake.hours != null) _row(context, Icons.schedule, 'Radno vreme', lake.hours!),
          if (lake.rules != null) _row(context, Icons.rule, 'Pravila', lake.rules!),
          if (lake.approxCoords) _row(context, Icons.location_searching, 'Lokacija', 'Približna — proveriti'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: c.water),
          const SizedBox(width: 10),
          Text('$label: ', style: context.ui(size: 12.5, weight: FontWeight.w700, color: c.muted)),
          Expanded(child: Text(value, style: context.ui(size: 12.5, weight: FontWeight.w600))),
        ],
      ),
    );
  }
}
