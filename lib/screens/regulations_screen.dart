import 'package:flutter/material.dart';
import '../data/fishing_seasons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/fish_icons.dart';
import '../widgets/components.dart';

class RegulationsScreen extends StatelessWidget {
  final bool showBack;
  const RegulationsScreen({super.key, this.showBack = true});

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
      body: Column(
        children: [
          PageHeader(
            title: 'Propisi i lovostaj',
            subtitle: closedCount > 0 ? '$closedCount u lovostaju danas' : 'Sve dozvoljeno danas',
            showBack: showBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              children: [
                const WarnBanner(
                  icon: Icons.gavel,
                  title: 'Poštuj lovostaj',
                  message: 'Ribe u lovostaju ili ispod minimalne mere obavezno vrati u vodu.',
                ),
                const SizedBox(height: 14),
                for (final r in regs) ...[
                  _FishRegRow(reg: r, today: today),
                  const SizedBox(height: 9),
                ],
                const SizedBox(height: 4),
                _disclaimer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface3,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Text(
        'ℹ️ Lovostaj i minimalne mere prema propisima RS. Datumi mogu varirati po '
        'ribolovnom području — proveri kod lokalnog ribolovačkog udruženja.',
        style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted, height: 1.4),
      ),
    );
  }
}

class _FishRegRow extends StatelessWidget {
  final FishReg reg;
  final DateTime today;
  const _FishRegRow({required this.reg, required this.today});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final closed = reg.isClosedOn(today);
    final icon = fishIconAsset(reg.name);
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: c.surface3, borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: icon != null
                      ? Image.asset(icon, width: 40, height: 40, fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Text('🐟', style: TextStyle(fontSize: 24)))
                      : const Text('🐟', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(reg.name, style: context.display(size: 16))),
              AppChip(
                closed ? 'U lovostaju' : 'Dozvoljeno',
                tone: closed ? ChipTone.warn : ChipTone.green,
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (reg.hasClosedSeason)
                _pill(context, Icons.event_busy, 'Lovostaj: ${reg.dateRange}',
                    tone: closed ? c.coral : c.gold)
              else
                _pill(context, Icons.check_circle_outline, reg.note ?? 'Bez lovostaja', tone: c.green),
              if (reg.minSizeCm != null)
                _pill(context, Icons.straighten, 'Min. ${reg.minSizeCm} cm', tone: c.water2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String text, {required Color tone}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone),
          const SizedBox(width: 5),
          Text(text, style: context.ui(size: 12, weight: FontWeight.w700, color: tone)),
        ],
      ),
    );
  }
}
