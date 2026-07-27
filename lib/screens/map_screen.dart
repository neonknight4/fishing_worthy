import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/fishing_seasons.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
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
  final _mapController = MapController();
  List<WaterBody> _waters = [];
  WaterBody? _selected;
  bool _loading = true;
  bool _choosing = false;
  String _filter = 'sve'; // 'sve' | 'reka' | 'jezero'

  List<WaterBody> get _filtered => _filter == 'sve'
      ? _waters
      : _waters.where((w) => _filter == 'reka' ? w.type == 'river' : w.type != 'river').toList();

  @override
  void initState() {
    super.initState();
    _load();
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
                    onTap: (_, _) => setState(() => _selected = null),
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
                    ],
                  ),
                ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                Positioned(
                  right: 12,
                  bottom: _selected != null ? 160 : 24,
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
                if (_selected != null) _infoCard(_selected!),
              ],
            ),
          ),
        ],
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
