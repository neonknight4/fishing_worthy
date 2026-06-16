import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../models/weather_data.dart';
import '../services/water_service.dart';

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
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ribolovne vode', style: TextStyle(fontSize: 16)),
            Text(
              widget.locationName,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Krug pretrage:',
            style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF0277BD) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? const Color(0xFF0277BD) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$r km',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'Greška pri učitavanju',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Pokušaj ponovo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0277BD),
                foregroundColor: Colors.white,
              ),
            ),
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
          Text(
            'Tražim vode u krugu od $_selectedRadius km...',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_bodies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Nema pronađenih voda u krugu od $_selectedRadius km',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pokušaj sa većim opsegom pretrage',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final rivers = _bodies.where((b) => b.type == 'river').toList();
    final lakes = _bodies.where((b) => b.type != 'river').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          '${_bodies.length} pronađenih voda u krugu od $_selectedRadius km',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (rivers.isNotEmpty) ...[
          _sectionLabel('REKE I KANALI', '🏞', rivers.length),
          const SizedBox(height: 8),
          ...rivers.map((b) => _WaterBodyTile(body: b)),
          const SizedBox(height: 16),
        ],
        if (lakes.isNotEmpty) ...[
          _sectionLabel('JEZERA I BARE', '🏖', lakes.length),
          const SizedBox(height: 8),
          ...lakes.map((b) => _WaterBodyTile(body: b)),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label, String icon, int count) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: Color(0xFF546E7A),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _WaterBodyTile extends StatelessWidget {
  final WaterBody body;
  const _WaterBodyTile({required this.body});

  @override
  Widget build(BuildContext context) {
    final isRiver = body.type == 'river';
    final baseColor = isRiver ? const Color(0xFF0277BD) : const Color(0xFF2E7D32);
    final bgColor = isRiver ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
    final protected = matchProtectedArea(body.name, null);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pop(context, body),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  isRiver ? '🏞' : '🏖',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            body.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        if (protected != null)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              '🔒 posebna dozvola',
                              style: TextStyle(fontSize: 9, color: Color(0xFF6A1B9A), fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRiver ? 'Reka' : 'Jezero / bara',
                            style: TextStyle(fontSize: 10, color: baseColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.place, size: 12, color: Colors.grey.shade400),
                        Text(
                          '${body.distanceKm.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        if (protected != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '~${protected.permitPrice} din/god.',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6A1B9A)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
