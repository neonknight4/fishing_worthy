import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Deljene UI komponente redizajna ("moderan outdoor dashboard").
/// Sve boje/senke idu iz [AppColors] (context.c), tipografija iz context.display/ui.

// ─────────────────────────── PAGE HEADER ───────────────────────────
/// Vrh ekrana (CSS `.topbar`): naslov (Baloo) + podnaslov + opcioni back/akcije.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget> actions;
  const PageHeader(
      {super.key, required this.title, this.subtitle, this.showBack = false, this.actions = const []});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Row(
          children: [
            if (showBack) ...[
              AppIconButton(Icons.arrow_back, onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.display(size: 22)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: context.ui(size: 12.5, weight: FontWeight.w600, color: c.muted)),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── CARD ───────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool flat;
  final VoidCallback? onTap;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.flat = false,
    this.onTap,
    this.radius = AppRadius.m,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: flat ? null : c.shadow,
        border: flat ? Border.all(color: c.line) : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

// ─────────────────────────── CHIP ───────────────────────────
enum ChipTone { neutral, green, water, gold, warn }

class AppChip extends StatelessWidget {
  final String label;
  final ChipTone tone;
  final bool small;
  final IconData? icon;
  const AppChip(this.label,
      {super.key, this.tone = ChipTone.neutral, this.small = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color bg, fg;
    switch (tone) {
      case ChipTone.neutral:
        bg = c.surface3;
        fg = c.ink;
      case ChipTone.green:
        bg = c.green.withValues(alpha: 0.16);
        fg = c.green;
      case ChipTone.water:
        bg = c.water.withValues(alpha: 0.18);
        fg = c.water2;
      case ChipTone.gold:
        bg = c.gold.withValues(alpha: 0.22);
        fg = c.gold;
      case ChipTone.warn:
        bg = c.coral.withValues(alpha: 0.16);
        fg = c.coral;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 9 : 11, vertical: small ? 5 : 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: context.ui(
                  size: small ? 11.5 : 12.5, weight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

// ─────────────────────── SECTION LABEL / HEADER ───────────────────────
/// Uppercase muted labela sa linijom (CSS `.sect`).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Tekst mora da ostane neflex-ovan da bi linija popunila ostatak reda, ali
    // bez gornje granice dug naslov prelije red. Otud LayoutBuilder: naslov se
    // kapira na širinu reda i prelomi, a linija dobije ono što ostane (i 0).
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 26, 2, 13),
      child: LayoutBuilder(
        builder: (context, box) => Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: (box.maxWidth - 9).clamp(0, double.infinity)),
              child: Text(text.toUpperCase(),
                  maxLines: 2,
                  style: context.ui(
                      size: 12, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.7)),
            ),
            const SizedBox(width: 9),
            Expanded(child: Container(height: 1, color: c.line)),
          ],
        ),
      ),
    );
  }
}

/// Baloo naslov sekcije (CSS `.sect-h`).
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 24, 2, 12),
      child: Text(text, style: context.display(size: 19, weight: FontWeight.w700)),
    );
  }
}

