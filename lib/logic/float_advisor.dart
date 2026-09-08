import '../models/float_plan.dart';
import '../models/weather_data.dart';

/// Gradi plan plovkarenja iz uslova na vodi, u dva režima:
/// klasičan plovak i plovak na otpuštanje (rečno vođenje).
///
/// Pravila za otpuštanje su iz `docs/research/2026-09-07-varalicarenje-research.md` §7 —
/// sportskiribolov.co.rs (tehnika plovkarenja na brzim rijekama),
/// plovkarenje.blogspot (Drina), zanimljiv.org i ribolov.de (skobalj i trava).
class FloatAdvisor {
  static FloatPlan plan({
    required double waterTempC,
    required WaterTurbidity turbidity,
    required double windSpeed,
    required int month,
    required FloatMode mode,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
  }) {
    return mode == FloatMode.trotting
        ? _trotting(waterTempC, turbidity, windSpeed, month, waterLevel, waterBody)
        : _standard(waterTempC, turbidity, windSpeed, month, waterLevel, waterBody);
  }

  /// Da li otpuštanje uopšte ima smisla na ovoj vodi.
  static bool trottingApplies(WaterBody? waterBody) => waterBody?.type != 'lake';

  // ── Klasičan plovak ────────────────────────────────────────────────────
  static FloatPlan _standard(
    double waterTempC,
    WaterTurbidity turbidity,
    double windSpeed,
    int month,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
  ) {
    final isLake = waterBody?.type == 'lake';
    final band = _band(waterTempC);
    final clear = turbidity == WaterTurbidity.clear;
    final coloured = turbidity == WaterTurbidity.turbid ||
        turbidity == WaterTurbidity.veryTurbid;
    final notes = <String>[];

    final String rod;
    final String floatType;
    final String shotting;
    if (isLake) {
      rod = 'Waggler štap 3.9–4.2 m';
      if (windSpeed >= 20) {
        floatType = 'Waggler sa opterećenjem 3+2 g (natopljen do vrha)';
        shotting = 'Sve olovo uz plovak, 2 sitne sačme na donjoj trećini. '
            'Potopi vrh strune da je vetar ne vuče.';
        notes.add('Vetar na jezeru — potopi strunu i vodi mamac malo iznad dna; '
            'površinska struja nosi postavku.');
      } else {
        floatType = 'Waggler 2+1 g';
        shotting = 'Bulk uz plovak, dve sitne sačme na donjoj trećini';
      }
    } else {
      rod = 'Bolonjez 4–5 m';
      if (windSpeed >= 20 || waterLevel?.trend == WaterLevelTrend.largeRise) {
        floatType = 'Bolonjez 4–8 g';
        shotting = 'Bulk na 2/3 dubine, jedna sačma 20 cm od udice — '
            'mora da drži liniju u struji';
      } else {
        floatType = 'Bolonjez 2–4 g';
        shotting = 'Stringer (opadajuće sačme) — prirodan pad mamca kroz slojeve';
      }
    }

    final List<String> baits;
    final String feeding;
    final String hooklength;
    final String hookSize;
    switch (band) {
      case _Band.cold:
        baits = ['Crv', 'Mrtav crv', 'Kaster', 'Zrno kukuruza'];
        feeding = 'Minimalno — loptica veličine oraha na 10–15 min, ili samo šaka kastera';
        hooklength = '25–35 cm · 0.10–0.12 mm';
        hookSize = '16–18';
        notes.add('Hladna voda — riba stoji nisko i sporo. Mamac mora da leži ili '
            'lebdi par cm iznad dna.');
      case _Band.cool:
        baits = ['Crv', 'Kaster', 'Kukuruz', 'Pelet 4mm'];
        feeding = 'Umereno — loptica na 5–8 min, gradi mesto polako';
        hooklength = '30–40 cm · 0.12–0.14 mm';
        hookSize = '14–16';
      case _Band.mild:
        baits = ['Kukuruz', 'Crv', 'Pelet 6mm', 'Konoplja'];
        feeding = 'Redovno — mala loptica na svaki 3–5 min + partikl u kap';
        hooklength = '30–45 cm · 0.14–0.16 mm';
        hookSize = '12–14';
      case _Band.warm:
        baits = ['Kukuruz', 'Pelet 6–8mm', 'Testo', 'Boila 10mm'];
        feeding = 'Izdašno i često — riba je u gornjim slojevima, hrani da je zadržiš';
        hooklength = '35–50 cm · 0.16–0.18 mm';
        hookSize = '10–12';
        notes.add('Topla voda — probaj mamac na pola dubine pre nego što spustiš na dno.');
    }

    final String depth;
    if (band == _Band.cold) {
      depth = 'Na dnu ili 2–5 cm iznad — bez povlačenja';
    } else if (band == _Band.warm) {
      depth = 'Počni na pola dubine, spuštaj dok ne nađeš sloj';
    } else {
      depth = '5–15 cm iznad dna, sa povremenim zadržavanjem mamca';
    }

    if (clear) {
      notes.add('Bistra voda — tanji podvez, sitnija udica, drži se dalje od obale '
          'i ne bacaj senku na vodu.');
    } else if (coloured) {
      notes.add('Mutna voda — krupniji i mirisniji mamac; plovak može deblji, '
          'riba ne vidi postavku.');
    }
    if (waterLevel?.trend == WaterLevelTrend.largeRise) {
      notes.add('Velika voda — traži mirnu vodu iza napera i u uvalama, '
          'riba beži iz matice.');
    }
    if (!isLake) {
      notes.add('Na šljunkovitoj reci sa brzom vodom otpuštanje radi bolje od '
          'klasičnog plovka — prebaci režim gore.');
    }

    return FloatPlan(
      mode: FloatMode.standard,
      rod: rod,
      floatType: floatType,
      shotting: shotting,
      depth: depth,
      hooklength: hooklength,
      hookSize: hookSize,
      hookBaits: baits,
      feeding: feeding,
      targetFish: _standardTargets(band, isLake),
      notes: notes,
    );
  }

