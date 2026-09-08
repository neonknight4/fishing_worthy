import 'dart:io';

import 'package:flutter/material.dart';

import '../models/diary_entry.dart';
import '../services/share_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'components.dart';

/// Fotografije ulova preko celog ekrana: swipe kroz slike, pinch/dupli tap zum,
/// deljenje tekuće slike (sa upečenom trakom — vidi [ShareCard]).
class PhotoViewerScreen extends StatefulWidget {
  final List<String> paths;
  final int initialIndex;

  /// Kad je zadat, gornja traka nudi deljenje (podaci iz unosa idu na sliku).
  final DiaryEntry? entry;

  const PhotoViewerScreen({
    super.key,
    required this.paths,
    this.initialIndex = 0,
    this.entry,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _page = PageController(initialPage: widget.initialIndex);
  late int _i = widget.initialIndex;
  bool _sharing = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final e = widget.entry;
    if (e == null || _sharing) return;
    setState(() => _sharing = true);
    await sharePhotos(context, e, [widget.paths[_i]]);
    if (mounted) setState(() => _sharing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: widget.paths.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => _Zoomable(path: widget.paths[i]),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(6, MediaQuery.of(context).padding.top + 6, 6, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  if (widget.paths.length > 1)
                    Text('${_i + 1} / ${widget.paths.length}',
                        style: context.ui(size: 13, weight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  if (widget.entry != null)
                    IconButton(
                      onPressed: _sharing ? null : _share,
                      icon: _sharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.share_outlined, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Zoomable extends StatefulWidget {
  final String path;
  const _Zoomable({required this.path});

  @override
  State<_Zoomable> createState() => _ZoomableState();
}

class _ZoomableState extends State<_Zoomable> {
  final _ctrl = TransformationController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleZoom(TapDownDetails d) {
    if (_ctrl.value != Matrix4.identity()) {
      _ctrl.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    final p = d.localPosition;
    _ctrl.value = Matrix4.identity()
      ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _toggleZoom,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _ctrl,
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Image.file(
            File(widget.path),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white24, size: 64),
          ),
        ),
      ),
    );
  }
}

/// Podeli [photos] iz unosa [e] — kartice se generišu u [ShareCard].
/// Stilovi se čitaju iz konteksta pre await-a (fontovi kao u aplikaciji).
/// Dok se slike pripremaju (~0.5s po slici) na ekranu stoji indikator, da
/// klik na share ne izgleda kao da ništa ne radi.
Future<void> sharePhotos(BuildContext context, DiaryEntry e, List<String> photos) async {
  final title = context.display(size: 52, weight: FontWeight.w800, height: 1.1);
  final place = context.ui(size: 30, weight: FontWeight.w700);
  final messenger = ScaffoldMessenger.of(context);
  final nav = Navigator.of(context, rootNavigator: true);

  if (photos.isNotEmpty) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      useRootNavigator: true,
      builder: (_) => _PreparingDialog(count: photos.length),
    );
  }
  try {
    final files = await ShareCard.prepare(
      e,
      photos: photos,
      titleStyle: title,
      placeStyle: place,
    );
    if (photos.isNotEmpty) nav.pop();
    await ShareCard.shareFiles(e, files);
  } catch (_) {
    if (photos.isNotEmpty && nav.canPop()) nav.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Deljenje nije uspelo.')));
  }
}

/// Deli slike **jednu po jednu**, sa pitanjem između: Facebook story od više
/// fajlova pravi kolaž u jednom story-ju, a ovako ide jedna slika = jedan story.
Future<void> sharePhotosOneByOne(
    BuildContext context, DiaryEntry e, List<String> photos) async {
  for (var i = 0; i < photos.length; i++) {
    if (!context.mounted) return;
    await sharePhotos(context, e, [photos[i]]);
    if (i == photos.length - 1 || !context.mounted) return;
    final next = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${i + 1} / ${photos.length} podeljeno'),
        content: const Text('Nastavi sa sledećom slikom?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Dosta')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sledeća')),
        ],
      ),
    );
    if (next != true) return;
  }
}

/// Ponudi način deljenja kad ima više slika: sve odjednom (feed / karusel) ili
/// jedna po jedna (story). Sa jednom slikom pitanje nema smisla — deli odmah.
Future<void> shareEntryPhotos(BuildContext context, DiaryEntry e) async {
  final photos = [...e.photos];
  if (photos.length < 2) {
    await sharePhotos(context, e, photos);
    return;
  }
  final oneByOne = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = ctx.c;
      return Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
        decoration: BoxDecoration(
            color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            AppButton('Sve ${photos.length} odjednom', icon: Icons.collections_outlined, block: true,
                onTap: () => Navigator.pop(ctx, false)),
            const SizedBox(height: 6),
            Text('Feed post ili karusel', style: ctx.ui(size: 11.5, weight: FontWeight.w500, color: c.muted)),
            const SizedBox(height: 14),
            AppButton('Jednu po jednu', icon: Icons.auto_stories_outlined,
                kind: BtnKind.outline, block: true, onTap: () => Navigator.pop(ctx, true)),
            const SizedBox(height: 6),
            Text('Za story — inače Facebook spoji sve u jedan',
                style: ctx.ui(size: 11.5, weight: FontWeight.w500, color: c.muted)),
          ],
        ),
      );
    },
  );
  if (oneByOne == null || !context.mounted) return;
  if (oneByOne) {
    await sharePhotosOneByOne(context, e, photos);
  } else {
    await sharePhotos(context, e, photos);
  }
}

class _PreparingDialog extends StatelessWidget {
  final int count;
  const _PreparingDialog({required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(AppRadius.m)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: c.green),
            ),
            const SizedBox(width: 14),
            Text(count > 1 ? 'Pripremam $count slike…' : 'Pripremam sliku…',
                style: context.ui(size: 13.5, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
