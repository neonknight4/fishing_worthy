import '../models/lure_plan.dart';
import '../models/weather_data.dart';

/// Gradi plan varaličarenja iz uslova na vodi.
/// Pravila su iz `docs/research/2026-09-07-varalicarenje-research.md` —
/// varalicar.com (zimska štuka, UL bucov), sportskiribolov.co.rs (smuđ),
/// plovak-varalica (klen na malim rekama).
class LureAdvisor {
  /// [waterTempC] neka bude prava RHMZ temperatura kad postoji, inače procena.
  static LurePlan plan({
    required double waterTempC,
    required WaterTurbidity turbidity,
    required double windSpeed,
    required int month,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
  }) {
    final isLake = waterBody?.type == 'lake';
    final band = _band(waterTempC);
    final coloured = turbidity == WaterTurbidity.turbid ||
        turbidity == WaterTurbidity.veryTurbid;
    final clear = turbidity == WaterTurbidity.clear;
    final notes = <String>[];

    final lureClass = _pickClass(band, coloured, windSpeed);

    // ── Varalice + vođenje po temperaturnom pojasu ────────────────────────
    final List<LurePick> lures;
    final String retrieve;
    final String depth;
    switch (band) {
      case _Band.icy:
        lures = const [
          LurePick(
            type: 'Suspending vobler (šed profil)',
            size: '9–13 cm',
            detail: 'Parkiraj ga i pusti da lebdi. Jedan veći i širi radi bolje nego tri manja i uža.',
          ),
          LurePick(
            type: 'Soft-jerk na worm udici 4/0–5/0',
            size: '11–15 cm',
            detail: 'Karolina rig; niski spori odskoci, ne dalje od 0.6 m od dna.',
          ),
          LurePick(
            type: 'Velika tanka kašika',
            size: 'do 80 mm · ~24 g',
            detail: 'Sporo motanje bez pauza — geganje ranjene ribe.',
          ),
          LurePick(
            type: 'Džig sa štitnikom, crno-plava suknja',
            size: 'king-size',
            detail: 'Iz čamca, paralelno sa linijom promene. Najsporije moguće džigovanje.',
          ),
        ];
        retrieve = 'Vrlo sporo, sa pauzama 15–20 s na hot-spotu. Neutralna štuka '
            'pomeriće se najviše za dužinu tela.';
        depth = 'Duboko — 60–70% maksimalne dubine. Pridneni sloj je zimi i najtopliji i najbogatiji kiseonikom.';
        notes.add('⚠ Miris je obavezan: brza varalica ga ne traži, nepokretna MORA da miriše. '
            'Fuluj soft-džerk i suknju aromom ribe/raka.');
        notes.add('Sitna štuka početkom zime praktično staje — cilj su krupni primerci.');
      case _Band.cold:
        lures = const [
          LurePick(
            type: 'Shad na jig glavi',
            size: '10–12 cm · 14–28 g',
            detail: 'Džigovanje: 2 odskoka pa pauza 2–4 s. Prati kontakt sa dnom.',
          ),
          LurePick(
            type: 'Dubokoronac',
            size: '9–12 cm',
            detail: 'Dubinu regulišeš sporijim povlačenjem i podizanjem vrha štapa.',
          ),
          LurePick(
            type: 'Kašika / glavinjara sa zvečkom',
            size: '15–28 g',
            detail: 'Za brzo pretraživanje terena kad ne znaš gde je riba.',
          ),
        ];
        retrieve = 'Džigovanje ili motanje sa pauzama. Što je voda hladnija, to sporije.';
        depth = 'Dublji delovi, uz strukture i prelaze.';
      case _Band.mild:
        lures = const [
          LurePick(
            type: 'Shad / tvister na jig glavi',
            size: '8–10 cm · 10–21 g',
            detail: 'Najlakša moguća glava za tu vodu — osećaj kontakt sa dnom.',
          ),
          LurePick(
            type: 'Mino vobler',
            size: '7–11 cm',
            detail: 'Ravnomerno sa twitch-evima; menjaj ritam dok ne nađeš okidač.',
          ),
          LurePick(
            type: 'Spinnerbait',
            size: '10–23 g',
            detail: 'Za zatravljene i zakrčene terene — suknja štiti od kačenja.',
          ),
        ];
        retrieve = 'Ravnomerno sa twitch-evima; varirati brzinu dok ne proradi.';
        depth = 'Srednji slojevi i prelazi plićaka u dubinu.';
      case _Band.warm:
        lures = const [
          LurePick(
            type: 'Mikro shad / tvister',
            size: 'do 5 cm · 2–7 g',
            detail: 'Osnovna UL porcija za klena i bandara.',
          ),
          LurePick(
            type: 'Leptir (rotirajuća kašika)',
            size: '#1–#3',
            detail: 'Baci preko toka i uvedi u maticu sa suprotne strane.',
          ),
          LurePick(
            type: 'Mino / plitkoronac',
            size: '5–7.5 cm',
            detail: 'Rapala F7/F9, SSR 5, OSP Bent Minnow — provereni na bucovu.',
          ),
          LurePick(
            type: 'Površinac / zara',
            size: '~7 g',
            detail: 'Teturanje s boka na bok po površini — okidač za bucova.',
          ),
        ];
        retrieve = 'Brže i agresivnije nego zimi. Za klena: preko toka pa u maticu, '
            'bez zadržavanja na jednom mestu.';
        depth = 'Površina i gornji slojevi; plitke zone i sprudovi.';
        notes.add('Na bistroj maloj vodi leti: rano ujutru i kasno popodne rade '
            'znatno bolje nego po danu.');
        notes.add('Ne zadržavaj se dugo na jednom mestu — klen uzima u prvih par '
            'zabačaja ako je tu i ako jede.');
      case _Band.hot:
        lures = const [
          LurePick(
            type: 'Površinac / popper / zara',
            size: '5–8 cm',
            detail: 'Zora i sumrak, gornji sloj — jedini pouzdan prozor po vrelini.',
          ),
          LurePick(
            type: 'Mikro varalice',
            size: '3–5 cm · 1–5 g',
            detail: 'Bandar, klen, bas uz travu i hlad.',
          ),
          LurePick(
            type: 'Krupan gumac / džerk (som)',
            size: '15–20 cm',
            detail: 'Uz dno, po mraku — som je jedina krupna meta u ovom pojasu.',
          ),
        ];
        retrieve = 'Površinski, u zoru i sumrak. Preko dana samo dubina i hlad.';
        depth = 'Površina u zoru/sumrak; preko dana najdublje što možeš.';
        notes.add('⚠ Kapitalna štuka je u niziji leti praktično neulovljiva — '
            'post traje 2–2.5 meseca. Ne troši dan na nju.');
    }

    // ── Boje po prozirnosti ───────────────────────────────────────────────
    final String colors;
    if (clear) {
      colors = 'Prirodne — roach, ukleja, perch, prozirne sa šljokicom';
      notes.add('Bistra voda — prirodne boje i finiji fluoro predvez; profil pre manji nego veći.');
    } else if (coloured) {
      colors = 'Kontrast i signal — firetiger, šartrez, crvena glava, crna silueta';
      notes.add('Mutna voda — idi na vibraciju i zvuk (glavinjare, spinnerbait, zvečke), krupniji profil.');
    } else {
      colors = 'Univerzalne — srebrno/plavo, motoroil, bela';
    }

    // ── Struna po klasi ───────────────────────────────────────────────────
    final String line;
    switch (lureClass) {
      case LureClass.ul:
        line = 'Pletenica 5–8 lb (0.06–0.10 mm) + fluoro predvez 4 lb, ~50 cm';
        notes.add('UL: samo tanka struna izbacuje lagane varalice dovoljno daleko. '
            'Fluoro predvez je obavezan — tanka pletenica puca na prvoj prepreci.');
      case LureClass.classic:
        line = 'Pletenica 10–15 lb + fluoro predvez 0.30–0.35 mm';
        notes.add('Gde ima štuke — čelični ili titan predvez, fluoro ne drži zube.');
      case LureClass.heavy:
        line = 'Pletenica 30–50 lb + titan ili fluoro 0.60 mm+';
    }

    // ── Mesta po tipu vode ────────────────────────────────────────────────
    final spots = <String>[];
    if (isLake) {
      spots.addAll([
        'Podvodni rt gde se plitko spaja sa dubokim — forsiraj sunčanu stranu',
        'Rupa 2–4× dublja od proseka, nagib oboda 30–45°',
        'Brežuljci na ravnom dnu, po mogućstvu sa granjem',
        'Ivica trske i potopljene vegetacije',
      ]);
    } else {
      spots.addAll([
        'Prelaz brze i tihe vode; špicevi, naperi, uvale',
        'Povratni tok — tu varalicu vuci NIZ tok',
        'Prelaz plićaka u dubinu i obrnuto (sprud 10–20 m od obale)',
        'Kamenito i peščano dno sa preprekama',
      ]);
      notes.add('Smuđ mrzi ravno muljevito dno. Gde nema zakački — nema ni smuđa.');
    }
    if (lureClass == LureClass.ul) {
      spots.add('UL nema domet — traži blagu, pristupačnu obalu i mesta blizu nje');
    }

    // ── Vodostaj ──────────────────────────────────────────────────────────
    switch (waterLevel?.trend) {
      case WaterLevelTrend.largeRise:
        notes.add('Veliki porast — riba je uz obalu. Teža glava, jače boje, kraći zabačaji.');
      case WaterLevelTrend.slightRise:
        notes.add('Porast donosi grabljivicu, ali vrh je 2–3 dana kasnije — kad voda legne '
            'i stane da oscilira u par cm.');
      case WaterLevelTrend.stable:
        notes.add('Stabilan vodostaj — najbolji scenario za varalicu.');
      case WaterLevelTrend.largeFall:
        notes.add('Nagli pad — riba se povlači u dubinu i gasi. Idi dublje i sporije.');
      case WaterLevelTrend.slightFall:
      case null:
        break;
    }

    // ── Vetar ─────────────────────────────────────────────────────────────
    if (windSpeed >= 25) {
      notes.add('Jak vetar — traži zavetrinu, ili obalu PREMA kojoj vetar duva '
          '(sabija sitnu ribu uz nogu, grabljivica ide za njom).');
    }

    return LurePlan(
      lureClass: lureClass,
      targetFish: _targets(band, month, isLake),
      lures: lures,
      colors: colors,
      retrieve: retrieve,
      depth: depth,
      line: line,
      spots: spots,
      notes: notes,
      alternative: _alternative(lureClass, band),
    );
  }

