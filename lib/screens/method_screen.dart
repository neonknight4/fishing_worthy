import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/commercial_lake.dart';
import '../models/diary_entry.dart';
import '../services/commercial_lakes_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/moon_calc.dart';
import '../widgets/components.dart';
import 'diary_entry_screen.dart';

/// Method tab — mapa komercijalnih revira (method/šaran) u Srbiji.
/// (Škola / montaže / kontekst dolaze kasnije — vidi docs/METHOD_TAB.md.)
class MethodScreen extends StatefulWidget {
  final bool showBack;
  const MethodScreen({super.key, this.showBack = false});

  @override
  State<MethodScreen> createState() => _MethodScreenState();
}

class _MethodScreenState extends State<MethodScreen> {
  final _service = CommercialLakesService();
  final _mapController = MapController();
  List<CommercialLake> _lakes = [];
  bool _loading = true;

  // Centar Srbije (prikaz cele zemlje).
  static final _center = LatLng(44.1, 20.8);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.load().catchError((_) => <CommercialLake>[]);
    if (mounted) setState(() { _lakes = list; _loading = false; });
  }

  void _openDetail(CommercialLake l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LakeSheet(lake: l),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Method reviri',
            subtitle: _loading ? 'Komercijalna jezera' : '${_lakes.length} revira',
            showBack: widget.showBack,
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 6.6,
                    minZoom: 6,
                    maxZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'rs.fishing.worthy',
                    ),
                    MarkerLayer(
                      markers: [for (final l in _lakes) _pin(l)],
                    ),
                  ],
                ),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (!_loading && _lakes.isEmpty) _emptyOverlay(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _pin(CommercialLake l) {
    final c = context.c;
    final col = l.method ? c.green : c.coral;
    return Marker(
      point: LatLng(l.lat, l.lon),
      width: 34,
      height: 34,
      child: GestureDetector(
        onTap: () => _openDetail(l),
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

  Widget _emptyOverlay(AppColors c) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: c.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 40, color: c.faint),
            const SizedBox(height: 10),
            Text('Reviri uskoro', style: context.display(size: 16)),
            const SizedBox(height: 4),
            Text('Komercijalni method reviri se dodaju.',
                textAlign: TextAlign.center,
                style: context.ui(size: 12.5, weight: FontWeight.w500, color: c.muted)),
          ],
        ),
      ),
    );
  }
}

class _LakeSheet extends StatefulWidget {
  final CommercialLake lake;
  const _LakeSheet({required this.lake});

  @override
  State<_LakeSheet> createState() => _LakeSheetState();
}

class _LakeSheetState extends State<_LakeSheet> {
  bool _logging = false;

  /// Zabeleži izlazak na ovaj revir u dnevnik — povuče današnje uslove
  /// za koordinate revira, pa otvori editor unosa.
  Future<void> _logTrip() async {
    final lake = widget.lake;
    setState(() => _logging = true);
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
    Navigator.pop(context); // zatvori sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiaryEntryScreen(entry: entry, isNew: true)),
    );
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
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          AppButton(
            _logging ? 'Beležim…' : 'Zabeleži izlazak',
            icon: Icons.menu_book_outlined,
            block: true,
            onTap: _logging ? null : _logTrip,
          ),
          if (lake.contact != null) ...[
            const SizedBox(height: 8),
            AppButton('Kontakt', icon: Icons.call, kind: BtnKind.outline, block: true, onTap: () => _openContact(lake.contact!)),
          ] else if (lake.link != null) ...[
            const SizedBox(height: 8),
            AppButton('Otvori', icon: Icons.open_in_new, kind: BtnKind.outline, block: true, onTap: () => _openContact(lake.link!)),
          ],
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
