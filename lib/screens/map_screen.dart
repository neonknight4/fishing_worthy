import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/fishing_seasons.dart';
import '../models/weather_data.dart';
import '../services/water_service.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _waterService = WaterService();
  final _mapController = MapController();
  List<WaterBody> _waters = [];
  WaterBody? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Karta voda', style: TextStyle(fontSize: 16)),
            Text(
              _loading ? widget.locationName : '${_waters.length} voda u krugu 50 km',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
      body: Stack(
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
                    child: const Icon(Icons.my_location, color: Color(0xFFD32F2F), size: 28),
                  ),
                  for (final w in _waters) _waterMarker(w),
                ],
              ),
            ],
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            right: 12,
            bottom: _selected != null ? 150 : 24,
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
    );
  }

  Marker _waterMarker(WaterBody w) {
    final isRiver = w.type == 'river';
    final color = isRiver ? const Color(0xFF0277BD) : const Color(0xFF2E7D32);
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

  Widget _zoomBtn(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: const Color(0xFF01579B), size: 22),
          ),
        ),
      );

  void _zoom(double delta) {
    final cam = _mapController.camera;
    _mapController.move(cam.center, (cam.zoom + delta).clamp(6, 17));
  }

  Widget _infoCard(WaterBody w) {
    final isRiver = w.type == 'river';
    final protected = matchProtectedArea(w.name, null);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isRiver ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isRiver ? Icons.waves : Icons.water, color: isRiver ? const Color(0xFF0277BD) : const Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                      Text(
                        '${isRiver ? "Reka / kanal" : "Jezero / bara"} · ${w.distanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () => setState(() => _selected = null),
                ),
              ],
            ),
            if (protected != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEDE7F6), borderRadius: BorderRadius.circular(10)),
                child: Text('🔒 ${protected.name} · posebna dozvola ~${protected.permitPrice} din/god.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, w),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Izaberi ovu vodu', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0277BD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
