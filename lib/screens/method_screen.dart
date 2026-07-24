import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

/// Method tab — hub za tehnike/montaže (feeder / method / plovak / varalica).
/// Sadržaj se dogovara; za sada placeholder.
class MethodScreen extends StatelessWidget {
  final bool showBack;
  const MethodScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: 'Method', subtitle: 'Tehnike i montaže', showBack: showBack),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phishing, size: 56, color: c.faint),
                    const SizedBox(height: 14),
                    Text('Method hub', style: context.display(size: 18)),
                    const SizedBox(height: 6),
                    Text('Vodič kroz tehnike, montaže i plan hranjenja. Sadržaj u dogovoru.',
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
