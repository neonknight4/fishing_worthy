import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/diary_entry.dart';

/// Link ka aplikaciji na Play-u (ide u tekst posta).
const kPlayUrl = 'https://play.google.com/store/apps/details?id=rs.upecaj.app';

/// Deljenje ulova: fotografija + "traka" upečena u sliku + Upecaj! logo.
/// Traka nosi **samo vodu i datum** — bez tačne lokacije, ulova i uslova:
/// pecaroši ne dele svoje mesto. Traka je deo piksela, pa brend ostaje i kad
/// slika ode na FB ili Instagram.
class ShareCard {
  // Kadar je **kvadrat 1080×1080**. Instagram feed pri objavi više slika
  // nametne 1:1 svima, pa mu odmah dajemo 1:1 — ništa ne kropuje, traka sa
  // brendom je uvek cela unutra. Fotografija se ne reže: stoji cela, a
  // pozadinu popunjava njena zamućena kopija (nema mrtvog praznog prostora,
  // radi isto za portret, pejzaž i panoramu).
  static const _w = 1080;
  static const _h = 1080;
  static const _stripH = 152.0;
  static const _stripTop = _h - _stripH; // 928
  static const _photoInset = 26.0; // margina fotografije u odnosu na kadar
  static const _pad = 44.0;

  static const _cream = Color(0xFFF4EFE1);
  static const _green2 = Color(0xFF16482A);
  static const _greenInk = Color(0xFF0F3A22);
  static const _gold = Color(0xFFE0A02F);

  static ui.Image? _logo;

  /// Napravi kartice za [photos]. Traje ~0.3–0.5s po slici (dekodiranje +
  /// crtanje + PNG), zato je odvojeno od [shareFiles] — pozivalac za to vreme
  /// drži indikator na ekranu.
  ///
  /// Stilove prima izvana (`context.display` / `context.ui`) da bi kartica
  /// koristila iste fontove kao aplikacija.
  static Future<List<XFile>> prepare(
    DiaryEntry e, {
    required List<String> photos,
    required TextStyle titleStyle,
    required TextStyle placeStyle,
  }) async {
    if (photos.isEmpty) return const [];
    final dir = await _shareDir();
    final logo = await _brandLogo();
    final files = <XFile>[];
    for (var i = 0; i < photos.length; i++) {
      final f = await _renderCard(
        src: photos[i],
        dir: dir,
        index: i,
        logo: logo,
        title: _waterLine(e),
        date: _date(e.date),
        titleStyle: titleStyle,
        placeStyle: placeStyle,
      );
      // Ako obrada padne, podeli original — bolje nego ništa.
      files.add(XFile(f?.path ?? photos[i]));
    }
    return files;
  }

  /// Otvori sistemski share sheet. Bez fajlova deli se samo tekst.
  static Future<void> shareFiles(DiaryEntry e, List<XFile> files) async {
    final caption = buildCaption(e);
    await SharePlus.instance.share(
      files.isEmpty
          ? ShareParams(text: caption, subject: _subject(e))
          : ShareParams(files: files, text: caption, subject: _subject(e)),
    );
  }

  // ── tekst ───────────────────────────────────────────────────────────────

  static String _subject(DiaryEntry e) => 'Ulov · ${_waterLine(e)}';

  /// Tekst posta (share sheet ga ubacuje u FB/mejl/WhatsApp).
  /// Isto pravilo kao na slici — voda i datum, bez lokacije i detalja.
  static String buildCaption(DiaryEntry e) => [
        '${_waterLine(e)} · ${_date(e.date)}',
        '',
        'Zabeleženo u Upecaj! — prognoza za pecanje, vodostaj i primame',
        kPlayUrl,
      ].join('\n');

  /// Samo ribolovna voda. Ako voda nije poznata, ostaje uneta lokacija.
  static String _waterLine(DiaryEntry e) => e.water ?? e.location;

  static String _date(DateTime d) =>
      '${_two(d.day)}.${_two(d.month)}.${d.year}.';

  static String _two(int v) => v.toString().padLeft(2, '0');

  // ── render ──────────────────────────────────────────────────────────────

