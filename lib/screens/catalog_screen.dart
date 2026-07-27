import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

/// Traper katalog 2026 — PDF čitač.
///
/// Za sada čita bundlovani asset (offline). Kad m-fishing okači katalog na
/// server, zameni `_prepare()` download-om + keširanjem (isti `_path` izlaz),
/// i skini asset iz pubspec-a da app ostane mala.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const _asset = 'assets/catalog/traper_katalog_2026.pdf';
  String? _path;
  bool _error = false;
  int _pages = 0;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final data = await rootBundle.load(_asset);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/traper_katalog_2026.pdf');
      if (!await file.exists() || await file.length() != data.lengthInBytes) {
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
      if (mounted) setState(() => _path = file.path);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Traper katalog 2026',
            subtitle: _pages > 0 ? 'Strana ${_current + 1} / $_pages' : 'u saradnji sa m-fishing.rs',
            showBack: true,
          ),
          Expanded(
            child: _error
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Katalog trenutno nije dostupan.',
                          textAlign: TextAlign.center,
                          style: context.ui(size: 14, weight: FontWeight.w500, color: c.muted)),
                    ),
                  )
                : _path == null
                    ? const Center(child: CircularProgressIndicator())
                    : PDFView(
                        filePath: _path!,
                        swipeHorizontal: false,
                        fitPolicy: FitPolicy.WIDTH,
                        onRender: (p) => setState(() => _pages = p ?? 0),
                        onPageChanged: (p, _) => setState(() => _current = p ?? 0),
                      ),
          ),
        ],
      ),
    );
  }
}
