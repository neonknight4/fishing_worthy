import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/school_lessons.dart';
import '../models/school_lesson.dart';
import '../services/school_progress_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

/// Škola tab — lekcije o ribolovu, filtrirane po temi; nivo znanja se prikazuje
/// i sortira po njemu, ali se ne filtrira.
/// Lista je direktorijum (brzo traženje na vodi), a lekcija je pun članak.
/// Sadržaj: `lib/data/school_lessons.dart`.
class SchoolScreen extends StatefulWidget {
  final bool showBack;
  const SchoolScreen({super.key, this.showBack = false});

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  Kind _kind = Kind.ucenje; // prekidač na vrhu: lekcije ili blog
  Topic? _topic; // null = sve teme
  Set<String> _read = const {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
    schoolProgressRevision.addListener(_loadProgress);
  }

  @override
  void dispose() {
    schoolProgressRevision.removeListener(_loadProgress);
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final r = await SchoolProgressService.read();
    if (mounted) setState(() => _read = r);
  }

  /// Blog je prazan dok nema naših tekstova — prekidač se tada ne prikazuje,
  /// da tab ne vodi u prazno (ista greška kao nekadašnji Method tab).
  static final bool _hasBlog =
      schoolLessons.any((l) => l.kind == Kind.blog);

  List<SchoolLesson> get _filtered {
    final list = schoolLessons
        .where((l) => l.kind == _kind)
        .where((l) => _topic == null || l.tags.contains(_topic))
        .toList();
    // Unutar teme lekcije idu od početnika ka naprednom.
    list.sort((a, b) {
      final t = a.primaryTag.index.compareTo(b.primaryTag.index);
      return t != 0 ? t : a.level.index.compareTo(b.level.index);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _filtered;
    // Grupisanje po temi ima smisla samo kad tema nije već izabrana.
    final grouped = _topic == null;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: 'Škola',
            subtitle: _kind == Kind.ucenje
                ? '${lessons.length} lekcija · ${_read.length} pročitano'
                : '${lessons.length} ${lessons.length == 1 ? "tekst" : "tekstova"} · domaći izvori',
            showBack: widget.showBack,
          ),
          if (_hasBlog)
            _KindToggle(
              value: _kind,
              onPick: (k) => setState(() { _kind = k; _topic = null; }),
            ),
          _FilterRow<Topic?>(
            values: [null, ...Topic.values],
            selected: _topic,
            labelOf: (t) => t == null ? 'Sve' : t.label,
            onPick: (t) => setState(() => _topic = t),
          ),
          Expanded(
            child: lessons.isEmpty
                ? _empty(context)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    children: [
                      if (_kind == Kind.ucenje) ...[
                        const _TrustLegend(),
                        const SizedBox(height: 12),
                      ] else ...[
                        const _BlogNote(),
                        const SizedBox(height: 12),
                      ],
                      for (var i = 0; i < lessons.length; i++) ...[
                        if (grouped &&
                            (i == 0 ||
                                lessons[i].primaryTag != lessons[i - 1].primaryTag))
                          SectionLabel(lessons[i].primaryTag.label.toUpperCase()),
                        _LessonRow(
                          lesson: lessons[i],
                          isRead: _read.contains(lessons[i].id),
                        ),
                        const SizedBox(height: 9),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 40, color: c.faint),
            const SizedBox(height: 10),
            Text('Nema tekstova za ovaj filter', style: context.display(size: 16)),
            const SizedBox(height: 4),
            Text('Probaj drugu temu.',
                style: context.ui(size: 12.5, weight: FontWeight.w500, color: c.muted)),
          ],
        ),
      ),
    );
  }
}

ChipTone _levelTone(Level l) => switch (l) {
      Level.pocetnik => ChipTone.green,
      Level.srednji => ChipTone.water,
      Level.napredni => ChipTone.gold,
    };