  static LureClass _pickClass(_Band band, bool coloured, double wind) {
    // UL ne radi po jakom vetru (ne izbacuje) ni u jako mutnoj vodi (lov na vid).
    if (wind >= 28) {
      return band == _Band.icy ? LureClass.heavy : LureClass.classic;
    }
    switch (band) {
      case _Band.icy:
        return LureClass.heavy;
      case _Band.cold:
        return LureClass.classic;
      case _Band.mild:
        return LureClass.classic;
      case _Band.warm:
        return coloured ? LureClass.classic : LureClass.ul;
      case _Band.hot:
        return coloured ? LureClass.classic : LureClass.ul;
    }
  }

  static String? _alternative(LureClass picked, _Band band) {
    switch (band) {
      case _Band.icy:
        return null;
      case _Band.cold:
        return 'UL ima smisla samo na maloj bistroj reci za klena — na velikoj vodi ne.';
      case _Band.mild:
        return picked == LureClass.classic
            ? 'UL (1–10 g) radi paralelno na klena i bandara, ako tražiš borbu a ne kilažu.'
            : null;
      case _Band.warm:
        return picked == LureClass.ul
            ? 'Klasik (10–40 g) i dalje drži smuđa i štuku na dubljim potezima.'
            : 'UL bi radio da voda nije mutna — proveri opet kad se izbistri.';
      case _Band.hot:
        return picked == LureClass.ul
            ? 'Za soma: teško (40 g+), krupan gumac uz dno, isključivo po mraku.'
            : null;
    }
  }

  static List<String> _targets(_Band band, int month, bool isLake) {
    switch (band) {
      case _Band.icy:
        return ['Štuka (krupna)', 'Smuđ'];
      case _Band.cold:
        return isLake ? ['Štuka', 'Bandar'] : ['Smuđ', 'Štuka', 'Bandar'];
      case _Band.mild:
        return isLake ? ['Štuka', 'Bandar', 'Bas'] : ['Smuđ', 'Štuka', 'Klen', 'Bucov'];
      case _Band.warm:
        return isLake ? ['Bandar', 'Bas', 'Štuka'] : ['Klen', 'Bucov', 'Bandar', 'Smuđ'];
      case _Band.hot:
        return isLake ? ['Bas', 'Bandar', 'Som'] : ['Bucov', 'Klen', 'Som'];
    }
  }

  static _Band _band(double t) {
    if (t < 6) return _Band.icy;
    if (t < 12) return _Band.cold;
    if (t < 18) return _Band.mild;
    if (t <= 24) return _Band.warm;
    return _Band.hot;
  }
}

enum _Band { icy, cold, mild, warm, hot }
