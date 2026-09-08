import 'package:flutter/material.dart';
import '../data/traper_baits.dart';
import '../models/bait_product.dart';
import '../services/shop_link.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'catalog_screen.dart';

/// Traper tab — kratak opis brenda + katalog 2026. Native, suptilno:
/// vrednost (opis proizvoda) prva, meki "Kupi na m-fishing" bez pritiska.
class TraperScreen extends StatelessWidget {
  final bool showBack;
  const TraperScreen({super.key, this.showBack = false});

  static const _sections = [
    (BaitCategory.groundbait, 'Primame'),
    (BaitCategory.pellet, 'Peleti'),
    (BaitCategory.additive, 'Aditivi'),
    (BaitCategory.partikl, 'Partikl'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: 'Traper', subtitle: 'u saradnji sa m-fishing.rs', showBack: showBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
              children: [
                const _BrandCard(),
                const SizedBox(height: 10),
                _CatalogCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CatalogScreen()),
                  ),
                ),
                for (final s in _sections)
                  ..._categorySection(context, s.$1, s.$2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _categorySection(BuildContext context, BaitCategory cat, String label) {
    final items = traperBaits.where((p) => p.category == cat).toList();
    if (items.isEmpty) return const [];
    return [
      SectionLabel('$label · ${items.length}'),
      for (final p in items) ...[
        _ProductCard(product: p),
        const SizedBox(height: 9),
      ],
    ];
  }
}

class _CatalogCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CatalogCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListRowCard(
      onTap: onTap,
      leading: Icon(Icons.menu_book, color: c.green, size: 22),
      title: 'Katalog 2026',
      subtitle: '264 strane · PDF',
      trailing: Icon(Icons.chevron_right, color: c.faint, size: 20),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard();
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: c.shadow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.green2, c.greenInk],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRAPER',
                    style: context.display(size: 22, color: const Color(0xFFF4EFE1))
                        .copyWith(letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text(
                  'Poljski proizvođač primama, peleta i aditiva za feeder i method '
                  'ribolov. Asortiman za srpske vode dostupan preko m-fishing.rs.',
                  style: context.ui(
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: const Color(0xFFF4EFE1),
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset('assets/brand/fish-cream.png', width: 40, height: 30, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final BaitProduct product;
  const _ProductCard({required this.product});

  Future<void> _open() => ShopLink.open(product.productUrl, placement: 'katalog');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasShop = product.productUrl != null;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: hasShop ? _open : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(product.imageAsset, width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    SizedBox(width: 60, height: 60, child: Icon(Icons.image_not_supported, size: 26, color: c.faint))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(product.name, style: context.ui(size: 13.5, weight: FontWeight.w700))),
                    if (product.flagship) ...[
                      const SizedBox(width: 6),
                      const Text('⭐', style: TextStyle(fontSize: 11)),
                    ],
                  ],
                ),
                Text('${product.line} · ${product.flavorColor}',
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted)),
                const SizedBox(height: 2),
                Text(product.shortDesc,
                    style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted, height: 1.3)),
                if (hasShop) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront, size: 13, color: c.green),
                      const SizedBox(width: 4),
                      Text('Kupi na m-fishing.rs',
                          style: context.ui(size: 10.5, weight: FontWeight.w700, color: c.green).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: c.green.withValues(alpha: 0.4))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