  // ── Plovak na otpuštanje (rečno vođenje) ───────────────────────────────
  static FloatPlan _trotting(
    double waterTempC,
    WaterTurbidity turbidity,
    double windSpeed,
    int month,
    WaterLevelForecast? waterLevel,
    WaterBody? waterBody,
  ) {
    final band = _band(waterTempC);
    final clear = turbidity == WaterTurbidity.clear;
    final coloured = turbidity == WaterTurbidity.turbid ||
        turbidity == WaterTurbidity.veryTurbid;
    final bigWater = waterLevel?.trend == WaterLevelTrend.largeRise ||
        waterLevel?.trend == WaterLevelTrend.slightRise;
    final notes = <String>[];

    // Trava (Cladophora glomerata) je glavni mamac; „maskirna" alga je
    // najlovnija rano leto i kasna jesen.
    final travaPeak = month == 6 || month == 7 || month == 10 || month == 11;
    final List<String> baits;
    final String feeding;
    if (coloured) {
      baits = ['Crv / glista', 'Kaster', 'Hleb', 'Trava (kladofora)'];
      feeding =
          'Na bele mamce hranjenje je obavezno — nekoliko loptica hleba ili primame, '
          'bačenih malo uzvodno od mesta gde očekuješ ribu.';
      notes.add('Mutna voda — crv i kaster nadmašuju travu, a riba je bliže obali.');
    } else {
      baits = [
        'Trava — kladofora (Cladophora glomerata)',
        'Hleb (kora i sredina)',
        'Testo / pen sajo',
        'Crv / glista',
        'Kaster',
      ];
      feeding = 'Na travu se NE hrani — riba je već na algi. '
          'Na bele mamce (hleb, testo) hranjenje je obavezno.';
    }

    if (travaPeak) {
      notes.add('Vrh sezone za travu — „maskirna" crno-pegava zeleno-žuta alga '
          'radi rano leto i kasnu jesen. Iskoristi.');
    }
    notes.add('Travu beri sa kamenja u TOJ reci — negde lovi jarko zelena, negde '
        'trula smeđe-žuta. Meka, raspadnuta alga sa sitnim organizmima je bolja od sveže.');
    notes.add('Udica za travu: sitnija, sa namotajem — algu namotaš oko struka, '
        'a donji deo ostaviš slobodan da leprša.');

    // Predvez po karakteru terena (aproksimacija preko vodostaja i bistrine).
    final String hooklength;
    if (bigWater) {
      hooklength = '50–70 cm · 0.16–0.20 mm — velika voda, duži predvez';
    } else if (clear) {
      hooklength = '30–50 cm · 0.12–0.14 mm — bistro, idi finije';
    } else {
      hooklength = '30–50 cm · 0.14–0.16 mm';
    }
    notes.add('Pravilo predveza: što brža, plića i ravnija voda — kraći predvez '
        '(ispod 30 cm). Duboko i krševito — do 70 cm, ali ne preko.');

    final floatType = bigWater
        ? 'Bolonjez plovak 6–10 g (suza), pojačan za jaku vodu'
        : band == _Band.cold
            ? 'Plovak-pero 3–5 g, tanka crvena antena'
            : 'Bolonjez plovak 3–6 g';

    // ── Četiri načina vođenja ────────────────────────────────────────────
    const guides = [
      FloatGuide(
        name: 'Štopovanje',
        when: 'Brza i ujednačena voda, sitan šljunak ili pesak. Klasika za skobalja.',
        how: 'Ritmično pridržavaj pa pusti — mamac „češlja" dno sporije od struje. '
            'Bulk 30 cm iznad udice + 1–2 sitne sačme tik iznad nje. '
            'Plovak podesi 10–20 cm DUBLJE od izmerene dubine.',
      ),
      FloatGuide(
        name: 'Španovanje',
        when: 'Ujednačen tok i ujednačena dubina. Najbolje kad pecaš na travu.',
        how: 'Vrh štapa drži strunu blago zategnutu, ali plovak NE zaustavljaš — '
            'ide malo sporije od vode. Plovak na tačnoj dubini dna.',
      ),
      FloatGuide(
        name: 'Zadržavanje',
        when: 'Krševito, nepravilno dno — kanali između gromada, nagle promene dubine.',
        how: 'Kratka pauza pred svaku prepreku da pritisak vode podigne postavku preko nje. '
            'Bulk odmah ispod plovka + 5–6 sitnih sačmi nanizanih ka udici, '
            'da sistem „slalomira" preko 25–80 cm razlike u dubini.',
      ),
      FloatGuide(
        name: 'Slobodno puštanje',
        when: 'Spora voda i travnati potezi, plotica, zimski skobalj u mirnim virovima.',
        how: 'Bez zatezanja — plovak putuje brzinom vode. Plotica je oprezna: '
            'svaka korekcija plovka u zoni uzimanja je odbija.',
      ),
    ];

    final String recommended;
    if (bigWater) {
      recommended = 'Zadržavanje';
    } else if (band == _Band.cold) {
      recommended = 'Slobodno puštanje';
    } else if (clear) {
      recommended = 'Španovanje';
    } else {
      recommended = 'Štopovanje';
    }

    // ── Dubina + vodostaj ────────────────────────────────────────────────
    final depth = 'Prati dno. Drina raste → pomeraj plovak na VEĆU dubinu; '
        'opada → smanjuj. Izbegavaj dublje od 5 m i čisto muljevito dno.';
    switch (waterLevel?.trend) {
      case WaterLevelTrend.largeRise:
        notes.add('Veliki porast — riba se sabija uz obalu, skrati zabačaj i pojačaj plovak.');
      case WaterLevelTrend.largeFall:
        notes.add('Nagli pad — riba se vraća u maticu, traži je dalje od obale.');
      default:
        break;
    }

    if (clear) {
      notes.add('Bistra voda — riba se povlači u maticu. Mutna — dolazi uz obalu.');
    }
    if (band == _Band.cold) {
      notes.add('Zima je bolji deo sezone za skobalja nego leto. Leti radi samo '
          'rano ujutru i kasno uveče.');
    }
    if (month == 4 || month == 5) {
      notes.add('⚠ Skobalj, mrena, plotica i klen su u lovostaju 15.4–31.5 — proveri datum.');
    }
    if (windSpeed >= 25) {
      notes.add('Jak vetar — teško je držati kontrolisanu liniju kroz otpuštanje; '
          'skrati potez i pojačaj plovak.');
    }

    return FloatPlan(
      mode: FloatMode.trotting,
      rod: 'Bolonjez 4–6 m sa mašinicom (ili 7 m bez mašinice)',
      floatType: floatType,
      shotting: 'Zavisi od vođenja — vidi izabranu tehniku ispod',
      depth: depth,
      hooklength: hooklength,
      hookSize: clear ? '12–14' : '9–12',
      hookBaits: baits,
      feeding: feeding,
      targetFish: const ['Skobalj', 'Mrena', 'Plotica', 'Klen'],
      notes: notes,
      guides: guides,
      recommendedGuide: recommended,
    );
  }

  static List<String> _standardTargets(_Band band, bool isLake) {
    switch (band) {
      case _Band.cold:
        return ['Deverika', 'Bodorka', 'Plotica'];
      case _Band.cool:
        return isLake ? ['Deverika', 'Bodorka', 'Karaš'] : ['Deverika', 'Bodorka', 'Klen'];
      case _Band.mild:
        return isLake ? ['Šaran', 'Karaš', 'Deverika'] : ['Deverika', 'Klen', 'Skobalj'];
      case _Band.warm:
        return isLake ? ['Šaran', 'Amur', 'Karaš'] : ['Klen', 'Deverika', 'Skobalj'];
    }
  }

  static _Band _band(double t) {
    if (t < 8) return _Band.cold;
    if (t < 14) return _Band.cool;
    if (t <= 20) return _Band.mild;
    return _Band.warm;
  }
}

enum _Band { cold, cool, mild, warm }
