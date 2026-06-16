import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../utils/fish_icons.dart';

class RegulationsScreen extends StatelessWidget {
  const RegulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // Closed-now first, then by name
    final regs = [...iconFishRegulations]..sort((a, b) {
        final ca = a.isClosedOn(today) ? 0 : 1;
        final cb = b.isClosedOn(today) ? 0 : 1;
        if (ca != cb) return ca - cb;
        return a.name.compareTo(b.name);
      });

    final closedCount = regs.where((r) => r.isClosedOn(today)).length;

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
            const Text('Lovostaj i mere', style: TextStyle(fontSize: 16)),
            Text(
              closedCount > 0
                  ? '$closedCount u lovostaju danas'
                  : 'Sve dozvoljeno danas',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          for (final r in regs) _FishRegCard(reg: r, today: today),
          const SizedBox(height: 8),
          const _Disclaimer(),
        ],
      ),
    );
  }
}

class _FishRegCard extends StatelessWidget {
  final FishReg reg;
  final DateTime today;
  const _FishRegCard({required this.reg, required this.today});

  @override
  Widget build(BuildContext context) {
    final closed = reg.isClosedOn(today);
    final icon = fishIconAsset(reg.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: closed ? const Color(0xFFEF9A9A) : Colors.grey.shade200,
          width: closed ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: icon != null
                ? Image.asset(icon, fit: BoxFit.contain)
                : const Text('🐟', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reg.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                if (reg.hasClosedSeason)
                  Text(
                    'Lovostaj: ${reg.dateRange}',
                    style: TextStyle(
                      fontSize: 12,
                      color: closed ? const Color(0xFFC62828) : Colors.grey.shade600,
                      fontWeight: closed ? FontWeight.w600 : FontWeight.normal,
                    ),
                  )
                else
                  Text(
                    reg.note ?? 'Bez lovostaja',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (reg.minSizeCm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'min ${reg.minSizeCm} cm',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0277BD),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: closed ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  closed ? '🚫 Zabranjeno' : '✓ Dozvoljeno',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: closed ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'ℹ️ Lovostaj i minimalne mere prema propisima RS. Datumi mogu varirati po '
        'ribolovnom području — proveri kod lokalnog ribolovačkog udruženja.',
        style: TextStyle(fontSize: 11, color: Color(0xFF8D6E63), height: 1.4),
      ),
    );
  }
}
