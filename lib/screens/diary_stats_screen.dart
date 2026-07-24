import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/fish_icons.dart';
import '../widgets/components.dart';

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
      body: Column(
        children: [
          const PageHeader(title: 'Statistika', subtitle: 'Uvidi iz dnevnika', showBack: true),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text('Nema dovoljno unosa za statistiku',
                        style: context.ui(color: context.c.muted)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    children: [
                      _summaryRow(context, entries.length, totalFish),
                      const SectionHeader('Ulov po vrsti'),
                      _speciesSection(context),
                      if (withCatch.length >= 2) ...[
                        const SectionHeader('Najbolji uslovi za ulov'),
                        ..._conditionInsights(context, withCatch),
                      ] else
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _hint(context, 'Zabeleži bar 2 izlaska sa ulovom da vidiš obrasce uslova.'),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, int trips, int fish) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: _statCard(context, '$trips', 'izlazaka')),
          const SizedBox(width: 10),
          Expanded(child: _statCard(context, '$fish', 'riba ukupno')),
          const SizedBox(width: 10),
          Expanded(child: _statCard(context, trips > 0 ? (fish / trips).toStringAsFixed(1) : '0', 'po izlasku')),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.display(size: 26, weight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(label, style: context.ui(size: 11, weight: FontWeight.w700, color: c.muted)),
        ],
      ),
    );
  }

  Widget _speciesSection(BuildContext context) {
    final c = context.c;
    final counts = <String, int>{};
    for (final e in entries) {
      for (final ct in e.catches) {
        counts[ct.species] = (counts[ct.species] ?? 0) + ct.count;
      }
    }
    if (counts.isEmpty) return _hint(context, 'Još nema zabeleženog ulova.');
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return AppCard(
      child: Column(
        children: sorted.map((e) {
          final icon = fishIconAsset(e.key);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: icon != null ? Image.asset(icon, fit: BoxFit.contain) : const Text('🐟', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 74,
                  child: Text(e.key, style: context.ui(size: 13, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: max > 0 ? e.value / max : 0,
                      minHeight: 12,
                      backgroundColor: c.surface3,
                      valueColor: AlwaysStoppedAnimation(c.green),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${e.value}', style: context.ui(size: 13, weight: FontWeight.w700, color: c.green)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Which band of each condition yields the most fish-per-trip.
  List<Widget> _conditionInsights(BuildContext context, List<DiaryEntry> e) {
    final widgets = <Widget>[];

    final tempBest = _bestBand(e, (d) {
      final t = d.waterTempReal ?? d.airTemp;
      if (t == null) return null;
      if (t < 8) return '<8°C (hladno)';
      if (t < 14) return '8–14°C (sveže)';
      if (t <= 20) return '14–20°C (blago)';
      return '>20°C (toplo)';
    });
    if (tempBest != null) widgets.add(_insightCard(context, Icons.thermostat, 'Temperatura vode', tempBest));

    final trendBest = _bestBand(e, (d) => d.waterTrend);
    if (trendBest != null) widgets.add(_insightCard(context, Icons.water, 'Vodostaj', trendBest));

    final pressBest = _bestBand(e, (d) {
      final p = d.pressure;
      if (p == null) return null;
      if (p < 1010) return '<1010 mbar (nizak)';
      if (p <= 1020) return '1010–1020 mbar';
      return '>1020 mbar (visok)';
    });
    if (pressBest != null) widgets.add(_insightCard(context, Icons.speed, 'Pritisak', pressBest));

    if (widgets.isEmpty) widgets.add(_hint(context, 'Nedovoljno podataka o uslovima.'));
    return widgets;
  }

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

  Widget _insightCard(BuildContext context, IconData icon, String label, String value) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: c.surface3, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: c.water),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.ui(size: 11, weight: FontWeight.w700, color: c.muted)),
                  const SizedBox(height: 3),
                  Text(value, style: context.ui(size: 13, weight: FontWeight.w700, color: c.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(BuildContext context, String text) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surface3, borderRadius: BorderRadius.circular(AppRadius.s)),
      child: Text('ℹ️ $text', style: context.ui(size: 12, weight: FontWeight.w500, color: c.muted, height: 1.4)),
    );
  }
}
