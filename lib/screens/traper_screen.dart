import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

/// Traper tab — hub za primame (katalog + kombinacije po vodi/sezoni).
/// Sadržaj se dogovara; za sada placeholder.
class TraperScreen extends StatelessWidget {
  final bool showBack;
  const TraperScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: 'Traper', subtitle: 'Primame i kombinacije', showBack: showBack),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/brand/fish-teal.png', width: 64, height: 48, fit: BoxFit.contain),
                    const SizedBox(height: 14),
                    Text('Traper hub', style: context.display(size: 18)),
                    const SizedBox(height: 6),
                    Text('Katalog proizvoda + 80 kombinacija po vodi i sezoni. Sadržaj u dogovoru.',
                        textAlign: TextAlign.center,
                        style: context.ui(size: 13, weight: FontWeight.w500, color: c.muted, height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