/// Prekidač tipa teksta. Nije filter nego dva odvojena sadržaja — lekcije
/// („kako se radi") i blog (članci sa domaćih izvora).
class _KindToggle extends StatelessWidget {
  final Kind value;
  final ValueChanged<Kind> onPick;
  const _KindToggle({required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: c.surface3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final k in Kind.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onPick(k),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: k == value ? c.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: k == value ? c.shadow : null,
                    ),
                    child: Text(k.label,
                        style: context.ui(
                            size: 13,
                            weight: FontWeight.w800,
                            color: k == value ? c.green : c.muted)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Blog su tuđi tekstovi — u app-u stoji naš sažetak i link, ne prepis.
class _BlogNote extends StatelessWidget {
  const _BlogNote();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.open_in_new, size: 17, color: c.water),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tekstovi sa domaćih sajtova. Ovde je naš sažetak — original se '
              'čita kod izvora, njima i pripada.',
              style: context.ui(size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skrolabilna traka čipova za temu. Nivo se NE filtrira (odluka 2026-09-08) —
/// stoji kao čip na redu i vodi sortiranje unutar teme.
class _FilterRow<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onPick;

  const _FilterRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          for (final v in values)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: GestureDetector(
                onTap: () => onPick(v),
                child: AppChip(labelOf(v),
                    tone: v == selected ? ChipTone.green : ChipTone.neutral, small: true),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrustLegend extends StatelessWidget {
  const _TrustLegend();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 17, color: c.water),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '✓ pravilo potvrđeno izvorom (propis ili istraživanje) · '
              '~ uobičajena praksa, proveri na svojoj vodi',
              style: context.ui(size: 11.5, weight: FontWeight.w500, color: c.muted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final SchoolLesson lesson;
  final bool isRead;
  const _LessonRow({required this.lesson, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.surface3, borderRadius: BorderRadius.circular(12)),
            child: Text(lesson.emoji, style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title,
                    style: context.ui(size: 15, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(lesson.subtitle,
                    style: context.ui(size: 12.5, weight: FontWeight.w500, color: c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    AppChip(lesson.level.label,
                        tone: _levelTone(lesson.level), small: true),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                          lesson.kind == Kind.blog
                              ? (lesson.sourceName ?? 'izvor')
                              : '${lesson.readMinutes} min',
                          style: context.ui(size: 11, weight: FontWeight.w600, color: c.faint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (lesson.verified) ...[
                      const SizedBox(width: 7),
                      Text('✓', style: context.ui(size: 11, weight: FontWeight.w800, color: c.green)),
                    ],
                    if (isRead) ...[
                      const SizedBox(width: 7),
                      Icon(Icons.check_circle, size: 13, color: c.green),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: c.faint),
        ],
      ),
    );
  }
}

// ─────────────────────────── LEKCIJA (ČLANAK) ───────────────────────────

/// Lekcija se čita kao članak: lead, sekcije, pravila sa oznakom porekla.
/// Označava se pročitanom kad korisnik stigne do dna, ne na otvaranje.
class LessonScreen extends StatefulWidget {
  final SchoolLesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _scroll = ScrollController();
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Kratka lekcija se ne skroluje — proveri i posle prvog layout-a.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_marked || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0 || _scroll.offset >= max - 40) {
      _marked = true;
      SchoolProgressService.markRead(widget.lesson.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = widget.lesson;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(title: '${l.emoji} ${l.title}', subtitle: l.subtitle, showBack: true),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 34),
              children: [
                // Lekcija sa četiri teme + nivo + vreme ne staje u jedan red na
                // užem ekranu — čipovi se prelamaju, vreme ostaje gore desno.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppChip(l.level.label, tone: _levelTone(l.level), small: true),
                          for (final t in l.tags)
                            AppChip(t.label, tone: ChipTone.neutral, small: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${l.readMinutes} min',
                          style: context.ui(size: 11.5, weight: FontWeight.w700, color: c.faint)),
                    ),
                  ],
                ),
                if (l.lead != null) ...[
                  const SizedBox(height: 14),
                  Text(l.lead!,
                      style: context.ui(
                          size: 15, weight: FontWeight.w600, color: c.ink, height: 1.55)),
                ],
                if (l.kind == Kind.blog && l.sourceUrl != null) ...[
                  const SizedBox(height: 14),
                  AppButton('Pročitaj na ${l.sourceName ?? "izvoru"}',
                      icon: Icons.open_in_new,
                      block: true,
                      onTap: () => launchUrl(Uri.parse(l.sourceUrl!),
                          mode: LaunchMode.externalApplication)),
                ],
                const SizedBox(height: 4),
                for (final s in l.sections) ...[
                  SectionLabel(s.title.toUpperCase()),
                  if (s.comparator != null) ...[
                    _ComparatorView(set: s.comparator!),
                    const SizedBox(height: 10),
                  ],
                  if (s.sequence != null) ...[
                    _SequenceView(seq: s.sequence!),
                    const SizedBox(height: 10),
                  ],
                  if (s.notes.isNotEmpty)
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [for (final n in s.notes) _NoteRow(note: n)],
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final LessonNote note;
  const _NoteRow({required this.note});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ok = note.trust == Trust.verified;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (ok ? c.green : c.faint).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(ok ? '✓' : '~',
                style: context.ui(size: 10.5, weight: FontWeight.w800, color: ok ? c.green : c.muted)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(note.text,
                style: context.ui(size: 13.5, weight: FontWeight.w500, color: c.ink, height: 1.55)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── UPOREDI ───────────────────────────

/// Interaktivno poređenje dva predmeta. Redovi u kojima se razlikuju su
/// istaknuti — inače korisnik mora sam da traži razliku u tabeli.
class _ComparatorView extends StatefulWidget {
  final ComparatorSet set;
  const _ComparatorView({required this.set});

  @override
  State<_ComparatorView> createState() => _ComparatorViewState();
}

class _ComparatorViewState extends State<_ComparatorView> {
  int _a = 0;
  late int _b = widget.set.items.length > 1 ? 1 : 0;

  Future<void> _pick(bool left) async {
    final items = widget.set.items;
    final taken = left ? _b : _a;
    final chosen = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      // Bez ovoga sheet staje na pola ekrana i lista od šest stavki prelije.
      isScrollControlled: true,
      builder: (ctx) {
        final c = ctx.c;
        return AppSheet(
          title: left ? 'Levo' : 'Desno',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < items.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  enabled: i != taken,
                  leading: SizedBox(
                    width: 34,
                    child: SvgPicture.string(
                      items[i].svg,
                      colorFilter: ColorFilter.mode(
                          i == taken ? c.faint : c.ink, BlendMode.srcIn),
                    ),
                  ),
                  title: Text(items[i].name,
                      style: ctx.ui(
                          size: 14,
                          weight: FontWeight.w700,
                          color: i == taken ? c.faint : c.ink)),
                  subtitle: Text(items[i].tagline,
                      style: ctx.ui(size: 11.5, weight: FontWeight.w500, color: c.muted)),
                  onTap: i == taken ? null : () => Navigator.pop(ctx, i),
                ),
            ],
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    setState(() => left ? _a = chosen : _b = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final set = widget.set;
    final a = set.items[_a], b = set.items[_b];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _panel(a, true)),
              Container(width: 1, height: 150, color: c.line),
              Expanded(child: _panel(b, false)),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < set.specLabels.length; i++)
            _specRow(set.specLabels[i], a.specs[i], b.specs[i]),
        ],
      ),
    );
  }

  Widget _panel(ComparatorItem item, bool left) {
    final c = context.c;
    return GestureDetector(
      onTap: () => _pick(left),
      child: Column(
        children: [
          SizedBox(
            height: 104,
            child: SvgPicture.string(
              item.svg,
              colorFilter: ColorFilter.mode(c.ink, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(item.name,
                    textAlign: TextAlign.center,
                    style: context.ui(size: 12.5, weight: FontWeight.w800, color: c.green),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.expand_more, size: 15, color: c.green),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Text(item.tagline,
                textAlign: TextAlign.center,
                style: context.ui(size: 10.5, weight: FontWeight.w500, color: c.muted, height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String va, String vb) {
    final c = context.c;
    final differs = va != vb;
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: differs ? c.gold.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: context.ui(
                  size: 9.5, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(va,
                    style: context.ui(
                        size: 11.5,
                        weight: differs ? FontWeight.w700 : FontWeight.w500,
                        color: c.ink,
                        height: 1.3)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(vb,
                    style: context.ui(
                        size: 11.5,
                        weight: differs ? FontWeight.w700 : FontWeight.w500,
                        color: c.ink,
                        height: 1.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────── KORAK PO KORAK ───────────────────────────

/// Postupak jedan korak u kadru: listaš prstom ili strelicama, brojač pokazuje
/// gde si. Kadar je fiksne visine a tekst stoji ispod njega, pa se sadržaj ne
/// pomera pri listanju.
class _SequenceView extends StatefulWidget {
  final StepSequence seq;
  const _SequenceView({required this.seq});

  @override
  State<_SequenceView> createState() => _SequenceViewState();
}

class _SequenceViewState extends State<_SequenceView> {
  final _pages = PageController();
  int _i = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) {
    final n = widget.seq.steps.length;
    if (i < 0 || i >= n) return;
    _pages.animateToPage(i,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final seq = widget.seq;
    final steps = seq.steps;
    final step = steps[_i];
    final last = _i == steps.length - 1;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(seq.purpose,
                    style: context.ui(size: 13, weight: FontWeight.w700, height: 1.35)),
              ),
              if (seq.strength != null) ...[
                const SizedBox(width: 8),
                AppChip(seq.strength!, tone: ChipTone.green, small: true),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Kadar koraka. Dijagrami još ne postoje za čvorove — dok ih nema,
          // stoji broj koraka, pa kadar ne izgleda pokvaren.
          SizedBox(
            height: 168,
            child: PageView.builder(
              controller: _pages,
              onPageChanged: (i) => setState(() => _i = i),
              itemCount: steps.length,
              itemBuilder: (_, i) => _frame(steps[i], i),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _navBtn(Icons.chevron_left, _i > 0 ? () => _go(_i - 1) : null),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var k = 0; k < steps.length; k++)
                      Container(
                        width: k == _i ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: k == _i ? c.green : c.line,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _navBtn(last ? Icons.replay : Icons.chevron_right,
                  last ? () => _go(0) : () => _go(_i + 1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: c.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text('${_i + 1}/${steps.length}',
                    style: context.ui(size: 11, weight: FontWeight.w800, color: c.green)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(step.text,
                    style: context.ui(
                        size: 13.5, weight: FontWeight.w500, color: c.ink, height: 1.5)),
              ),
            ],
          ),
          if (seq.videoUrl != null) ...[
            const SizedBox(height: 12),
            AppButton(seq.videoLabel ?? 'Vidi video',
                icon: Icons.play_circle_outline,
                kind: BtnKind.outline,
                block: true,
                onTap: () => launchUrl(Uri.parse(seq.videoUrl!),
                    mode: LaunchMode.externalApplication)),
          ],
          if (seq.mistakes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('NAJČEŠĆE GREŠKE',
                style: context.ui(
                    size: 9.5, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            for (final m in seq.mistakes) _NoteRow(note: m),
          ],
        ],
      ),
    );
  }

  Widget _frame(ProcedureStep step, int i) {
    final c = context.c;
    if (step.svg != null) {
      return SvgPicture.string(step.svg!,
          colorFilter: ColorFilter.mode(c.ink, BlendMode.srcIn));
    }
    if (step.imageAsset != null) {
      // Slike su crne linije u alfa kanalu na prozirnoj pozadini, pa se boje
      // isto kao SVG dijagrami — jedna slika radi u light i dark temi.
      return Image.asset(step.imageAsset!,
          fit: BoxFit.contain,
          color: c.ink,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_, _, _) => _placeholder(i));
    }
    return _placeholder(i);
  }

  /// Dok slika koraka ne postoji — veliki broj koraka, bez lažnog crteža.
  Widget _placeholder(int i) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface3,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${i + 1}',
              style: context.display(size: 44, weight: FontWeight.w800, color: c.faint)),
          Text('korak',
              style: context.ui(size: 10.5, weight: FontWeight.w700, color: c.faint)),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap) {
    final c = context.c;
    final on = onTap != null;
    return Material(
      color: on ? c.surface3 : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 20, color: on ? c.green : c.faint),
        ),
      ),
    );
  }
}
