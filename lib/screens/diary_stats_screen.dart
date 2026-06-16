import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../utils/fish_icons.dart';

/// Pattern analysis over diary entries: top species + which conditions
/// produce the most fish (temp band, water-level trend, pressure band).
class DiaryStatsScreen extends StatelessWidget {
  final List<DiaryEntry> entries;
  const DiaryStatsScreen({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final withCatch = entries.where((e) => e.totalCatch > 0).toList();
    final totalFish = entries.fold<int>(0, (s, e) => s + e.totalCatch);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        title: const Text('Statistika dnevnika', style: TextStyle(fontSize: 16)),
      ),
      body: entries.isEmpty
          ? Center(
              child: Text('Nema dovoljno unosa za statistiku',
                  style: TextStyle(color: Colors.grey.shade600)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _summaryRow(entries.length, totalFish),
                const SizedBox(height: 20),
                _speciesSection(),
                const SizedBox(height: 20),
                if (withCatch.length >= 2) ...[
                  _Label('NAJBOLJI USLOVI ZA ULOV'),
                  const SizedBox(height: 10),
                  ..._conditionInsights(withCatch),
                ] else
                  _hint('Zabeleži bar 2 izlaska sa ulovom da vidiš obrasce uslova.'),
              ],
            ),
    );
  }

  Widget _summaryRow(int trips, int fish) {
    return Row(
      children: [
        Expanded(child: _statCard('🎣', '$trips', 'izlazaka')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('🐟', '$fish', 'riba ukupno')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('📊', trips > 0 ? (fish / trips).toStringAsFixed(1) : '0', 'po izlasku')),
      ],
    );
  }

  Widget _statCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E))),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _speciesSection() {
    final counts = <String, int>{};
    for (final e in entries) {
      for (final c in e.catches) {
        counts[c.species] = (counts[c.species] ?? 0) + c.count;
      }
    }
    if (counts.isEmpty) return _hint('Još nema zabeleženog ulova.');
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('ULOV PO VRSTI'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: sorted.map((e) {
              final icon = fishIconAsset(e.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26, height: 26,
                      child: icon != null ? Image.asset(icon, fit: BoxFit.contain) : const Text('🐟', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)), overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: max > 0 ? e.value / max : 0,
                          minHeight: 12,
                          backgroundColor: const Color(0xFFE3F2FD),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF0277BD)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${e.value}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0277BD))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Which band of each condition yields the most fish-per-trip.
  List<Widget> _conditionInsights(List<DiaryEntry> e) {
    final widgets = <Widget>[];

    // Water temp (real, fallback air)
    final tempBest = _bestBand(e, (d) {
      final t = d.waterTempReal ?? d.airTemp;
      if (t == null) return null;
      if (t < 8) return '<8°C (hladno)';
      if (t < 14) return '8–14°C (sveže)';
      if (t <= 20) return '14–20°C (blago)';
      return '>20°C (toplo)';
    });
    if (tempBest != null) widgets.add(_insightCard('🌡', 'Temperatura vode', tempBest));

    // Water level trend
    final trendBest = _bestBand(e, (d) => d.waterTrend);
    if (trendBest != null) widgets.add(_insightCard('🌊', 'Vodostaj', trendBest));

    // Pressure band
    final pressBest = _bestBand(e, (d) {
      final p = d.pressure;
      if (p == null) return null;
      if (p < 1010) return '<1010 hPa (nizak)';
      if (p <= 1020) return '1010–1020 hPa';
      return '>1020 hPa (visok)';
    });
    if (pressBest != null) widgets.add(_insightCard('📊', 'Pritisak', pressBest));

    if (widgets.isEmpty) widgets.add(_hint('Nedovoljno podataka o uslovima.'));
    return widgets;
  }

  // Returns "label · avg X riba/izlazak" for the band with best average.
  String? _bestBand(List<DiaryEntry> entries, String? Function(DiaryEntry) classify) {
    final sums = <String, int>{};
    final counts = <String, int>{};
    for (final e in entries) {
      final band = classify(e);
      if (band == null) continue;
      sums[band] = (sums[band] ?? 0) + e.totalCatch;
      counts[band] = (counts[band] ?? 0) + 1;
    }
    if (sums.isEmpty) return null;
    String? best;
    double bestAvg = -1;
    sums.forEach((band, total) {
      final avg = total / counts[band]!;
      if (avg > bestAvg) { bestAvg = avg; best = band; }
    });
    if (best == null) return null;
    return '$best · ${bestAvg.toStringAsFixed(1)} riba/izlazak';
  }

  Widget _insightCard(String icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF546E7A))),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(String text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
        child: Text('ℹ️ $text', style: const TextStyle(fontSize: 12, color: Color(0xFF8D6E63), height: 1.4)),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Color(0xFF546E7A)));
}
