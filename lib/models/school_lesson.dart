// Lekcija u Školi ribolova. Sadržaj je statičan — `lib/data/school_lessons.dart`.

/// Tema lekcije. Lekcija nosi VIŠE tema kad stvarno pripada više njih —
/// čvorovi i čitanje vode služe svakoj tehnici, primama i feederu i plovku.
/// Prva tema u listi je primarna (po njoj se grupiše kad filter nije aktivan).
enum Topic { opste, feeder, varalica, plovak }

extension TopicLabel on Topic {
  String get label => switch (this) {
        Topic.opste => 'Opšte',
        Topic.feeder => 'Feeder',
        Topic.varalica => 'Varalica',
        Topic.plovak => 'Plovak',
      };
}

/// Tip teksta — treći tag. `ucenje` su lekcije (kako se nešto radi),
/// `blog` su članci i vesti. Bira se prekidačem na vrhu, ne filterom.
enum Kind { ucenje, blog }

extension KindLabel on Kind {
  String get label => switch (this) {
        Kind.ucenje => 'Učenje',
        Kind.blog => 'Blog',
      };
}

/// Nivo znanja — drugi tag; prikazuje se i po njemu se sortira unutar teme,
/// ali se NE filtrira (odluka 2026-09-08).
enum Level { pocetnik, srednji, napredni }

extension LevelLabel on Level {
  String get label => switch (this) {
        Level.pocetnik => 'Početnik',
        Level.srednji => 'Srednji',
        Level.napredni => 'Napredni',
      };
}

/// Poreklo pravila — ide u UI kao ✓ / ~ da korisnik zna čemu da veruje.
enum Trust {
  /// Potvrđeno izvorom: zvanični propis ili istraživanje u `docs/`.
  verified,

  /// Uobičajena praksa / naša heuristika — nije potvrđeno izvorom.
  heuristic,
}

class SchoolLesson {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;

  /// Prva tema je primarna.
  final List<Topic> tags;
  final Level level;
  final Kind kind;

  /// Za `Kind.blog`: odakle je tekst i gde se čita u celini. Sadržaj tuđeg
  /// članka se NE prepisuje — ovde stoji naš sažetak i link na izvor.
  final String? sourceName;
  final String? sourceUrl;

  /// Uvodni pasus — magazinski lead na vrhu lekcije.
  final String? lead;

  final List<LessonSection> sections;

  const SchoolLesson({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.level,
    this.kind = Kind.ucenje,
    this.sourceName,
    this.sourceUrl,
    this.lead,
    required this.sections,
  });

  Topic get primaryTag => tags.first;

  /// Lekcija nosi ✓ samo ako je svako pravilo u njoj potvrđeno izvorom;
  /// jedno heurističko pravilo je spušta na ~.
  bool get verified =>
      sections.every((s) => s.notes.every((n) => n.trust == Trust.verified));

  /// Procena vremena čitanja. ~900 znakova u minuti (sporije od proze —
  /// ovo su tehnička uputstva koja se čitaju pažljivo), minimum 1.
  int get readMinutes {
    var chars = lead?.length ?? 0;
    for (final s in sections) {
      chars += s.title.length;
      for (final n in s.notes) {
        chars += n.text.length;
      }
      final c = s.comparator;
      if (c != null) {
        for (final i in c.items) {
          chars += i.tagline.length + i.specs.join().length;
        }
      }
    }
    return (chars / 900).ceil().clamp(1, 30);
  }
}

class LessonSection {
  final String title;
  final List<LessonNote> notes;

  /// Opciono interaktivno poređenje unutar sekcije (npr. tipovi hranilica).
  final ComparatorSet? comparator;

  /// Opcioni postupak korak-po-korak (čvorovi, montiranje sistema).
  final StepSequence? sequence;

  const LessonSection({
    required this.title,
    this.notes = const [],
    this.comparator,
    this.sequence,
  });
}

/// Postupak koji se uči korak po korak — jedan korak u kadru, listaš ih.
/// Za čvorove je ovo jedini format koji radi: tekst bez redosleda ne uči,
/// a sve odjednom je zid.
class StepSequence {
  /// Čemu služi — jedna rečenica.
  final String purpose;

  /// Npr. „drži 90–95% jačine najlona".
  final String? strength;

  final List<ProcedureStep> steps;

  /// Video se otvara kad korisniku zapne. Dijagrami koraka još ne postoje
  /// (vidi napomenu u `tools/school_diagrams.py`), pa je video za sada glavna
  /// vizuelna potpora.
  final String? videoUrl;
  final String? videoLabel;

  /// Najčešće greške — posle koraka, ne pre.
  final List<LessonNote> mistakes;

  const StepSequence({
    required this.purpose,
    this.strength,
    required this.steps,
    this.videoUrl,
    this.videoLabel,
    this.mistakes = const [],
  });
}

class ProcedureStep {
  final String text;

  /// Inline SVG dijagram koraka, kad ga bude.
  final String? svg;

  /// Fotografija koraka iz `assets/` — planirani put za čvorove.
  final String? imageAsset;

  final Trust trust;

  const ProcedureStep(this.text, {this.svg, this.imageAsset, this.trust = Trust.heuristic});

  const ProcedureStep.ok(this.text, {this.svg, this.imageAsset})
      : trust = Trust.verified;
}

class LessonNote {
  final String text;
  final Trust trust;

  const LessonNote(this.text, {this.trust = Trust.heuristic});

  /// Kratica za potvrđeno pravilo.
  const LessonNote.ok(this.text) : trust = Trust.verified;
}

/// Interaktivno poređenje: korisnik bira dva predmeta i vidi ih jedan uz
/// drugi, sa istaknutim redovima gde se razlikuju.
class ComparatorSet {
  /// Nazivi redova tabele; svaki `ComparatorItem.specs` ide u istom redosledu.
  final List<String> specLabels;
  final List<ComparatorItem> items;

  const ComparatorSet({required this.specLabels, required this.items});
}

class ComparatorItem {
  final String id;
  final String name;

  /// Jedna rečenica — čemu služi.
  final String tagline;

  /// Inline SVG dijagram (currentColor, tinta se po temi).
  final String svg;

  /// Vrednosti u redosledu `ComparatorSet.specLabels`.
  final List<String> specs;

  const ComparatorItem({
    required this.id,
    required this.name,
    required this.tagline,
    required this.svg,
    required this.specs,
  });
}
