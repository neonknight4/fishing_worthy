import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/fishing_seasons.dart';
import '../models/diary_entry.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
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
  final _mapController = MapController();
  List<WaterBody> _waters = [];
  List<DiaryEntry> _catches = []; // zabeleženi ulovi sa koordinatama
  WaterBody? _selected;
  LatLng? _customPoint; // korisnikova izabrana tačka (long-press)
  String? _customName;
  bool _loading = true;
  bool _choosing = false;
  bool _showCatches = false;
  String _filter = 'sve'; // 'sve' | 'reka' | 'jezero'

  List<WaterBody> get _filtered => _filter == 'sve'
      ? _waters
      : _waters.where((w) => _filter == 'reka' ? w.type == 'river' : w.type != 'river').toList();

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
    if (mounted) setState(() { _waters = list; _loading = false; });
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
            subtitle: _loading ? widget.locationName : '${_filtered.length} voda u krugu 50 km',
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
                      userAgentPackageName: 'rs.fishing.worthy',
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
                // filter čipovi
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Row(
                    children: [
                      for (final f in const [('sve', 'Sve'), ('reka', 'Reke'), ('jezero', 'Jezera')])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() { _filter = f.$1; _selected = null; }),
                            child: AppChip(f.$2, tone: _filter == f.$1 ? ChipTone.green : ChipTone.neutral),
                          ),
                        ),
                      const Spacer(),
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