  static Future<Directory> _shareDir() async {
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/share');
    if (await dir.exists()) {
      // Očisti prethodni share da temp ne raste.
      for (final f in dir.listSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    } else {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<ui.Image?> _brandLogo() async {
    if (_logo != null) return _logo;
    try {
      final data = await rootBundle.load('assets/brand/lockup-dark.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 600,
      );
      _logo = (await codec.getNextFrame()).image;
    } catch (_) {
      _logo = null;
    }
    return _logo;
  }

  static Future<File?> _renderCard({
    required String src,
    required Directory dir,
    required int index,
    required ui.Image? logo,
    required String title,
    required String date,
    required TextStyle titleStyle,
    required TextStyle placeStyle,
  }) async {
    try {
      final bytes = await File(src).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: _w * 2);
      final img = (await codec.getNextFrame()).image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const full = Rect.fromLTWH(0, 0, _w * 1.0, _h * 1.0);
      final srcFull = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());

      // 1) Pozadina: ista slika razvučena preko celog kadra i zamućena.
      //    Malo je preko ivica (×1.12) da zamućenje ne "izbledi" na krajevima.
      final bgScale =
          math.max(_w / img.width, _h / img.height) * 1.12;
      final bgW = img.width * bgScale;
      final bgH = img.height * bgScale;
      canvas.drawImageRect(
        img,
        srcFull,
        Rect.fromLTWH((_w - bgW) / 2, (_h - bgH) / 2, bgW, bgH),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..imageFilter = ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
      );
      canvas.drawRect(full, Paint()..color = Colors.black.withValues(alpha: 0.30));

      // 2) Fotografija: cela, uklopljena u polje iznad trake, zaobljena.
      final boxW = _w - 2 * _photoInset;
      final boxH = _stripTop - 2 * _photoInset;
      final fit = math.min(boxW / img.width, boxH / img.height);
      final fw = img.width * fit;
      final fh = img.height * fit;
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH((_w - fw) / 2, _photoInset + (boxH - fh) / 2, fw, fh),
        const Radius.circular(18),
      );
      canvas.save();
      canvas.clipRRect(rr);
      canvas.drawImageRect(img, srcFull, rr.outerRect,
          Paint()..filterQuality = FilterQuality.high);
      canvas.restore();

      // 3) Diskretan znak u gornjem desnom uglu fotografije.
      if (logo != null) {
        const h = 46.0;
        final w = h * logo.width / logo.height;
        canvas.drawImageRect(
          logo,
          Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
          Rect.fromLTWH(rr.right - w - 14, rr.top + 14, w, h),
          Paint()..color = Colors.white.withValues(alpha: 0.60),
        );
      }

      // 4) Traka sa vodom i datumom.
      canvas.drawRect(
        Rect.fromLTWH(0, _stripTop, _w * 1.0, _stripH),
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, _stripTop),
            const Offset(_w * 1.0, _h * 1.0),
            [_green2, _greenInk],
          ),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, _stripTop, _w * 1.0, 5),
        Paint()..color = _gold,
      );

      var textW = _w - 2 * _pad;
      if (logo != null) {
        const h = 66.0;
        final w = h * logo.width / logo.height;
        canvas.drawImageRect(
          logo,
          Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
          Rect.fromLTWH(_w - w - _pad, _stripTop + (_stripH - h) / 2, w, h),
          Paint(),
        );
        textW -= w + 24;
      }

      var y = _stripTop + 26;
      y += _line(canvas, title, titleStyle.copyWith(color: _cream), textW, y) + 12;
      _line(canvas, date, placeStyle.copyWith(color: _cream.withValues(alpha: 0.80)),
          textW, y);

      final picture = recorder.endRecording();
      final out = await picture.toImage(_w, _h);
      final png = await out.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      out.dispose();
      if (png == null) return null;

      final file = File('${dir.path}/upecaj_ulov_${index + 1}.png');
      await file.writeAsBytes(png.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Iscrta jedan red teksta i vrati njegovu visinu.
  static double _line(
      Canvas canvas, String text, TextStyle style, double maxWidth, double y) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(_pad, y));
    return tp.height;
  }
}
