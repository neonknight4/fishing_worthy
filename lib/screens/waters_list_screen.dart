import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../models/weather_data.dart';
import '../services/water_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

class WatersListScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const WatersListScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<WatersListScreen> createState() => _WatersListScreenState();
}

class _WatersListScreenState extends State<WatersListScreen> {
  final _waterService = WaterService();
  final _radii = [10, 25, 50];
  int _selectedRadius = 25;
  List<WaterBody> _bodies = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _waterService.fetchNearbyWaterBodies(
        widget.latitude,
        widget.longitude,
        radiusKm: _selectedRadius,
      );
      setState(() {
        _bodies = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: 'Vode', subtitle: widget.locationName, showBack: true),
          _buildRadiusFilter(),
          Expanded(
            child: _loading
                ? _buildLoading()
                : _error != null
                    ? _buildError()
                    : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusFilter() {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Row(
        children: [
          Text('Krug:', style: context.ui(size: 13, weight: FontWeight.w600, color: c.muted)),
          const SizedBox(width: 10),
          ..._radii.map((r) {
            final selected = r == _selectedRadius;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: selected
                    ? null
                    : () {
                        setState(() => _selectedRadius = r);
                        _fetch();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? c.green : c.surface3,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$r km',
                      style: context.ui(
                          size: 13, weight: FontWeight.w700, color: selected ? c.onBrand : c.ink)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError() {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: c.coral),
            const SizedBox(height: 12),
            Text('Greška pri učitavanju', style: context.display(size: 17)),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: context.ui(size: 12, color: c.muted)),
            const SizedBox(height: 16),
            AppButton('Pokušaj ponovo', icon: Icons.refresh, onTap: _fetch),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text('Tražim vode u krugu od $_selectedRadius km…',
              style: context.ui(size: 13, color: context.c.muted)),
        ],
      ),
    );
  }

  Widget _buildList() {
    final c = context.c;
    if (_bodies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water, size: 52, color: c.faint),
              const SizedBox(height: 12),
              Text('Nema voda u krugu od $_selectedRadius km',
                  textAlign: TextAlign.center, style: context.display(size: 17)),
              const SizedBox(height: 6),
              Text('Pokušaj sa većim opsegom pretrage',
                  style: context.ui(size: 13, weight: FontWeight.w500, color: c.muted)),
            ],
          ),
        ),
      );
    }

    final rivers = _bodies.where((b) => b.type == 'river').toList();
    final lakes = _bodies.where((b) => b.type != 'river').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
      children: [
        Text('${_bodies.length} voda u krugu od $_selectedRadius km',
            style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted)),
        if (rivers.isNotEmpty) ...[
          const SectionLabel('Reke i kanali'),
          ...rivers.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _WaterBodyRow(body: b),
              )),
        ],
        if (lakes.isNotEmpty) ...[
          const SectionLabel('Jezera i bare'),
          ...lakes.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _WaterBodyRow(body: b),
              )),
        ],
      ],
    );
  }
}

class _WaterBodyRow extends StatelessWidget {
  final WaterBody body;
  const _WaterBodyRow({required this.body});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isRiver = body.type == 'river';
    final protected = matchProtectedArea(body.name, null);
    return ListRowCard(
      onTap: () => Navigator.pop(context, body),
      leading: Icon(isRiver ? Icons.waves : Icons.water, color: c.water, size: 22),
      title: body.name,
      subtitle:
          '${isRiver ? 'Reka' : 'Jezero / bara'} · ${body.distanceKm.toStringAsFixed(1)} km${protected != null ? '  🔒 posebna dozvola' : ''}',
      trailing: Icon(Icons.chevron_right, color: c.faint, size: 20),
    );
  }
}