// ─────────────────────────── BUTTONS ───────────────────────────
enum BtnKind { primary, water, ghost, outline }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final BtnKind kind;
  final bool block;
  final bool large;
  final VoidCallback? onTap;
  const AppButton(
    this.label, {
    super.key,
    this.icon,
    this.kind = BtnKind.primary,
    this.block = false,
    this.large = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    late Color bg, fg;
    Border? border;
    List<BoxShadow>? shadow;
    switch (kind) {
      case BtnKind.primary:
        bg = c.green;
        fg = c.onBrand;
      case BtnKind.water:
        bg = c.water;
        fg = Colors.white;
      case BtnKind.ghost:
        bg = c.surface;
        fg = c.ink;
        shadow = c.shadow;
      case BtnKind.outline:
        bg = Colors.transparent;
        fg = c.ink;
        border = Border.all(color: c.line, width: 1.5);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(large ? 16 : 14),
        child: Container(
          width: block ? double.infinity : null,
          padding: EdgeInsets.symmetric(
              horizontal: large ? 20 : 18, vertical: large ? 17 : 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(large ? 16 : 14),
            border: border,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: large ? 20 : 18, color: fg),
                const SizedBox(width: 9),
              ],
              // U block dugmetu je širina ograničena, pa labela sme da se
              // skupi — bez ovoga dug tekst („Pročitaj na feeder.rs") prelije
              // red. Non-block dugme ostaje neflex-ovano, jer može da stoji u
              // neograničenom Row-u gde Flexible pukne.
              block
                  ? Flexible(
                      child: Text(label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.ui(
                              size: large ? 17 : 15.5,
                              weight: FontWeight.w700,
                              color: fg)),
                    )
                  : Text(label,
                      style: context.ui(
                          size: large ? 17 : 15.5, weight: FontWeight.w700, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kvadratno ikonično dugme (CSS `.iconbtn`).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool ghost;
  final double size;
  const AppIconButton(this.icon,
      {super.key, this.onTap, this.ghost = false, this.size = 40});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: ghost ? Colors.transparent : c.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: ghost ? null : c.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 20, color: c.ink),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── LIST ROW ───────────────────────────
class ListRowCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const ListRowCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: c.surface3, borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Center(child: leading),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.ui(size: 15, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (subtitle != null)
                  Text(subtitle!,
                      style: context.ui(
                          size: 12.5, weight: FontWeight.w500, color: c.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}

// ─────────────────────────── WARN BANNER ───────────────────────────
class WarnBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const WarnBanner(
      {super.key, this.icon = Icons.warning_amber_rounded, required this.title, required this.message});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.coral.withValues(alpha: 0.12), c.surface),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: c.coral.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c.coral, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.ui(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(message,
                    style: context.ui(
                        size: 12.5, weight: FontWeight.w500, color: c.muted, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── COLLAPSIBLE ───────────────────────────
class Collapsible extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyOpen;
  const Collapsible(
      {super.key, required this.title, required this.child, this.initiallyOpen = false});
  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  late bool _open = widget.initiallyOpen;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(margin: const EdgeInsets.only(top: 10), height: 1, color: c.line),
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 13, 0, 3),
            child: Row(
              children: [
                Expanded(
                    child: Text(widget.title,
                        style: context.ui(size: 14, weight: FontWeight.w700))),
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right, size: 20, color: c.muted),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
            child: widget.child,
          ),
          crossFadeState:
              _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────── HALF GAUGE ───────────────────────────
/// Poluluk merač skora (CSS `Gauge`): 180° luk, popuna po vrednosti 0–100.
class HalfGauge extends StatelessWidget {
  final double value; // 0–100
  final double width;
  final Color color;
  final Color trackColor;
  final double stroke;
  const HalfGauge({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.width = 112,
    this.stroke = 11,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.56),
      painter: _GaugePainter(value.clamp(0, 100) / 100, color, trackColor, stroke),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double t;
  final Color color, track;
  final double stroke;
  _GaugePainter(this.t, this.color, this.track, this.stroke);
  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: r);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, math.pi, math.pi, false, base);
    if (t > 0) {
      final fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, math.pi, math.pi * t, false, fill);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter o) =>
      o.t != t || o.color != color || o.track != track;
}

// ─────────────────────────── CONDITION TILE ───────────────────────────
enum Trend { up, down, flat }

class ConditionTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? unit;
  final String label;
  final String? delta;
  final Trend trend;
  const ConditionTile({
    super.key,
    required this.icon,
    required this.value,
    this.unit,
    required this.label,
    this.delta,
    this.trend = Trend.flat,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final trendColor =
        trend == Trend.up ? c.good : trend == Trend.down ? c.coral : c.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.s),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: c.water),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              text: value,
              style: context.display(size: 19, weight: FontWeight.w700),
              children: [
                if (unit != null)
                  TextSpan(
                      text: ' $unit',
                      style: context.ui(
                          size: 11, weight: FontWeight.w700, color: c.muted)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Ploča stoji u ćeliji fiksne visine, a labele poput „Vetar SZ" se
          // prelamaju u dva reda — bez Flexible-a to prelije ćeliju.
          Flexible(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.ui(size: 11, weight: FontWeight.w600, color: c.muted)),
          ),
          if (delta != null) ...[
            const SizedBox(height: 2),
            Text(delta!,
                style: context.ui(
                    size: 10.5, weight: FontWeight.w700, color: trendColor)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────── FACTOR ROW ───────────────────────────
/// Grupisane +/− stavke skora unutar jednog zaobljenog bloka.
class FactorList extends StatelessWidget {
  final List<FactorItem> items;
  const FactorList(this.items, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.m),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Container(height: 1, color: c.line),
            _FactorRow(items[i]),
          ],
        ],
      ),
    );
  }
}

class FactorItem {
  final bool positive;
  final String title;
  final String? sub;
  const FactorItem({required this.positive, required this.title, this.sub});
}

class _FactorRow extends StatelessWidget {
  final FactorItem f;
  const _FactorRow(this.f);
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tone = f.positive ? c.good : c.coral;
    return Container(
      color: c.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(f.positive ? '+' : '–',
                style: context.ui(size: 15, weight: FontWeight.w800, color: tone)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title, style: context.ui(size: 14, weight: FontWeight.w700)),
                if (f.sub != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(f.sub!,
                        style: context.ui(
                            size: 12, weight: FontWeight.w500, color: c.muted)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── MOON VISUAL ───────────────────────────
/// Krug meseca sa senkom po osvetljenosti 0–1 (CSS `MoonVis`).
class MoonVis extends StatelessWidget {
  final double illum; // 0–1
  final double size;
  const MoonVis({super.key, required this.illum, this.size = 60});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c.line, spreadRadius: 1, blurRadius: 0)],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9E2C9), Color(0xFFC9C2A6)],
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: size * (1 - illum.clamp(0, 1)),
          height: size,
          decoration: BoxDecoration(
            color: c.surface3,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── OSM ATTRIBUTION ───────────────────────────
/// Obavezna atribucija za OpenStreetMap tile-ove (OSMF tile usage policy).
/// Stavlja se u Stack preko FlutterMap-a; tap otvara copyright stranicu.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Positioned(
      right: 6,
      bottom: 6,
      child: GestureDetector(
        onTap: () => launchUrl(
          Uri.parse('https://www.openstreetmap.org/copyright'),
          mode: LaunchMode.externalApplication,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Text('© OpenStreetMap',
              style: context.ui(size: 9.5, weight: FontWeight.w600, color: c.muted)),
        ),
      ),
    );
  }
}

// ─────────────────────────── BOTTOM SHEET ───────────────────────────

/// Zajednička školjka za bottom sheet: hvatalica, opcioni naslov, skrolabilno
/// telo i fiksiran podnožni deo.
///
/// Bez ovoga svaki sheet sa listom preraste ekran — `showModalBottomSheet`
/// podrazumevano seče na pola visine, a Column sa `mainAxisSize.min` nema
/// skrol pa prijavi overflow. Ovde: `maxHeight` je deo ekrana, telo skroluje,
/// `viewInsets` prima tastaturu, a `padding.bottom` sistemsku navigaciju.
///
/// Pozivalac MORA da prosledi `isScrollControlled: true`, inače sheet i dalje
/// ne može da pređe pola ekrana.
class AppSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  /// Ostaje prikovan na dnu, van skrola — tu idu akcije (dugmad), da budu
  /// dohvatljive i kad je tastatura otvorena.
  final Widget? footer;

  final double maxHeightFactor;

  const AppSheet({
    super.key,
    this.title,
    required this.child,
    this.footer,
    this.maxHeightFactor = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * maxHeightFactor),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration:
                    BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Text(title!, style: context.display(size: 18)),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, footer == null ? safeBottom + 22 : 10),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20, 2, 20, safeBottom + 16),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
