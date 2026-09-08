import '../models/school_lesson.dart';
import 'school_diagrams.dart';

/// Škola ribolova — statični sadržaj lekcija.
///
/// Oznake po pravilu: `LessonNote.ok(...)` = potvrđeno izvorom
/// (zvanični propis iz `fishing_seasons.dart`, istraživanje iz
/// `docs/METHOD_TAB.md` / `docs/research/`), obična `LessonNote(...)` =
/// uobičajena praksa i naša heuristika, nije potvrđeno izvorom.
///
/// Pravila koja dolaze iz našeg skor engine-a (`fishing_score.dart`) NISU
/// označena kao potvrđena — to je naš model, ne izvor.
///
/// Svaka lekcija nosi temu (može ih biti više — čvorovi i uslovi služe svakoj
/// tehnici), nivo znanja i tip teksta.
///
/// `Kind.blog` je zasad prazan: tuđi tekstovi se NE koriste kao naš blog
/// sadržaj (odluka 2026-09-08) — feeder.rs i slični su istraživački ulaz,
/// saznanja su u `docs/research/2026-09-08-feeder-rs-research.md`. Blog čeka
/// naše originalne tekstove; prekidač se ne prikazuje dok ih nema.
const schoolLessons = <SchoolLesson>[
  // ── OPŠTE ────────────────────────────────────────────────────────────────
  SchoolLesson(
    id: 'oprema',
    emoji: '🎒',
    title: 'Prva oprema',
    subtitle: 'Šta kupiti prvo, a šta ne',
    tags: [Topic.opste, Topic.feeder],
    level: Level.pocetnik,
    lead: 'Najčešća greška početnika nije loš štap — nego tri štapa i nijedan '
        'meredov. Ovo je redosled kupovine koji radi: prvo ono bez čega ne '
        'možeš bacati, pa ono bez čega ne možeš izvaditi ribu, pa sve ostalo.',
    sections: [
      LessonSection(
        title: 'Prvi komplet — redom',
        notes: [
          LessonNote('1. Feeder štap. Kanali, manje reke i jezera: 3,0–3,3 m, '
              'test 30–60 g. Velike reke (Dunav, Sava, Tisa): 3,6–3,9 m, 80–120 g.'),
          LessonNote('2. Rolna 3000–4000, dublji špul za daljinu. Prenos oko 5:1 '
              'je dovoljan — bitniji su ravnomeran namotaj i meka kočnica od broja ležajeva.'),
          LessonNote('3. Monofil 0,20–0,25 mm kao glavni. Elastičnost gasi trzaje '
              'i čuva usnu; upletenica dolazi kasnije.'),
          LessonNote('4. Dve hranilice iste vrste, različite težine (npr. 30 i 50 g) '
              '— da imaš rezervu i da možeš da promeniš teret bez menjanja tipa.'),
          LessonNote('5. Udice 12 i 14 za crva i glistu, 10 za pelet i kukuruz. '
              'Vrtila, perlice, stoperi.'),
          LessonNote('6. Meredov. Ne preskači ga — bez njega se krupnija riba vadi '
              'rukom ili se gubi, a i jedno i drugo je loše.'),
        ],
      ),
      LessonSection(
        title: 'Ne kupuj na početku',
        notes: [
          LessonNote('Tri štapa odjednom. Nauči jedan pa vidi šta ti fali.'),
          LessonNote('Upletenicu kao prvi najlon. Nema rastezanja, pa svaka greška '
              'u kočnici i zabodu ide direktno u usnu.'),
          LessonNote('Elektronske signalizatore. Vrh feeder štapa je precizniji '
              'pokazivač trzaja od zvuka.'),
          LessonNote('Skupu primamu. Razlika se vidi kad već znaš da hraniš mesto.'),
        ],
      ),
      LessonSection(
        title: 'Uporedi najlone',
        comparator: ComparatorSet(
          specLabels: ['Rastezanje', 'Prenos trzaja', 'Vidljivost u vodi', 'Gde ide'],
          items: [
            ComparatorItem(
              id: 'mono',
              name: 'Monofil',
              tagline: 'Rasteže se — elastičnost gasi trzaje i čuva usnu.',
              svg: kLineMono,
              specs: [
                'Rasteže se najviše',
                'Blaži — deo trzaja se izgubi u rastezanju',
                'Vidljiv',
                'Glavni najlon za početnika, 0,20–0,25 mm',
              ],
            ),
            ComparatorItem(
              id: 'braid',
              name: 'Upletenica',
              tagline: 'Ne rasteže se — svaki trzaj dolazi ceo do vrha štapa.',
              svg: kLineBraid,
              specs: [
                'Praktično nula',
                'Pun — vidiš i najmanji trzaj na 60 m',
                'Vidljiva, i debljina obmanjuje',
                'Daljina i struja, 0,10–0,12 mm; traži šok lider',
              ],
            ),
            ComparatorItem(
              id: 'fluoro',
              name: 'Fluorokarbon',
              tagline: 'U vodi se praktično ne vidi — za opreznu ribu.',
              svg: kLineFluoro,
              specs: [
                'Malo — između monofila i upletenice',
                'Dobar',
                'Skoro nevidljiv',
                'Predvez i lider, ne glavni najlon',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote('Monofil je prvi izbor jer greške oprašta — rastezanje gasi '
              'prejak zabod i trzaje krupne ribe.'),
          LessonNote('Upletenicu uzimaš kad ti trzaj na 60 m nestaje u rastezanju. '
              'Ali bez šok lidera puca na zamahu, a bez meke kočnice kida usnu.'),
          LessonNote.ok('Na UL varalici je fluorokarbonski lider 4 lb, oko 50 cm, '
              'obavezan — bistra voda i oprezna riba inače ne rade.'),
          LessonNote.ok('Dijametar se bira PO TEŽINI hranilice, ne po ribi: '
              '0,16 mm sa 15–20 g (kanal, bara) · 0,18 mm sa 40 g '
              '(univerzalno) · 0,22–0,25 mm sa 60–80 g (jaka struja, '
              'komercijalni reviri).'),
          LessonNote.ok('Debelji najlon pravi veći otpor u vodi, pa traži i '
              'težu hranilicu da drži mesto — zato se ne uzima „debelje za '
              'svaki slučaj".'),
          LessonNote.ok('Održavanje: skini poslednja 3 m posle svakog izlaska '
              'i prebriši najlon krpom. UV je najbrži ubica — ne kupuj sa '
              'izloga na suncu i proveri datum proizvodnje.'),
        ],
      ),
      LessonSection(
        title: 'Predvez i šok lider',
        notes: [
          LessonNote('Predvez uvek tanji od glavne (npr. 0,16–0,18 na 0,22) — '
              'kad zakači, puca predvez, a ne cela montaža.'),
          LessonNote('Šok lider 8–10 m monofila 0,28–0,30 mm kad bacaš teže od 60 g. '
              'Upletenica bez lidera puca na zamahu.'),
        ],
      ),
      LessonSection(
        title: 'Sitan pribor',
        notes: [
          LessonNote.ok('Vrtilo na kraju glavnog najlona — sprečava uvijanje '
              'strune pri izvlačenju.'),
          LessonNote.ok('Quick-change vrtilo za brzu zamenu predveza kad je '
              'udica tupa, polomljena ili pogrešne dužine.'),
          LessonNote.ok('Kopča za hranilicu je dvodelna (vrtilo gore, kopča '
              'dole); bolje verzije imaju protivkuku.'),
          LessonNote.ok('Stoperi (guma, mek plastik ili silikon) čuvaju čvor '
              'od dodira sa delovima, ograničavaju put udice od hranilice i '
              'klizanje hranilice po najlonu.'),
          LessonNote.ok('Vadilica za udicu — za duboko zagutanu ribu, ali '
              'korisna u svakom slučaju, jer smanjuje povredu.'),
          LessonNote.ok('Za hair rig: burgija za bušenje mamca, igla za '
              'provlačenje niti i stoper da mamac ne sklizne pri zabačaju.'),
          LessonNote('Vezivač udica i vezivač petlji — pomažu ako ti oči ili '
              'prsti otkazuju na sitnim udicama, i daju jednake petlje na '
              'svim predvezima.'),
        ],
      ),
      LessonSection(
        title: 'Ostalo što se zaboravi',
        notes: [
          LessonNote('Vlažna podloga ili prostirka, kliješta za vađenje udice, '
              'makaze, kofa za vodu, čuvarica samo ako ti je zaista potrebna.'),
          LessonNote('Držač štapa (rod pod) — bez njega vrh ne stoji mirno i '
              'ne vidiš trzaj.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'po-vrstama',
    emoji: '🐟',
    title: 'Po vrstama',
    subtitle: 'Gde, kada i čime po ribi',
    tags: [Topic.opste, Topic.feeder, Topic.varalica, Topic.plovak],
    level: Level.pocetnik,
    lead: 'Ista voda u isti dan daje različitu ribu na različitoj dubini i '
        'mamcu. Ovo je kratak ključ: gde stoji, kad jede, čime se hvata.',
    sections: [
      LessonSection(
        title: 'Bela riba',
        notes: [
          LessonNote('Deverika: dno, mulj, sporija voda. Crv, glista, sitan pelet. '
              'Fina primama, češće a manje.'),
          LessonNote.ok('Deverika je riba dna — tu najviše i boravi i jede. '
              'Živi u jezerima, kanalima i donjim tokovima reka, a kako '
              'temperatura pada seli se u dublje.'),
          LessonNote.ok('Krupni primerci su vrlo plašljivi i oprezni — predvez '
              'im ide i do metar i po.'),
          LessonNote.ok('Proleće i jesen: gliste i larve (protein). Leto: '
              'kukuruz, hleb, testo.'),
          LessonNote.ok('Proleće ceo dan, najaktivnija u najtoplijem delu; '
              'leto jutro i večer; jesen sve duži periodi.'),
          LessonNote('Bodorka i babuška: plićak i srednja dubina, sitan mamac, '
              'brz ritam hranjenja.'),
          LessonNote('Skobalj i klen: brzaci i ivice struje, bistra voda, '
              'lakša montaža.'),
          LessonNote('Mrena: struja i kameno dno. Gliste i crvi, teža hranilica '
              'koja drži mesto.'),
        ],
      ),
      LessonSection(
        title: 'Šaran i amur',
        notes: [
          LessonNote('Šaran: 16–24 °C najbolje. Method, pelet, kukuruz. Jedna '
              'tačka, više hrane, mir na obali.'),
          LessonNote('Amur: topla voda, srednji sloj i površina. Kukuruz, testo, '
              'biljni mamci. Vrlo osetljiv na buku.'),
        ],
      ),
      LessonSection(
        title: 'Grabljivica',
        notes: [
          LessonNote('Smuđ i štuka: varalica, zora i sumrak, bistrija voda. '
              'Smuđ uz dno, štuka uz travu i prepreke.'),
          LessonNote('Som: mrak, jame i dubine, blizu prepreka. Topla voda.'),
          LessonNote.ok('Štuka po veličini reaguje različito na temperaturu: '
              'sitna (~0,5 kg) staje početkom zime, krupna 4–7,5 kg vrhuni u '
              'blagoj jeseni, kapitalna 15 kg+ u nizijskom letu praktično ne jede.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'bonton-zakon',
    emoji: '⚖️',
    title: 'Bonton i zakon',
    subtitle: 'Dozvola, lovostaj, mere, ophođenje',
    tags: [Topic.opste, Topic.feeder, Topic.varalica, Topic.plovak],
    level: Level.pocetnik,
    lead: 'Dozvola i lovostaj nisu formalnost — kazna je veća od cele opreme. '
        'A bonton je ono što odlučuje da li će voda i za pet godina davati ribu.',
    sections: [
      LessonSection(
        title: 'Pre izlaska',
        notes: [
          LessonNote.ok('Dozvola je obavezna. Zaštićena područja (nacionalni '
              'parkovi, rezervati) traže posebnu dozvolu — cene su u tabu Propisi.'),
          LessonNote.ok('Proveri lovostaj i najmanju meru za vrstu koju ciljaš. '
              'Ceo spisak je u tabu Propisi.'),
          LessonNote.ok('Pastrmski reviri imaju svoja pravila (C&R, samo '
              'artificijelni mamci, udice bez kontre, ograničenja veličine varalice) '
              'i razlikuju se od revira do revira — proveri pravila tog revira.'),
        ],
      ),
      LessonSection(
        title: 'Lovostaj — najčešće vrste',
        notes: [
          LessonNote.ok('Šaran: 1.4–31.5, najmanja mera 30 cm.'),
          LessonNote.ok('Smuđ: 1.3–30.4, 40 cm.'),
          LessonNote.ok('Štuka: 1.2–31.3, 40 cm.'),
          LessonNote.ok('Som: 1.5–15.6, 60 cm.'),
          LessonNote.ok('Deverika, klen, skobalj, plotica: 15.4–31.5, 20 cm.'),
          LessonNote.ok('Mrena: 15.4–31.5, 25 cm.'),
          LessonNote.ok('Salmonidi (mladica, lipljen, pastrmka): zabranjen ribolov '
              '21–03 letnje / 18–05 zimsko računanje vremena.'),
        ],
      ),
      LessonSection(
        title: 'Nikad ne zadržavaj',
        notes: [
          LessonNote.ok('Trajno zabranjene vrste: kečiga i jeseterske vrste, '
              'zlatni karaš, linjak, čikov, jegulja, vretenar, belka, crnka, '
              'rečni rak, pegunica, vijunica. Puštaju se odmah.'),
        ],
      ),
      LessonSection(
        title: 'Bonton',
        notes: [
          LessonNote('Mokre ruke i mokra podloga pri vađenju. Nikad ribu na '
              'suvu travu ili pesak — skida sluz i ljusku.'),
          LessonNote('Vlažan džak ili mreža, kratko. Fotografiši nisko nad vodom '
              'i pusti ribu odmah.'),
          LessonNote('Smeće nosiš kući — i najlon i olovo. Najlon na obali ubija '
              'ptice.'),
          LessonNote('Ne zauzimaj tuđe mesto i ne baca se preko tuđeg najlona. '
              'Pozdrav i pitanje „ima li mesta" rešavaju sve.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'citanje-vode',
    emoji: '🌊',
    title: 'Čitanje vode',
    subtitle: 'Uslovi, dno, gde stoji riba',
    tags: [Topic.opste, Topic.feeder, Topic.varalica, Topic.plovak],
    level: Level.srednji,
    lead: 'Ovo je lekcija koja ti štedi cele izlaske. Ista oprema i ista '
        'primama daju sasvim drugi rezultat po pritisku, temperaturi vode i '
        'vodostaju — a to je isto ono što app meri i sabira u skor.',
    sections: [
      LessonSection(
        title: 'Uslovi (isto što meri skor u app-u)',
        notes: [
          LessonNote('Pritisak: stabilan ili blagi pad (pre-frontalni prozor) je '
              'najbolji. Brzi pad ili brzi rast — riba se gasi.'),
          LessonNote('Temperatura vode: deverika 14–22 °C, šaran 16–24 °C, '
              'mrena 14–20 °C = pun apetit. Pod 4 °C i preko 30 °C skoro ništa.'),
          LessonNote('Vodostaj: blagi porast puni obalu i pokreće belu ribu. '
              'Veliki porast ili veliki pad — loše.'),
          LessonNote.ok('Za smuđa porast donosi ribu, ali vrh je 2–3 dana POSLE '
              'porasta, kad se nivo izravna. Ako se vrati na staro ili niže, '
              'bolje da nije ni došao.'),
          LessonNote('Vetar: topao južni i jugozapadni podstiče hranjenje, '
              'hladan istočni je najgori.'),
          LessonNote('Mutnoća: blago mutna voda krije pecaroša i bela riba je '
              'smelija. Jako mutna — riba ne nalazi mamac.'),
          LessonNote.ok('Naglа promena vremena je okidač za hranjenje: vetar koji '
              'krene ili stane, kiša koja krene ili stane, naglo razvedravanje.'),
        ],
      ),
      LessonSection(
        title: 'Gde stoji riba',
        notes: [
          LessonNote('Unutrašnja strana krivine — mirnija voda i mulj, tu se '
              'skuplja hrana.'),
          LessonNote('Ivica brzaka i prelaz plićaka u dubinu — riba stoji u '
              'dubljem, hrani se na ivici.'),
          LessonNote('Ušća potoka posle kiše — donose hranu i mutnu vodu.'),
          LessonNote('Prepreke: potopljeno drvo, kamen, stub mosta. Grabljivica '
              'čeka tu.'),
        ],
      ),
      LessonSection(
        title: 'Vreme dana',
        notes: [
          LessonNote('Zora i sumrak: grabljivica jede jako, bela riba blaže. '
              'App ti daje bonus na skor u tim satima.'),
          LessonNote('Leto: rano jutro i noć. Zima: sredina dana, kad se voda '
              'malo zagreje.'),
          LessonNote.ok('Mlad i pun mesec — riba je aktivnija.'),
        ],
      ),
    ],
  ),

  // ── FEEDER ───────────────────────────────────────────────────────────────
  SchoolLesson(
    id: 'hranilice',
    emoji: '🪝',
    title: 'Hranilice',
    subtitle: 'Šest tipova — uporedi ih',
    tags: [Topic.feeder],
    level: Level.pocetnik,
    lead: 'Hranilice se ne razlikuju po obliku nego po tome GDE i KADA primama '
        'izlazi. Cage je ispraznila pola tereta pre nego što je stigla do dna; '
        'window ga drži do samog dna. To je cela razlika — i od nje zavisi da '
        'li si nahranio ribu ili pola reke. Izaberi dva tipa i uporedi ih.',
    sections: [
      LessonSection(
        title: 'Uporedi tipove',
        comparator: ComparatorSet(
          specLabels: ['Otpuštanje', 'Domet', 'Gde', 'Primama', 'Za početnika'],
          items: [
            ComparatorItem(
              id: 'cage',
              name: 'Cage / kavez',
              tagline: 'Mrežasti kavez — pušta primamu na sve strane, već u padu.',
              svg: kFeederCage,
              specs: [
                'Najbrže — pušta već dok pada',
                'Mali',
                'Plitko, stajaća voda do ~4 m',
                'Primama; pravi oblak mirisa',
                'Da — vidiš šta radi',
              ],
            ),
            ComparatorItem(
              id: 'open',
              name: 'Open-end',
              tagline: 'Otvorena na oba kraja — pušta postepeno kad legne na dno.',
              svg: kFeederOpen,
              specs: [
                'Postepeno, kad legne na dno',
                'Srednji',
                'Sve-namenska: bare, kanali, mirne reke',
                'Primama, crvi, kaster, pelet, partikl',
                'Da — prva hranilica koju kupuješ',
              ],
            ),
            ComparatorItem(
              id: 'window',
              name: 'Window',
              tagline: 'Olovo ulivano u bazu, leti kao kugla — za daljinu i vetar.',
              svg: kFeederWindow,
              specs: [
                'Drži teret do dna, pa ga prosipa kroz prozore',
                'Najveći — 60–80 m',
                'Daljina i vetar',
                'Primama + partikl',
                'Ne — prvo nauči zabačaj',
              ],
            ),
            ComparatorItem(
              id: 'method',
              name: 'Method',
              tagline: 'Primama oblepljena spolja, mamac leži na njoj.',
              svg: kFeederMethod,
              specs: [
                'Primama se raspada oko tela, mamac odmah do nje',
                'Srednji',
                'Šaran i amur na dnu',
                'Method primama, pelet 2 mm',
                'Da — za šarana najlakši ulaz',
              ],
            ),
            ComparatorItem(
              id: 'pellet',
              name: 'Pellet',
              tagline: 'Zatvorena sa strane i odozgo — izlaz samo naprijed.',
              svg: kFeederPellet,
              specs: [
                'Samo kroz prednji otvor',
                'Kratko do srednje — najviše ~50 m, loša preciznost leta',
                'Kad ti treba najtešnja kupa',
                'Pelet, kukuruz',
                'Srednje',
              ],
            ),
            ComparatorItem(
              id: 'maggot',
              name: 'Maggot / za crve',
              tagline: 'Poklopci na krajevima — živi mamac ne izleti pri udaru.',
              svg: kFeederMaggot,
              specs: [
                'Kroz sitne otvore, kad skineš poklopac',
                'Srednji',
                'Neaktivna riba i hladna sezona',
                'Živi ili mrtvi crvi, seckane gliste, larve',
                'Da — za hladnu vodu najsigurniji izbor',
              ],
            ),
            ComparatorItem(
              id: 'hybrid',
              name: 'Hybrid',
              tagline: 'Između method i pellet — visoke strane čuvaju mamac u padu.',
              svg: kFeederHybrid,
              specs: [
                'Kontrolisano, kroz proreze u gornjoj polovini',
                'Srednji do veliki',
                'Dublja voda',
                'Pelet ili primama',
                'Ne — kad prevaziđeš method',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote.ok('Cage pušta primamu već dok pada — zato je za plitko, '
              'do ~4 m. U dubokom bi se ispraznila pre dna.'),
          LessonNote.ok('Kavezne se prave u oblicima: okrugla za stajaću i '
              'slabo tekuću vodu, kvadratna i pravougaona za slabo tekuću, a '
              '„tunelka" za jaku struju sa manjim teretom.'),
          LessonNote.ok('Maggot hranilica ima odvojive poklopce i puni se živim '
              'mamcem — tako crvi ne izlete pri udaru i propadanju, pa legnu '
              'tačno na dno.'),
          LessonNote.ok('Open-end je otvorena na oba kraja i pušta postepeno kad '
              'legne. Najsigurniji prvi izbor jer prima i primamu i crve i pelet, '
              'pa menjaš smešu bez menjanja hranilice.'),
          LessonNote.ok('Window drži teret do dna, pa ga prosipa kroz prozore. '
              'Olovo je ulivano u bazu i leti kao kugla — jedini tip koji rešava '
              '„daleko i uz vetar" (60–80 m).'),
          LessonNote.ok('Method nosi primamu oblepljenu spolja, a mamac leži na '
              'njoj. Ravno teško dno je uvek okrene mamcem gore.'),
          LessonNote.ok('Pellet je zatvorena sa strane — riba pristupa samo s '
              'prednje strane, pa daje najtešnju kupu.'),
          LessonNote.ok('Hybrid je između method i pellet: visoke strane čuvaju '
              'mamac u padu, pa je za dublju vodu.'),
        ],
      ),
      LessonSection(
        title: 'Koju prvu',
        notes: [
          LessonNote('Jedna open-end i jedna method pokrivaju 90% situacija na '
              'domaćim vodama. Window kupuješ kad ti zafali domet, pellet i '
              'hybrid kad počneš da doteruješ kupu.'),
          LessonNote('Uzmi istu hranilicu u dve težine pre nego drugi tip — '
              'češće ti fali teret nego drugačiji izlaz primame.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'feeder-abc',
    emoji: '🎯',
    title: 'Feeder ABC',
    subtitle: 'Težina, zabačaj, ritam',
    tags: [Topic.feeder],
    level: Level.pocetnik,
    lead: 'Kad znaš koju hranilicu, ostaje tri stvari: koliko teška, gde tačno '
        'i kako često. Zabačaj u istu tačku je važniji od svega ostalog — kupa '
        'se pravi samo tako.',
    sections: [
      LessonSection(
        title: 'Težina',
        notes: [
          LessonNote('Stajaća voda i kanali: 20–40 g. Srednja struja: 40–80 g. '
              'Velika voda (Dunav, Sava): 80–120 g.'),
          LessonNote('Pravilo: najlakša hranilica koja drži mesto. Ako je struja '
              'vuče niz vodu, dodaj 20 g i probaj ponovo.'),
          LessonNote.ok('Teret i najlon idu u paru: 15–20 g na 0,16 mm, '
              '40 g na 0,18 mm, 60–80 g na 0,22–0,25 mm. Preterano debeo '
              'najlon traži još teži teret jer sam pravi otpor u vodi.'),
        ],
      ),
      LessonSection(
        title: 'Zabačaj',
        notes: [
          LessonNote('Klipsuj najlon i uzmi orijentir na drugoj obali — svaki '
              'zabačaj mora u istu tačku, jer se samo tako pravi kupa.'),
          LessonNote('Prvo 4–6 punjenja bez udice (hranjenje), pa onda peca. '
              'Hraniš mesto, ne celu reku.'),
        ],
      ),
      LessonSection(
        title: 'Ritam',
        notes: [
          LessonNote('Kad je riba na mestu, skrati pauzu. Kad nema ništa 20–30 '
              'min, promeni dubinu ili udaljenost pre nego mamac.'),
          LessonNote('Vrh štapa mora biti napet ali ne prenapet — trzaj se '
              'vidi, a struja ga ne krivi stalno.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'primama-101',
    emoji: '🧺',
    title: 'Primama 101',
    subtitle: 'Mešanje, arome, boje, vezivanje',
    tags: [Topic.feeder, Topic.plovak],
    level: Level.srednji,
    lead: 'Primama nije hrana nego mamac za mesto. Cilj je da se veže za '
        'zabačaj i raspadne na dnu — ako se raspadne u vazduhu, nahranio si '
        'površinu; ako se ne raspadne, nisi nahranio nikoga.',
    sections: [
      LessonSection(
        title: 'Mešanje',
        notes: [
          LessonNote.ok('Vodu dodaj malo-po-malo, mešajući, dok smeša ne postane '
              'vlažna i teška. Nikad svu vodu odjednom — presipana smeša se ne '
              'popravlja.'),
          LessonNote.ok('Cilj: smeša se veže za zabačaj, a raspada na dnu. '
              '(Pravilo „maksimalno suvo" je sporno — ne drži na zabačaj.)'),
          LessonNote('Ostavi 10–15 min da upije, pa promešaj još jednom i prosej. '
              'Grudve otpuštaju neravnomerno.'),
          LessonNote.ok('Prosejavanje pre pecanja je obavezno: razbija grudve, '
              'izjednačava granulaciju, provetrava smešu (bolje se raspada u '
              'vodi) i ravnomerno raspoređuje aromu.'),
          LessonNote.ok('Sito 2–3 mm za suvu smešu, zemlju i fine prihrane; '
              '4–5 mm za krupnozrne smeše i method mikseve.'),
          LessonNote.ok('Pelet 2 mm ide u smešu kao vezivo.'),
          LessonNote.ok('Kvasi vodom SA MESTA na kom pecaš — nikad iz česme '
              'ni destilovanom.'),
          LessonNote.ok('Zapiši u graduisanoj posudi koliko je vode radilo, da '
              'se recept ponovi.'),
          LessonNote.ok('⚠ Kad si bacio, ne vraća se — ni voda, ni aditiv, ni '
              'loptica. Zato se doteruje prskalicom, a ne dolivanjem.'),
        ],
      ),
      LessonSection(
        title: 'Sastojci — šta šta radi',
        notes: [
          LessonNote.ok('Melasa ide PRVO U VODU, nikad direktno na suvu smešu.'),
          LessonNote.ok('Braon prezle dodaju masu bez promene mirisa; bele '
              'prezle lepe smešu.'),
          LessonNote.ok('Liofilizovane prezle daju grublju smešu — dodaju se u '
              'već navlaženi hleb da ne slepe previše.'),
          LessonNote.ok('Mlevena pržena konoplja je najjači pojačivač '
              'aktivnosti smeše.'),
          LessonNote.ok('Cela konoplja se kuva u ekspres loncu dok ~30% zrna '
              'ne pukne.'),
          LessonNote.ok('Kombinuj dve ili više komercijalnih prihrana da '
              'dobiješ svoje ponašanje, boju, slanost i slatkoću.'),
          LessonNote.ok('Partikl ide POSLE prosejavanja finalne smeše, u '
              'maloj količini i odvojenoj posudi. Nikad pre-navlažen pelet u '
              'gotovu smešu — upija vlagu i menja joj svojstva.'),
        ],
      ),
      LessonSection(
        title: 'Boja i aroma',
        notes: [
          LessonNote('Bistra voda i plašljiva riba → tamnija smeša. Mutna ili '
              'topla voda → svetlija, riba je lakše nalazi.'),
          LessonNote('Zima: manje arome, slatko-mlečno. Leto: više arome, '
              'začinsko i riblje. Hladna voda ne nosi miris kao topla.'),
        ],
      ),
      LessonSection(
        title: 'Traper linija',
        notes: [
          LessonNote.ok('GST Method — high-protein baza za method.'),
          LessonNote.ok('READY — pre-vlažena, gotova za upotrebu.'),
          LessonNote.ok('Pop-Up Dumbells — hookbait.'),
          LessonNote('Konkretan recept za tvoju vodu i sezonu je u tabu Traper i '
              'na ekranu rezultata.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'method-skola',
    emoji: '📖',
    title: 'Method škola',
    subtitle: 'Method feeder od nule',
    tags: [Topic.feeder],
    level: Level.srednji,
    lead: 'Method je najkraći put do šarana: mamac leži na hrani, a riba se '
        'sama zabada o težinu hranilice. Zato je i najmanje oprostiv za greške '
        'u smeši — ovde se sve svodi na to koliko se raspada i kada.',
    sections: [
      LessonSection(
        title: 'Šta ga razlikuje od klasičnog feedera',
        notes: [
          LessonNote.ok('Najlon prolazi KROZ hranilicu, ne klizi pored nje.'),
          LessonNote.ok('Kraći predvezi, veće i jače udice, debljи glavni '
              'najlon i strukturno drugačija smeša.'),
          LessonNote.ok('Baca se ređe nego klasičnim feederom.'),
        ],
      ),
      LessonSection(
        title: 'Kada radi, a kada ne',
        notes: [
          LessonNote.ok('Radi: komercijalni reviri (tu nadmašuje klasične '
              'kavezne), slabo tekuće vode — Tamiš, Tisa, sporiji delovi Save '
              'i Dunava.'),
          LessonNote.ok('Radi: kad ciljaš krupnije primerke — šaran, krupan '
              'karaš, amur, krupna deverika, linjak; mrena na tekućoj vodi.'),
          LessonNote.ok('⚠ Retko kada radi na bržim strujama.'),
          LessonNote.ok('⚠ Nije za obimno početno hranjenje.'),
        ],
      ),
      LessonSection(
        title: 'Pribor za method',
        notes: [
          LessonNote.ok('Štap najmanje 40 g bacačke težine.'),
          LessonNote.ok('Glavni najlon 0,22–0,25 mm — debljи od klasičnog.'),
          LessonNote.ok('Predvez 0,12–0,22 mm, fluorokarbon ili monofil.'),
          LessonNote.ok('Udice kratkog struka i širokog otvora: 12/10/8 za '
              'sitniju ribu, 4/2 za šarana.'),
          LessonNote.ok('Mašinica sa širokom i plitkom špulom.'),
        ],
      ),
      LessonSection(
        title: 'Smeša',
        notes: [
          LessonNote.ok('Vodu dodaj malo-po-malo dok smeša ne postane vlažna i teška.'),
          LessonNote.ok('Cilj: veže za zabačaj → raspada se na dnu.'),
          LessonNote.ok('Pelet 2 mm vezuje smešu.'),
        ],
      ),
      LessonSection(
        title: 'Ritam hranjenja',
        notes: [
          LessonNote.ok('Hladna voda i zima: 2–3 mala punjenja, pa čekaj.'),
          LessonNote.ok('Topla voda: više punjenja i češće — riba brže troši.'),
        ],
      ),
      LessonSection(
        title: 'Hookbait',
        notes: [
          LessonNote.ok('Izbor po dnu: bottom (tvrdo dno), wafter (mešano), '
              'pop-up (mulj — mamac stoji nad muljem).'),
          LessonNote.ok('Traper method linija: GST Method, READY, Pellet 2 mm, '
              'Pop-Up Dumbells.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'montaze',
    emoji: '🎣',
    title: 'Montaže',
    subtitle: 'Inline, free-running, Ronnie, bezbednost',
    tags: [Topic.feeder],
    level: Level.srednji,
    lead: 'Montaža odlučuje dve stvari: da li ćeš videti trzaj i šta se '
        'dogodi ribi ako najlon pukne. Prvo je pitanje ulova, drugo je '
        'pitanje da li si pecaroš ili ne.',
    sections: [
      LessonSection(
        title: 'Uporedi montaže',
        comparator: ComparatorSet(
          specLabels: ['Kuda ide najlon', 'Kad najlon pukne', 'Samozabod', 'Kada je koristiš'],
          items: [
            ComparatorItem(
              id: 'inline',
              name: 'Inline',
              tagline: 'Najlon prolazi kroz centar hranilice.',
              svg: kRigInline,
              specs: [
                'Kroz telo hranilice, od vrha do dna',
                'Hranilica spada s najlona — zato je i nastala',
                'Jak — riba se zabada o težinu hranilice',
                'Method, šaran i amur na dnu',
              ],
            ),
            ComparatorItem(
              id: 'running',
              name: 'Free-running',
              tagline: 'Hranilica visi sa prstena koji klizi po najlonu.',
              svg: kRigRunning,
              specs: [
                'Prsten klizi po glavnoj struni',
                'Prsten sklizne s najlona',
                'Slab — glavni otpor je vrh štapa, ne hranilica',
                'Oprezna riba, nežnije prema usni',
              ],
            ),
            ComparatorItem(
              id: 'paternoster',
              name: 'Paternoster',
              tagline: 'Predvez na petlji, hranilica na donjem kraku.',
              svg: kRigPaternoster,
              specs: [
                'Predvez i hranilica na odvojenim kracima',
                'Zavisi od montaže — krak mora da popusti',
                'Nema — trzaj ide direktno u vrh štapa',
                'Klasičan feeder, bela riba, struja',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote.ok('Inline: najlon prolazi kroz centar hranilice. Bolja '
              'registracija trzaja, i — zato je i nastala — hranilica spada s '
              'najlona ako pukne, pa je riba ne vuče za sobom.'),
          LessonNote.ok('Free-running: hranilica slobodno klizi po najlonu. Riba '
              'izvlači najlon, a glavni otpor je vrh štapa — ne zabada se o '
              'težinu hranilice kao kod inline.'),
          LessonNote('Inline je jači samozabod, free-running je nežniji prema '
              'usni. Na komercijalnim revirima sa no-kill pravilima gledaj šta '
              'revir propisuje.'),
        ],
      ),
      LessonSection(
        title: 'Paternoster — stoper reguliše samozabod',
        notes: [
          LessonNote.ok('Sastav: karabin sa vrtilom, stoper, vrtilo (ili '
              'quick-change), glavni najlon, hranilica, vezana udica.'),
          LessonNote.ok('Upletena sekcija glavnog najlona iznad vrtila: '
              '10–15 cm. Čvor se navlaži pre zatezanja.'),
          LessonNote.ok('Gornji stoper određuje koliko hranilica sme da klizi, '
              'a time i jačinu samozaboda: 0–3 cm za plašljivu ribu, 10+ cm '
              'za aktivnu. Kad riba provuče najlon kroz karabin, sama se '
              'zabode.'),
          LessonNote('Plašljiva riba ispusti mamac ako odmah oseti teret — '
              'zato kratko klizanje. Aktivna riba beži i sama se nabode, pa '
              'tu duže klizanje radi u tvoju korist.'),
        ],
      ),
      LessonSection(
        title: 'Montiranje mamca — pet načina',
        notes: [
          LessonNote.ok('Direktno na udicu — kukuruz, testo, živi mamci.'),
          LessonNote.ok('Hair rig — bojli, pelet, tigrov orah; kroz izbušenu '
              'rupicu, mamac stoji pored udice.'),
          LessonNote.ok('Maggot prsten — grozd larvi na silikonskom prstenu.'),
          LessonNote.ok('Feeder prsten — gumeni prsten za cilindrični pelet.'),
          LessonNote.ok('Bodlja (šiljak) — uvijena žica, vezuje se D-čvorom '
              'ili uni čvorom. Razvijena pretežno za waftere.'),
          LessonNote.ok('Kod bodlje: hvatište poravnaj sa najnižom tačkom '
              'udice ili malo ispod, a veličina mamca mora biti srazmerna '
              'udici — inače zabod promašuje.'),
        ],
      ),
      LessonSection(
        title: 'Hair rig',
        notes: [
          LessonNote('Mamac stoji 1–2 cm od udice. Kraće za wafter, duže za bojli.'),
          LessonNote('Udica po mamcu: 12–14 za pelet 6 mm, 10–12 za pelet 8 mm '
              'i dumbell.'),
          LessonNote.ok('Ronnie (spinner) rig za pop-up — udica se slobodno okreće '
              'i hvata za usnu.'),
        ],
      ),
      LessonSection(
        title: 'Bezbednost ribe',
        notes: [
          LessonNote.ok('Montaža mora da otpusti hranilicu ako najlon pukne — '
              'riba koja vuče hranilicu za sobom ugine.'),
          LessonNote('Proveri predvez posle svake veće ribe; istrošen predvez '
              'puca u najgorem trenutku.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'cvorovi',
    emoji: '🪢',
    title: 'Čvorovi',
    subtitle: 'Spajanje najlona i petlje',
    tags: [Topic.opste, Topic.feeder, Topic.varalica, Topic.plovak],
    level: Level.pocetnik,
    lead: 'Ovde su čvorovi kojima se najlon spaja sa najlonom — predvez na '
        'glavnu, upletenica na šok lider, petlja na kraj. Čvorovi za udicu su '
        'u svojoj lekciji. Jedno pravilo je iznad svih: nakvasi pre zatezanja. '
        'Suvo zatezanje pregoreva najlon i odnese pola nosivosti.',
    sections: [
      LessonSection(
        title: '1 · Dupla petlja (surgeon\'s loop)',
        sequence: StepSequence(
          purpose: 'Petlja na kraju predveza i na kraju glavne strune — osnova '
              'za loop-to-loop.',
          steps: [
            ProcedureStep('Presavij kraj najlona na duplo, oko 10 cm.'),
            ProcedureStep('Napravi običan uzao presavijenim delom, ali ne '
                'zatežeš.'),
            ProcedureStep('Provuci petlju kroz uzao još jednom — otud „dupla".'),
            ProcedureStep('Nakvasi i zategni. Petlja ostaje mala, oko 1 cm.'),
          ],
          videoUrl: 'https://www.youtube.com/results?search_query=surgeons+loop+knot',
          videoLabel: 'Vidi video — Dupla petlja',
          mistakes: [
            LessonNote('Prevelika petlja se zapetljava o hranilicu pri '
                'zabačaju.'),
          ],
        ),
      ),
      LessonSection(
        title: '2 · Loop-to-loop',
        sequence: StepSequence(
          purpose: 'Spaja predvez i glavnu strunu. Jedina veza koju menjaš u '
              'sekundi na vodi, mokrim rukama.',
          steps: [
            ProcedureStep('Provuci petlju predveza kroz petlju glavne strune.'),
            ProcedureStep('Provuci ceo predvez (sa udicom) kroz svoju petlju.'),
            ProcedureStep('Zategni obe strane. Veza legne kao dva spojena '
                'prstena, bez preklapanja.'),
          ],
          videoUrl: 'https://www.youtube.com/results?search_query=loop+to+loop+connection+fishing',
          videoLabel: 'Vidi video — Loop-to-loop',
          mistakes: [
            LessonNote('Nepravilno provučeno pa veza legne u „krst" — tu se '
                'najlon reže sam o sebe.'),
            LessonNote.ok('Zato predvezi idu unaprijed vezani kod kuće, na '
                'držaču — ne vezuju se na obali.'),
          ],
        ),
      ),
      LessonSection(
        title: '3 · Uni-na-uni',
        sequence: StepSequence(
          purpose: 'Spaja dva najlona približno istog preseka. Jači od '
              'surgeon i blood čvora.',
          strength: 'do 90%',
          steps: [
            ProcedureStep.ok('Preklopi dva najlona tako da se paralelno '
                'poklapaju oko 15 cm.'),
            ProcedureStep.ok('Prvim najlonom napravi uni čvor oko drugog — '
                'pet namotaja unutar petlje.'),
            ProcedureStep.ok('Ponovi isto drugim najlonom oko prvog.'),
            ProcedureStep.ok('Nakvasi, zategni svaki čvor pojedinačno, pa '
                'povuci oba najlona da se čvorovi spoje.'),
          ],
          videoUrl: 'https://www.youtube.com/results?search_query=uni+to+uni+knot',
          videoLabel: 'Vidi video — Uni-na-uni',
        ),
      ),
      LessonSection(
        title: '4 · Albright — upletenica na šok lider',
        sequence: StepSequence(
          purpose: 'Spaja dva najlona RAZLIČITOG preseka. Ravan je i prolazi '
              'kroz vođice — bez njega nema šok lidera.',
          strength: '~90%',
          steps: [
            ProcedureStep.ok('Napravi petlju u debljem najlonu.'),
            ProcedureStep.ok('Provuci kraj tanjeg najlona kroz tu petlju.'),
            ProcedureStep.ok('Obmotaj tanjim deset puta, počevši od baze '
                'petlje ka njenom vrhu.'),
            ProcedureStep.ok('Vrati kraj tanjeg natrag kroz petlju, na istu '
                'stranu na koju je i ušao.'),
            ProcedureStep.ok('Zategni suprotne krajeve i odreži oba viška.'),
          ],
          videoUrl: 'https://www.youtube.com/results?search_query=albright+knot',
          videoLabel: 'Vidi video — Albright',
          mistakes: [
            LessonNote('Manje od deset namotaja — na upletenici klizi.'),
            LessonNote('Kraj vraćen na pogrešnu stranu petlje; čvor se ne '
                'zaključa.'),
          ],
        ),
        notes: [
          LessonNote.ok('Šok lider je 8–10 m monofila 0,28–0,30 mm i obavezan '
              'je kad bacaš teže od 60 g — upletenica bez njega puca na '
              'zamahu.'),
        ],
      ),
      LessonSection(
        title: 'Pravila za svaki čvor',
        notes: [
          LessonNote.ok('Nakvasi pre zatezanja. Bez izuzetka.'),
          LessonNote('Zatežeš polako i ravnomerno, ne trzajem.'),
          LessonNote('Ostavi 2–3 mm viška pri rezanju — čvor se pod teretom '
                'još malo skupi.'),
          LessonNote('Predvez uvek tanji od glavne — kad zakači, puca predvez '
              'a ne cela montaža.'),
          LessonNote('Proveri čvor posle svake veće ribe i posle zakačke.'),
        ],
      ),
    ],
  ),
  SchoolLesson(
    id: 'ribe-srbije',
    emoji: '🗺️',
    title: 'Ribe i vode Srbije',
    subtitle: 'Koja vrsta na kojoj vodi',
    tags: [Topic.opste, Topic.varalica],
    level: Level.srednji,
    lead: 'Nema smisla tražiti basa na Dunavu ni mladicu u Vojvodini. Ovo je '
        'karta: koja vrsta zaista živi na kojoj vodi u Srbiji, po dodeli iz '
        'našeg istraživanja.',
    sections: [
      LessonSection(
        title: 'Grabljivica po vodama',
        notes: [
          LessonNote.ok('Bucov: Dunav, Sava, Tisa, donja Drina, Velika Morava.'),
          LessonNote.ok('Mladica: Drina, Lim, Uvac, Vapa.'),
          LessonNote.ok('Potočna i kalifornijska pastrmka: Mlava, Rzav, Đetinja, '
              'Piva, Tara, Vapa, Uvac.'),
          LessonNote.ok('Bandar: Vlasinsko jezero i Timok.'),
          LessonNote.ok('Bas: Stari Bački kanal — i praktično nigde drugde.'),
          LessonNote.ok('Smuđ i štuka: velike nizijske reke i jezera, najšire '
              'rasprostranjene varaličarske vrste.'),
        ],
      ),
      LessonSection(
        title: 'Bela riba i mrenaste vrste',
        notes: [
          LessonNote('Skobalj, plotica i mrena: brzaci i kameno dno — Drina je '
              'referentna voda za otpuštanje.'),
          LessonNote('Deverika, bodorka, babuška: kanali, bare, mirni delovi '
              'velikih reka.'),
          LessonNote('Klen: male reke i ivice struje, hvata se i na varalicu i '
              'na plovak.'),
        ],
      ),
      LessonSection(
        title: 'Pre nego kreneš',
        notes: [
          LessonNote.ok('Pastrmski reviri imaju svoja pravila po reviru (C&R, '
              'samo artificijelni mamci, udice bez kontre, ograničenja veličine '
              'varalice) — proveri pravila tog revira, ne generalno.'),
          LessonNote('U app-u su vode i vrste povezane: izaberi vodu na Mapi i '
              'Result ekran ti kaže koje su vrste sada aktivne.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'temp-godina',
    emoji: '🌡️',
    title: 'Temperatura vode kroz godinu',
    subtitle: 'Zašto isti mamac ne radi u martu i julu',
    tags: [Topic.opste, Topic.feeder, Topic.varalica, Topic.plovak],
    level: Level.napredni,
    lead: 'Temperatura vode je jedini faktor koji menja sve ostalo: koliko riba '
        'jede, na kojoj dubini stoji, koliko primame trpi i koliko sporo mora '
        'da ide varalica. Ako naučiš samo jedan parametar, nauči ovaj.',
    sections: [
      LessonSection(
        title: 'Zašto vazduh nije voda',
        notes: [
          LessonNote('Voda se greje i hladi mnogo sporije od vazduha. Topao dan '
              'u martu ne znači toplu vodu, a hladno jutro u avgustu ne znači '
              'hladnu.'),
          LessonNote('App zato vuče PRAVU temperaturu vode sa najbliže RHMZ '
              'hidrološke stanice kad je ima, a procenu koristi samo kao rezervu.'),
          LessonNote('Plićak se greje prvi u proleće i hladi prvi u jesen — '
              'zato riba u proleće ide u plićak, a u jesen u dubinu.'),
        ],
      ),
      LessonSection(
        title: 'Bela riba i šaran',
        notes: [
          LessonNote('Pod 4 °C bela riba praktično staje — koliko god dobra bila '
              'ostala prognoza.'),
          LessonNote('8–14 °C: jede, ali sporo i malo. Manje primame, finiji '
              'predvez, sitniji mamac.'),
          LessonNote('14–22 °C za deveriku i 16–24 °C za šarana: pun apetit, '
              'najviše primame i najkrupniji mamac.'),
          LessonNote('Preko 28–30 °C kiseonik pada i riba se gasi — traži dublje '
              'i senovito, ili peca u zoru.'),
        ],
      ),
      LessonSection(
        title: 'Grabljivica ide obrnuto',
        notes: [
          LessonNote('Smuđ i štuka najbolje rade u 8–20 °C — dakle jesen, zima '
              'i rano proleće, kad bela riba staje.'),
          LessonNote.ok('Štuka po veličini reaguje različito: sitna (~0,5 kg) '
              'staje početkom zime, krupna 4–7,5 kg vrhuni u blagoj jeseni, a '
              'kapitalna 15 kg+ u nizijskom letu posti 2–2,5 meseca i hrani se '
              'pod ledom.'),
          LessonNote('Zato jedan „skor za štuku" kroz celu godinu nije tačan — '
              'zavisi koju veličinu ciljaš.'),
          LessonNote('Skobalj na otpuštanje je zimska riba: optimum je 4–14 °C, '
              'a decembar i januar su vrh sezone.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'vodostaj-grabljivica',
    emoji: '📈',
    title: 'Vodostaj i grabljivica',
    subtitle: 'Zašto se čeka 2–3 dana posle porasta',
    tags: [Topic.opste, Topic.varalica],
    level: Level.napredni,
    lead: 'Većina pecaroša izlazi kad voda raste. Prema izvoru sa tridesetak '
        'godina na Dunavu i Savi, to je dan-dva prerano — vrh nije u porastu '
        'nego u izravnanju posle njega.',
    sections: [
      LessonSection(
        title: 'Pravilo',
        notes: [
          LessonNote.ok('Porast donosi ribu, ali vrh je 2–3 dana POSLE porasta, '
              'kad se nivo izravna (±nekoliko cm).'),
          LessonNote.ok('Ako se nivo vrati na pređašnji ili niže — „bolje da nije '
              'ni došao". Aktivnost pada ispod početne.'),
          LessonNote('Praktično: prati vodostaj tri dana, ne jedan. Kada krivulja '
              'postane ravna, to je dan za izlazak.'),
        ],
      ),
      LessonSection(
        title: 'Šta app može, a šta ne',
        notes: [
          LessonNote('App sada čita samo trend (raste / pada / stabilan) i vidi '
              'današnji nivo plus četiri dana prognoze sa RHMZ-a.'),
          LessonNote('„Porast pa plato" zahteva ISTORIJU nivoa, koju hidmet ne '
              'objavljuje — zato ovo pravilo još nije u skoru, samo u savetu za '
              'varalicu.'),
          LessonNote('Do tada: pogledaj vodostaj u Result ekranu tri dana za redom '
              'i sam prepoznaj plato.'),
        ],
      ),
      LessonSection(
        title: 'Ostali okidači',
        notes: [
          LessonNote.ok('Naglа promena vremena pokreće hranjenje: vetar koji krene '
              'ili stane, kiša koja krene ili stane, naglo razvedravanje.'),
          LessonNote.ok('Mlad i pun mesec — riba je aktivnija.'),
          LessonNote.ok('Umerena mutnoća je dobra za grabljivicu, jaka mutnoća loša '
              '— varalica se ne vidi.'),
        ],
      ),
    ],
  ),

  // ── VARALICA ─────────────────────────────────────────────────────────────
  SchoolLesson(
    id: 'varalice',
    emoji: '🌀',
    title: 'Varalice',
    subtitle: 'Vrste i kada koja',
    tags: [Topic.varalica],
    level: Level.pocetnik,
    lead: 'Varalica ne mora da izgleda kao riba — mora da se ponaša kao ranjena '
        'riba. Zato se dele po tome ŠTA rade u vodi, a ne po tome kako izgledaju '
        'u kutiji.',
    sections: [
      LessonSection(
        title: 'Uporedi varalice',
        comparator: ComparatorSet(
          specLabels: ['Šta radi u vodi', 'Dubina', 'Veličina', 'Ciljna riba'],
          items: [
            ComparatorItem(
              id: 'shad',
              name: 'Shad na jig glavi',
              tagline: 'Ravna lopatica na repu vibrira i pri sporom vođenju.',
              svg: kLureShad,
              specs: [
                'Skakuće uz dno, lopatica vibrira',
                'Uz dno',
                '8–10 cm / 10–21 g; hladnije 10–12 cm / 14–28 g',
                'Smuđ, štuka',
              ],
            ),
            ComparatorItem(
              id: 'tvister',
              name: 'Tvister',
              tagline: 'Kovrdžavi rep trepće i na najsporijem motanju.',
              svg: kLureTvister,
              specs: [
                'Rep trepće čak i kad stoji u struji',
                'Uz dno i srednji sloj',
                '5–10 cm',
                'Smuđ, bandar, klen',
              ],
            ),
            ComparatorItem(
              id: 'mino',
              name: 'Mino vobler',
              tagline: 'Vitko telo, mala usna — pliva plitko, voli twitch.',
              svg: kLureMino,
              specs: [
                'Pliva ravnomerno, reaguje na twitch',
                'Površina do ~2 m',
                '7–11 cm',
                'Smuđ, klen, bucov',
              ],
            ),
            ComparatorItem(
              id: 'deep',
              name: 'Dubokoronac',
              tagline: 'Velika usna pod uglom ga vuče nisko.',
              svg: kLureDeep,
              specs: [
                'Velika usna ga obara na dubinu',
                '2–5 m; dubinu reguliše brzina i vrh štapa',
                '9–12 cm',
                'Smuđ i štuka na dubini',
              ],
            ),
            ComparatorItem(
              id: 'spoon',
              name: 'Kašika',
              tagline: 'Klati se levo-desno — geganje ranjene ribe.',
              svg: kLureSpoon,
              specs: [
                'Klati se u stranu, pravi vibraciju',
                'Sve — po težini i brzini',
                '15–28 g; na ledenoj vodi tanka do 80 mm / ~24 g',
                'Štuka, bucov, pastrmka',
              ],
            ),
            ComparatorItem(
              id: 'spinner',
              name: 'Spinnerbait',
              tagline: 'Listovi vibriraju, suknja i žica čuvaju udicu od zakačenja.',
              svg: kLureSpinner,
              specs: [
                'Listovi rotiraju, suknja krije udicu',
                'Površina do ~1,5 m',
                'Srednja do velika',
                'Štuka kroz travu i prepreke',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote('Gumeni mamci na jig glavi (shad, tvister): rade uz dno, '
              'skakuću. Najuniverzalnije i najjeftinije — počni odavde.'),
          LessonNote('Voblери: plivaju na zadatoj dubini. Mino je vitak i za '
              'twitch, dubokoronac ide nisko, suspending stoji u vodi kad staneš.'),
          LessonNote('Kašike i glavinjare: brzo pretraživanje nepoznatog terena. '
              'Rotiraju ili se klate, prave vibraciju.'),
          LessonNote('Spinnerbait i džig sa štitnikom: kroz travu i prepreke, '
              'gde bi se sve ostalo zakačilo.'),
        ],
      ),
      LessonSection(
        title: 'Veličine koje rade',
        notes: [
          LessonNote('Shad ili tvister 8–10 cm na glavi 10–21 g za blagu vodu; '
              '10–12 cm na 14–28 g kad je hladnije i dublje.'),
          LessonNote('Mino vobler 7–11 cm za smuđa i klena; suspending šed profil '
              '9–13 cm za zimsku štuku.'),
          LessonNote('Kašika 15–28 g za pretraživanje; velika tanka do 80 mm '
              '(~24 g) za sporo motanje na ledenoj vodi.'),
          LessonNote('Pravilo: najlakša jig glava kojom još osećaš dno. Preteška '
              'glava ubija igru.'),
        ],
      ),
      LessonSection(
        title: 'Prva kutija',
        notes: [
          LessonNote('Dve boje su dovoljne: prirodna (bela, srebrna, motoroil) za '
              'bistru vodu i jarka (šartrez, narandžasta) za mutnu i mrak.'),
          LessonNote('Nosi tri težine iste jig glave umesto tri različita mamca — '
              'dubina i struja se menjaju češće od ribljeg ukusa.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'ul-vs-klasik',
    emoji: '🎯',
    title: 'UL vs klasik',
    subtitle: 'Oprema za varalicu po ciljnoj ribi',
    tags: [Topic.varalica],
    level: Level.srednji,
    lead: 'Ne postoji jedan štap za varalicu. Klen od 300 g i štuka od 5 kg '
        'traže dva različita sistema, a greška u izboru se vidi odmah — '
        'prejak štap ne baca lake mamce, preslab ne izvlači krupnu ribu.',
    sections: [
      LessonSection(
        title: 'Tri klase',
        notes: [
          LessonNote.ok('UL (ultra-light): test 1–10 g. Klen, bandar, bas, '
              'pastrmka, bucov, mrena.'),
          LessonNote.ok('Klasik: 10–40 g. Smuđ i štuka — najčešća kombinacija '
              'na našim vodama.'),
          LessonNote.ok('Heavy / jerk: 40 g i više. Som, krupna štuka, mladica.'),
          LessonNote.ok('Međunarodno se UL računa strože (0,9–3,5 g), ali domaća '
              'i regionalna praksa ide do 10 g.'),
        ],
      ),
      LessonSection(
        title: 'Najlon na UL-u',
        notes: [
          LessonNote.ok('Upletenica 5–8 lb kao glavni.'),
          LessonNote.ok('Fluorokarbonski lider 4 lb, oko 50 cm — OBAVEZAN. '
              'Bez njega bistra voda i oprezna riba ne rade.'),
          LessonNote('Lider vezuješ albright ili uni-na-uni čvorom — vidi '
              'lekciju Čvorovi.'),
        ],
      ),
      LessonSection(
        title: 'Šta se dobija',
        notes: [
          LessonNote('UL ti otvara vrste koje klasik ne može da baci: klen na '
              'maloj reci, bandar na Vlasini, pastrmka na Rzavu.'),
          LessonNote('Klasik ostaje za smuđa i štuku, gde su glava i mamac '
              'preteški za UL, a riba dovoljno jaka da mu polomi vrh.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'vodjenje',
    emoji: '➰',
    title: 'Vođenje varalice',
    subtitle: 'Ritam je važniji od mamca',
    tags: [Topic.varalica],
    level: Level.srednji,
    lead: 'Isti mamac vođen na dva načina daje dva sasvim različita dana. '
        'Ritam se ne bira po ukusu nego po temperaturi vode — što je hladnija, '
        'to sporije i sa dužim pauzama.',
    sections: [
      LessonSection(
        title: 'Osnovna četiri',
        notes: [
          LessonNote('Džigovanje: dva odskoka pa pauza 2–4 s, prati kontakt sa '
              'dnom. Osnovni ritam za smuđa.'),
          LessonNote('Ravnomerno motanje sa twitch-evima: mino vobler, menjaj '
              'ritam dok ne nađeš okidač.'),
          LessonNote('Stop-and-go: motaj i staj. Napad dolazi u pauzi, skoro '
              'nikad u motanju.'),
          LessonNote('Sporo motanje bez pauza: velika tanka kašika koja se klati '
              '— oponaša geganje ranjene ribe u ledenoj vodi.'),
        ],
      ),
      LessonSection(
        title: 'Po temperaturi',
        notes: [
          LessonNote('Blaga voda: normalan ritam, agresivnije, više terena po satu.'),
          LessonNote('Hladna voda: džigovanje sa dužim pauzama, dublji delovi, '
              'uz strukture i prelaze.'),
          LessonNote.ok('Ledena voda: vrlo sporo, sa pauzama 15–20 s na dobrom '
              'mestu. Neutralna štuka pomeriće se najviše za dužinu svog tela.'),
        ],
      ),
      LessonSection(
        title: 'Dubina',
        notes: [
          LessonNote('Pravilo za hladno: pridneni sloj — 60–70% maksimalne dubine. '
              'Zimi je i najtopliji i najbogatiji kiseonikom.'),
          LessonNote('Ako ne znaš gde je riba, prvo pretraži kašikom po širini, '
              'pa onda usporavaj tamo gde je bilo kontakta.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'zimska-grabljivica',
    emoji: '🧊',
    title: 'Zimska štuka i smuđ',
    subtitle: 'Kad se lovi krupno, ne mnogo',
    tags: [Topic.varalica],
    level: Level.napredni,
    lead: 'Zima nije mrtva sezona za varalicu — nego sezona kad se broji krupno '
        'a ne mnogo. Sitna riba staje, kapitalna jede. Ali sve mora ići '
        'nekoliko puta sporije nego što ti se čini razumnim.',
    sections: [
      LessonSection(
        title: 'Mamci',
        notes: [
          LessonNote.ok('Suspending vobler šed profila 9–13 cm: parkiraj ga i '
              'pusti da lebdi. Jedan veći i širi radi bolje nego tri manja i uža.'),
          LessonNote.ok('Soft-jerk na worm udici 4/0–5/0, 11–15 cm, karolina rig: '
              'niski spori odskoci, ne dalje od 0,6 m od dna.'),
          LessonNote.ok('Velika tanka kašika do 80 mm (~24 g): sporo motanje bez '
              'pauza — geganje ranjene ribe.'),
          LessonNote.ok('Džig sa štitnikom, crno-plava suknja, king-size: iz čamca, '
              'paralelno sa linijom promene, najsporije moguće džigovanje.'),
        ],
      ),
      LessonSection(
        title: 'Miris je obavezan',
        notes: [
          LessonNote.ok('Brza varalica ne traži miris, nepokretna MORA da miriše. '
              'Fuluj soft-jerk i suknju aromom ribe ili raka.'),
          LessonNote('Bez arome nepomičan mamac na 15–20 s pauze je za ribu samo '
              'komad plastike.'),
        ],
      ),
      LessonSection(
        title: 'Šta očekivati',
        notes: [
          LessonNote.ok('Sitna štuka početkom zime praktično staje — cilj su '
              'krupni primerci.'),
          LessonNote.ok('Kapitalna štuka 15 kg+ u nizijskom letu ne jede 2–2,5 '
              'meseca, a pod ledom se hrani i dobija na težini.'),
          LessonNote('Malo trzaja po danu je normalno. Ovo je pecanje na jedan '
              'dobar kontakt, ne na brojeve.'),
        ],
      ),
    ],
  ),

  // ── PLOVAK ───────────────────────────────────────────────────────────────
  SchoolLesson(
    id: 'plovci',
    emoji: '🪄',
    title: 'Plovci',
    subtitle: 'Waggler, bolonjez i kada koji',
    tags: [Topic.plovak],
    level: Level.pocetnik,
    lead: 'Plovak nije samo pokazivač trzaja — on drži mamac na tačnoj dubini i '
        'nosi ga kroz vodu. Zato se bira po vodi i po vetru, a ne po boji.',
    sections: [
      LessonSection(
        title: 'Uporedi plovke',
        comparator: ComparatorSet(
          specLabels: ['Vezivanje za strunu', 'Voda', 'Štap', 'Opterećenje'],
          items: [
            ComparatorItem(
              id: 'waggler',
              name: 'Waggler',
              tagline: 'Vezuje se samo za donji kraj — jedna tačka.',
              svg: kFloatWaggler,
              specs: [
                'Samo donji prsten — jedna tačka',
                'Jezero, bara, mirni kanal',
                'Waggler štap 3,9–4,2 m',
                '2+1 g mirno; 3+2 g natopljen uz vetar',
              ],
            ),
            ComparatorItem(
              id: 'bolo',
              name: 'Bolonjez',
              tagline: 'Dve gumice, gore i dole — drži liniju u struji.',
              svg: kFloatBolo,
              specs: [
                'Dve gumice — gore i dole',
                'Reka, jača struja',
                'Bolonjez 4–5 m',
                '2–4 g slabija struja; 4–8 g jaka',
              ],
            ),
            ComparatorItem(
              id: 'trot',
              name: 'Za otpuštanje',
              tagline: 'Kratka debela antena — vidljiv dok ide niz vodu.',
              svg: kFloatTrot,
              specs: [
                'Dve gumice, kratka debela antena za vidljivost',
                'Reka po kamenu — vođenje niz vodu',
                'Bolonjez 4–5 m',
                'Po tehnici vođenja — vidi lekciju Otpuštanje',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote('Vezuje se samo za donji kraj, pa ga vetar i površinska '
              'struja manje nose. Za jezera, bare i mirne kanale.'),
          LessonNote('Jezero uz vetar: waggler sa opterećenjem 3+2 g, natopljen '
              'do vrha, i POTOPI strunu da je vetar ne vuče.'),
          LessonNote('Mirno: waggler 2+1 g je dovoljan — što lakši plovak, to '
              'osetljiviji trzaj.'),
          LessonNote('Štap: waggler 3,9–4,2 m.'),
        ],
      ),
      LessonSection(
        title: 'Bolonjez — reka',
        notes: [
          LessonNote('Teleskopski štap 4–5 m sa vođicama, plovak se vodi niz '
              'vodu. Za reke i jače struje.'),
          LessonNote('Jaka struja: bolonjez 4–8 g — mora da drži liniju.'),
          LessonNote('Slabija struja: 2–4 g, osetljivije.'),
        ],
      ),
      LessonSection(
        title: 'Dva različita pecanja',
        notes: [
          LessonNote.ok('Klasičan plovak i plovak na otpuštanje nisu ista tehnika. '
              'Klasičan = stajaća ili spora voda, hranjeno mesto, deverika, '
              'bodorka, šaran. Otpuštanje = rečno vođenje po kamenu, skobalj, '
              'mrena, plotica, klen.'),
          LessonNote('U app-u to vidiš kao prekidač na Result ekranu — samo na '
              'rekama, jer na jezeru otpuštanje nema smisla.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'olovljavanje',
    emoji: '⚖️',
    title: 'Olovljavanje',
    subtitle: 'Gde ide olovo i zašto',
    tags: [Topic.plovak],
    level: Level.srednji,
    lead: 'Raspored olova odlučuje kako mamac pada kroz vodu. Sve olovo uz '
        'plovak = mamac pada kao kamen, dobro kad riba stoji na dnu. Rasuto '
        'olovo = mamac lebdi nadole, dobro kad riba jede u prolazu.',
    sections: [
      LessonSection(
        title: 'Uporedi rasporede',
        comparator: ComparatorSet(
          specLabels: ['Raspored olova', 'Kako mamac pada', 'Voda', 'Kada'],
          items: [
            ComparatorItem(
              id: 'bulk',
              name: 'Bulk uz plovak',
              tagline: 'Sve olovo gore — mamac pada kao kamen.',
              svg: kShotBulk,
              specs: [
                'Sve zajedno uz plovak + dve sitne sačme na donjoj trećini',
                'Brzo i pravo do dna',
                'Stajaća voda',
                'Hladno, riba stoji nisko i sporo',
              ],
            ),
            ComparatorItem(
              id: 'stringer',
              name: 'Stringer',
              tagline: 'Opadajuće sačme — mamac lebdi kroz slojeve.',
              svg: kShotStringer,
              specs: [
                'Sačme nanizane po struni, sve manje ka udici',
                'Sporo, prirodan pad kroz slojeve',
                'Stajaća i slaba struja',
                'Riba jede u padu, ne na dnu',
              ],
            ),
            ComparatorItem(
              id: 'stream',
              name: 'Struja',
              tagline: 'Bulk na 2/3 dubine — drži liniju u struji.',
              svg: kShotStream,
              specs: [
                'Bulk na 2/3 dubine + jedna sačma 20 cm od udice',
                'Brzo, pa mamac drži liniju',
                'Reka, jača struja',
                'Bolonjez i vođenje niz vodu',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote('Bulk (sve zajedno) uz plovak, plus dve sitne sačme na donjoj '
              'trećini: brz pad, mamac odmah na dnu. Za stajaću vodu i hladno.'),
          LessonNote('Stringer (opadajuće sačme raspoređene po strun): prirodan '
              'pad mamca kroz slojeve. Za slabiju struju i ribu koja jede u padu.'),
          LessonNote('Struja: bulk na 2/3 dubine i jedna sačma 20 cm od udice — '
              'mora da drži liniju.'),
        ],
      ),
      LessonSection(
        title: 'Predvez i udica po temperaturi',
        notes: [
          LessonNote('Hladno: predvez 25–35 cm / 0,10–0,12 mm, udica 16–18. Riba '
              'stoji nisko i sporo — mamac mora da leži ili lebdi par cm iznad dna.'),
          LessonNote('Blago: 30–40 cm / 0,12–0,14 mm, udica 14–16.'),
          LessonNote('Toplo: 30–45 cm / 0,14–0,16 mm, udica 12–14.'),
        ],
      ),
      LessonSection(
        title: 'Ritam hranjenja',
        notes: [
          LessonNote('Hladno: minimalno — loptica veličine oraha na 10–15 min, '
              'ili samo šaka kastera.'),
          LessonNote('Blago: loptica na 5–8 min, gradi mesto polako.'),
          LessonNote('Toplo: mala loptica svakih 3–5 min plus partikl.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'otpustanje',
    emoji: '🏞️',
    title: 'Plovak na otpuštanje',
    subtitle: 'Četiri načina vođenja niz vodu',
    tags: [Topic.plovak],
    level: Level.napredni,
    lead: 'Otpuštanje je rečno pecanje po kamenu — skobalj, mrena, plotica, '
        'klen. Drina je referentna voda. Ovde ne hraniš mesto i ne čekaš: '
        'vodiš mamac niz vodu i kontrolišeš napetost strune. Zimski je, a '
        'decembar i januar su vrh.',
    sections: [
      LessonSection(
        title: 'Četiri tehnike vođenja',
        notes: [
          LessonNote.ok('Štopovanje: bulk 30 cm iznad udice, plovak postavljen '
              '10–20 cm DUBLJE od izmerene dubine. Mamac ide ispred plovka.'),
          LessonNote.ok('Španovanje: plovak na tačnoj dubini, laka stalna '
              'napetost. Ovo je tehnika za travu.'),
          LessonNote.ok('Zadržavanje: bulk pod plovkom plus 5–6 nanizanih sačmi. '
              'Za dno posuto krupnim kamenom.'),
          LessonNote.ok('Slobodno puštanje: nula napetosti. Plotica i zimski '
              'skobalj.'),
        ],
      ),
      LessonSection(
        title: 'Predvez',
        notes: [
          LessonNote.ok('Kraće od 30 cm na brzoj, plitkoj i ravnoj vodi.'),
          LessonNote.ok('Do 70 cm na dubokoj i nepravilnoj — nikad duže.'),
        ],
      ),
      LessonSection(
        title: 'Zašto je zimska tehnika',
        notes: [
          LessonNote('Optimum za skobalja je 4–14 °C, pa generička plovkarska '
              'kriva (12–22 °C) ovde vara — app zato za otpuštanje koristi '
              'posebnu, hladno pomerenu krivu.'),
          LessonNote('Otpuštanje i toleriše porast vodostaja bolje od klasičnog '
              'plovka.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'trava',
    emoji: '🌿',
    title: 'Trava (kladofora)',
    subtitle: 'Mamac koji bereš na vodi',
    tags: [Topic.plovak],
    level: Level.napredni,
    lead: 'Za skobalja na Drini najbolji mamac se ne kupuje nego bere — sa '
        'kamena u istoj reci u kojoj pecaš. To je alga kladofora, i sa njom '
        'ide jedno pravilo koje se protivi svemu ostalom u ribolovu: NE hraniš.',
    sections: [
      LessonSection(
        title: 'Šta je trava',
        notes: [
          LessonNote.ok('Alga kladofora (Cladophora glomerata), skida se sa '
              'kamena u istoj reci u kojoj pecaš.'),
          LessonNote.ok('Meka, raspadnuta alga je bolja od sveže.'),
          LessonNote.ok('„Maskirna" — zeleno-žuta sa crnim tačkama — vrhuni rano '
              'leto i kasna jesen.'),
        ],
      ),
      LessonSection(
        title: 'Pravilo hranjenja',
        notes: [
          LessonNote.ok('Kad pecaš na travu, NE hraniš. Riba je već na algi — '
              'primama je samo odvlači sa tvoje linije.'),
          LessonNote.ok('Kad pecaš na bele mamce (hleb, testo), hranjenje je '
              'OBAVEZNO. Tu logika radi obrnuto.'),
        ],
      ),
      LessonSection(
        title: 'Kako se vodi',
        notes: [
          LessonNote.ok('Španovanje — plovak na tačnoj dubini, laka stalna '
              'napetost. To je tehnika za travu.'),
          LessonNote('Traži kamen sa dobrom algom pre nego mesto za pecanje. '
              'Nema trave — nema pecanja na travu.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'feeder-velika-reka',
    emoji: '🌊',
    title: 'Feeder na velikoj reci',
    subtitle: 'Dunav, Sava, Tisa — teško i daleko',
    tags: [Topic.feeder],
    level: Level.napredni,
    lead: 'Velika reka kažnjava opremu koja radi na kanalu. Struja odnosi '
        'hranilicu, domet je dvostruk, a zabačaj od 100 g upletenicom bez '
        'lidera puca u vazduhu. Ovo je šta se menja.',
    sections: [
      LessonSection(
        title: 'Oprema',
        notes: [
          LessonNote('Štap 3,6–3,9 m, test 80–120 g. Kraći ne baca dovoljno '
              'daleko ni dovoljno teško.'),
          LessonNote('Upletenica 0,10–0,12 mm kao glavni — nula rastezanja, pa na '
              '60 m i dalje vidiš trzaj i zabod je oštar.'),
          LessonNote('Šok lider 8–10 m monofila 0,28–0,30 mm je obavezan preko '
              '60 g. Vezuje se albright čvorom.'),
          LessonNote('Window hranilica ako ti fali domet — olovo ulivano u bazu '
              'nosi 60–80 m i drži teret do dna.'),
        ],
      ),
      LessonSection(
        title: 'Čitanje struje',
        notes: [
          LessonNote('Najlakša hranilica koja drži mesto. Vuče niz vodu — dodaj '
              '20 g, ne menjaj tip.'),
          LessonNote('Unutrašnja strana krivine je mirnija i muljevita — tu se '
              'skuplja hrana i tu stoji bela riba.'),
          LessonNote('Prelaz plićaka u dubinu i ivica brzaka: riba stoji u '
              'dubljem a hrani se na ivici. Zabačaj ide na ivicu, ne u sredinu.'),
        ],
      ),
      LessonSection(
        title: 'Primama u struji',
        notes: [
          LessonNote('Lepljivija smeša nego na stajaćoj — inače je struja raznese '
              'pre nego riba dođe.'),
          LessonNote('Open-end pakovana čvršće drži duže. Cage ovde nema smisla '
              '— ispraznila bi se u padu.'),
          LessonNote('Više punjenja na početku (6–8) jer struja stalno odnosi '
              'deo kupe.'),
        ],
      ),
    ],
  ),

  // ── UČENJE: dve teme koje su bile rupa (izvor: feeder.rs) ───────────────
  SchoolLesson(
    id: 'sondiranje',
    emoji: '🔍',
    title: 'Sondiranje i klipovanje',
    subtitle: 'Pročitaj dno pre prvog zabačaja',
    tags: [Topic.feeder],
    level: Level.srednji,
    lead: 'Pre prvog zabačaja sa hranilicom ide golo olovo. Njime se čita dno — '
        'dubina, tvrdoća, prelazi — i tek onda se bira mesto. Petnaest do '
        'dvadeset minuta ovde vredi više od tri sata slepog pecanja.',
    sections: [
      LessonSection(
        title: 'Sondiranje — kako se čita dno',
        notes: [
          LessonNote.ok('Ide golo olovo za sondiranje. Krut štap i upletenica '
              'prenose informaciju o dnu, monofil je rastezanjem ubija.'),
          LessonNote.ok('Dubina se meri brojanjem: olovo od 30 g pada oko '
              '1 m u sekundi. Broj sekunde do udara u dno.'),
          LessonNote.ok('Spusti vrh štapa na oko 45° i vuci polako sa napetom '
              'strunom — olovo pomeraj štapom, ne rolnom.'),
          LessonNote.ok('Šta osećaš: blago zapinjanje i puštanje = mulj ili '
              'pesak. Neprekidno „tiktakanje" = šljunak ili školjke. '
              'Tvrd otpor = zakačka, rastinje ili prelaz dubine.'),
          LessonNote.ok('Sondiraj celu zonu, i u širinu. Mikro-promene terena '
              'su baš ono gde riba stoji.'),
        ],
      ),
      LessonSection(
        title: 'Klipovanje — isti zabačaj svaki put',
        notes: [
          LessonNote.ok('Okrugle metalne klipse su bolje od trouglastih '
              'plastičnih — manje oštećuju najlon. Noviji modeli imaju oprugu '
              'unutra da ublaže trzaj pri zabačaju.'),
          LessonNote.ok('⚠ Klipsa je za pecanje sa štapom u ruci i sitniju '
              'ribu. Ne koristi je sa method hranilicom ni kad krupna riba '
              'može da odvuče 10+ m strune — puca.'),
          LessonNote.ok('Alternativa: vodootporni marker na prvih 30–50 cm '
              'strune, ili obojena nit vezana iznad špule kao oznaka daljine.'),
          LessonNote.ok('Ako pukne, daljina se vraća ovako: dva pikera na '
              'obali 3 m jedan od drugog, pa namotavaj strunu oko njih u '
              'krugove od hranilice do mesta klipse — dobiješ tačnu dužinu.'),
        ],
      ),
      LessonSection(
        title: 'Orijentir',
        notes: [
          LessonNote.ok('Uzmi nepokretan orijentir na drugoj obali — zgradu, '
              'drvo. Nikad parkirano vozilo ili nešto što odlazi.'),
          LessonNote.ok('Na stajaćoj vodi je ovo kritično: nema struje da '
              'razvuče miris, pa kupa postoji samo ako svaki zabačaj padne '
              'na isto mesto.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'lokacija',
    emoji: '📍',
    title: 'Izbor mesta i postavljanje',
    subtitle: 'Obala, stolica, ugao štapa',
    tags: [Topic.feeder, Topic.opste],
    level: Level.pocetnik,
    lead: 'Mesto se ne bira po tome gde je lepo nego gde možeš da baciš, '
        'sediš ravno i vidiš trzaj. Loše postavljen pecaroš promaši trzaje '
        'koje bi na dobrom mestu videо.',
    sections: [
      LessonSection(
        title: 'Obala',
        notes: [
          LessonNote.ok('Izbegavaj presrutu obalu — ne možeš da baciš preko '
              'glave.'),
          LessonNote.ok('Krupno kamenje znači nestabilna stolica i rizik za '
              'opremu.'),
          LessonNote.ok('Mek mulj traži podloge pod nogare.'),
          LessonNote.ok('Očisti rastinje i grane IZA sebe — zamah ide unazad.'),
          LessonNote.ok('Ako mesto traži sate čišćenja, oteraćeš ribu pre nego '
              'što počneš.'),
        ],
      ),
      LessonSection(
        title: 'Ugao štapa',
        notes: [
          LessonNote.ok('Stajaća voda: vrh štapa nisko, blizu vode — manje '
              'površine za vetar.'),
          LessonNote.ok('Reka: vrh štapa visoko i nagore — struja manje '
              'pritiska strunu, pa možeš lakšu hranilicu.'),
          LessonNote.ok('Ugao između vrha štapa i strune najmanje 45°, '
              'najbolje 60–90° — tako se trzaj vidi.'),
        ],
      ),
      LessonSection(
        title: 'Postavljanje',
        notes: [
          LessonNote.ok('Stolica pod 90° na vodu, stopala ravno na zemlji, '
              'kolena pod 90°, naslon pod 90° na sedište.'),
          LessonNote.ok('Kutija sa mamcem i kofa sa primamom na dohvat ruke. '
              'Meredov takođe — a ako je mrežа pamučna, drži je u vodi.'),
          LessonNote.ok('Obeleži nivo vode pikerom dok obilaziš — vidiš da li '
              'raste ili pada tokom dana.'),
          LessonNote.ok('Kišobran postavi tako da ne ulazi u zamah, i računaj '
              'da se sunce pomera.'),
          LessonNote('Imaj rezervno mesto na umu. Krupna riba ili grabljivica '
              'ume da rastera jato sa kupe.'),
        ],
      ),
    ],
  ),


  // ── Popunjene rupe iz docs/research/2026-09-08-feeder-rs-research.md ────
  SchoolLesson(
    id: 'sloj',
    emoji: '📐',
    title: 'Traženje sloja',
    subtitle: 'Riba ne mora biti na dnu',
    tags: [Topic.feeder],
    level: Level.napredni,
    lead: 'Najskuplja pretpostavka u feeder ribolovu je da riba jede na dnu. '
        'U jednom takmičarskom primeru voda je bila 180 cm duboka, a riba je '
        'jela 60 cm od površine — mamac na dnu prvih pet minuta nije ni '
        'pipnut. Sloj se ne pogađa, nego se traži dužinom predveza i meri '
        'štopericom.',
    sections: [
      LessonSection(
        title: 'Uporedi dužine',
        comparator: ComparatorSet(
          specLabels: ['Gde stoji mamac', 'Kako pada', 'Kada radi', 'Šta gledaš'],
          items: [
            ComparatorItem(
              id: 'kratak',
              name: 'Predvez 50 cm',
              tagline: 'Mamac uz dno, kraj hranilice. Polazna dužina.',
              svg: kLayerKratak,
              specs: [
                'Uz dno, do same hranilice',
                'Brzo — kratak put do dna',
                'Riba jede na dnu; hladna voda',
                'Ako nema trzaja u 5–10 min, produži',
              ],
            ),
            ComparatorItem(
              id: 'srednji',
              name: 'Predvez 75 cm',
              tagline: 'Mamac malo nad dnom, u oblaku čestica.',
              svg: kLayerSrednji,
              specs: [
                'Nekoliko desetina cm nad dnom',
                'Sporije, duže lebdi u oblaku',
                'Riba se odvojila od dna',
                'Meri vreme do trzaja i uporedi sa 50 cm',
              ],
            ),
            ComparatorItem(
              id: 'dug',
              name: 'Predvez 125 cm',
              tagline: 'Mamac visoko u vodenom stubu, među česticama.',
              svg: kLayerDug,
              specs: [
                'Visoko — u primeru 60 cm od površine u 180 cm vode',
                'Najsporije, najduže u oblaku',
                'Riba se hrani u sloju, ne na dnu',
                'Trzaj u roku od 2 min = našao si sloj',
              ],
            ),
          ],
        ),
        notes: [
          LessonNote.ok('Riba se hrani u sloju. U primeru: dubina ~180 cm, riba '
              'na ~60 cm od površine.'),
          LessonNote.ok('Sloj se traži od dna ka površini: 50 cm → 75 cm → '
              '125 cm predveza.'),
          LessonNote.ok('Na 50 cm je trzaj dolazio svake 2 min, a na 125 cm u '
              'roku od 2 min — dužina se bira po izmerenom vremenu, ne po osećaju.'),
          LessonNote.ok('Koristi štopericu. Bez merenja ne znaš koja dužina '
              'zaista radi, samo ti se čini.'),
          LessonNote.ok('Čestice koje propadaju drže ribu u srednjim slojevima — '
              'zato se sloj i pravi hranjenjem, ne samo nalazi.'),
        ],
      ),
      LessonSection(
        title: 'Kako se radi u praksi',
        notes: [
          LessonNote('Počni od dna sa 50 cm i idi nagore. Menjaj jednu stvar '
              'u jednom trenutku — samo dužinu, ne i mamac.'),
          LessonNote('Nosi unaprijed vezane predveze u nekoliko dužina, pa se '
              'menja loop-to-loop u sekundi — vidi lekciju Čvorovi.'),
          LessonNote('Duži predvez traži i finiji najlon da mamac lebdi '
              'prirodno.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'zemlja',
    emoji: '🪨',
    title: 'Zemlja u prihrani',
    subtitle: 'Oblak, težina i kontrola otpuštanja',
    tags: [Topic.feeder, Topic.plovak],
    level: Level.srednji,
    lead: 'Zemlja nije popunjivač da bi prihrana bila jeftinija — mada je i '
        'to. Ona pravi oblak koji imitira uzmućeno dno, nosi aromu, kontroliše '
        'brzinu otpuštanja i boji smešu u boju dna. Na Dunavu, gde treba mnogo '
        'prihrane, bez nje se teško izlazi na kraj.',
    sections: [
      LessonSection(
        title: 'Dve vrste',
        notes: [
          LessonNote.ok('Teška zemlja (černozem, crnica) — iz krtičnjaka i '
              'šume, tamna, veoma lepljiva, pH ≤7 (blago kisela).'),
          LessonNote.ok('Laka zemlja (les) — iz nanosa uz vodu, svetlija, '
              'slabo lepljiva, pH >7 (bazna).'),
          LessonNote.ok('Odnos do 1:5 — 1 kg prihrane na 5 kg zemlje, ukupno '
              '6 kg smeše.'),
        ],
      ),
      LessonSection(
        title: 'Redosled — ovde se najviše greši',
        notes: [
          LessonNote.ok('Prosej zemlju pre upotrebe.'),
          LessonNote.ok('Zemlja ide POSLEDNJA, u već izmešanu i navlaženu '
              'prihranu. Nikad ne mešaj suvu prihranu i suvu zemlju pa onda '
              'kvasi.'),
          LessonNote.ok('Prvo kvašenje pa 10–15 min odmaranja; drugo kvašenje '
              'neka bude malo vlažnije od idealnog, jer zemlja upija.'),
          LessonNote.ok('Posle zemlje odmori smešu još malo, pa koriguj samo '
              'prskalicom.'),
        ],
      ),
      LessonSection(
        title: 'Koju kada',
        notes: [
          LessonNote.ok('Teška i vlažna — sporije otpuštanje u jakoj struji, '
              'drži čestice uz udicu.'),
          LessonNote.ok('Laka — brže se raznosi, i spašava presipanu prihranu.'),
          LessonNote.ok('Tamna — maskira jarku boju smeše kod plašljive ribe.'),
          LessonNote.ok('Čista zemlja bez prihrane je takmičarski potez: mnogo '
              'pecaroša na malom prostoru i prehranjena riba.'),
          LessonNote.ok('⚠ Radi na svim vrstama osim šarana.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'hladna-sezona',
    emoji: '❄️',
    title: 'Kraj zime i početak proleća',
    subtitle: 'Malo hrane, mesni mamac, sporo',
    tags: [Topic.feeder],
    level: Level.srednji,
    lead: 'U hladnoj vodi se sve okreće naglavačke: nema klasičnog početnog '
        'hranjenja, hranilica se prazni deset minuta, a cilj je da na udici '
        'ima više hrane nego u hranilici. Ko u martu hrani kao u julu, '
        'nahranio je vodu i nije ništa upecao.',
    sections: [
      LessonSection(
        title: 'Gde je riba',
        notes: [
          LessonNote.ok('Stoji dublje i u sporijoj struji — čuva energiju.'),
          LessonNote.ok('Traže se „riblji autoputevi" — zone kojima se riba '
              'kreće ka hrani kako se voda greje.'),
          LessonNote.ok('Reka: male dragice i spoljna strana krivine gde voda '
              'vrtloži. Stubovi mostova i vertikalne obale sa sporijom vodom.'),
          LessonNote.ok('Stajaća: uz potopljene prepreke i rastinje, dublji '
              'delovi dalje od obale.'),
          LessonNote.ok('⚠ Nema znakova posle ~1 h — menjaj mesto. Na reci '
              'nizvodno.'),
        ],
      ),
      LessonSection(
        title: 'Prihrana i mamac',
        notes: [
          LessonNote.ok('Tamna prihrana na bazi ribljeg brašna — crna, tamno '
              'bordo, braon, zelena.'),
          LessonNote.ok('Zemlju izbegavaj sasvim, osim ako uslovi ne nalažu '
              'drugačije.'),
          LessonNote.ok('Partikl minimalno: nekoliko mrtvih crva ili seckanih '
              'larvi po hranilici.'),
          LessonNote.ok('Početno hranjenje: samo 2–4 hranilice da položiš '
              'mamac, pa peca. Nema klasičnog početnog hranjenja.'),
          LessonNote.ok('Ideal je više partikla na udici nego u hranilici. Ne '
              'zasićuj mesto.'),
          LessonNote.ok('Mamac isključivo mesni: živi crvi, mrtvi crvi, larve, '
              'pinkiji. Jedan crv, ili crv + pinki, maksimum.'),
        ],
      ),
      LessonSection(
        title: 'Pribor i ritam',
        notes: [
          LessonNote.ok('Glavni najlon najviše 0,18 mm. Upletenica samo kad je '
              'vazduh iznad 0–4 °C.'),
          LessonNote.ok('Predvez: 0,14 mm je gornja granica, optimalno '
              '0,10–0,12 mm. Počni od 50 cm i koriguj tokom sesije.'),
          LessonNote.ok('Udica sitna, laka, skrivena u mamcu.'),
          LessonNote.ok('Hranilici treba ~10 min da se isprazni u hladnoj vodi.'),
          LessonNote.ok('Zabačaj svakih 5–15 min, po aktivnosti.'),
          LessonNote.ok('Štap Medium Heavy ili Medium na većim vodama; '
              'Light/Ultra Light na stajaćim i za sitnije vrste.'),
          LessonNote.ok('Dva štapa su korisna dok ne nađeš ribu.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'vezivanje-udice',
    emoji: '🪝',
    title: 'Vezivanje udice',
    subtitle: 'Pet načina — sa ušicom i bez nje',
    tags: [Topic.opste, Topic.feeder],
    level: Level.pocetnik,
    lead: 'Udica je jedina tačka koja drži ribu, a čvor na njoj je najslabija '
        'tačka celog sistema. Pet načina pokriva sve: dva univerzalna, jedan '
        'za method i pelet, jedan za pravac izvlačenja, i jedan za udice bez '
        'ušice. Jedno pravilo važi za svaki — nakvasi pre zatezanja, jer suvo '
        'zatezanje pregoreva najlon i odnese pola jačine.',
    sections: [
      LessonSection(
        title: '1 · Palomar — ušica',
        sequence: StepSequence(
          purpose: 'Najjači i najlakši čvor za udicu, varalicu i vrtilo. '
              'Prvi koji treba naučiti.',
          strength: '90–95%',
          videoUrl: 'https://www.youtube.com/results?search_query=palomar+knot',
          videoLabel: 'Vidi video — Palomar',
          steps: [
            ProcedureStep.ok('Presavij oko 15 cm najlona na duplo i provuci '
                'petlju kroz ušicu udice.',
                imageAsset: 'assets/knots/palomar-1.png'),
            ProcedureStep.ok('Napravi običan uzao duplim krajem. Udica visi '
                'slobodno, ne zatežeš još.',
                imageAsset: 'assets/knots/palomar-2.png'),
            ProcedureStep.ok('Prebaci petlju preko cele udice.',
                imageAsset: 'assets/knots/palomar-3.png'),
            ProcedureStep.ok('Nakvasi i zategni oba kraja u isto vreme, pa '
                'odreži višak.',
                imageAsset: 'assets/knots/palomar-4.png'),
          ],
          mistakes: [
            LessonNote('Zatezanje samo jednog kraja — čvor se ne skupi kako '
                'treba i puca ispod nosivosti.'),
            LessonNote('Premala ušica za duplu strunu. Onda idi na uni.'),
          ],
        ),
        notes: [
          LessonNote.ok('Drži 90–95% jačine najlona i radi i na monofilu i na '
              'upletenici — otud je prvi izbor.'),
          LessonNote('Petlja preko udice je prostorna, pa je ovaj čvor jedini '
              'sa ilustracijom po koraku umesto shematskog dijagrama.'),
        ],
      ),
      LessonSection(
        title: '2 · Uni / grinner — ušica',
        sequence: StepSequence(
          purpose: 'Univerzalni čvor. Radi na monofilu, fluorokarbonu i '
              'upletenici, i prolazi kroz male ušice.',
          strength: 'do 90%',
          videoUrl: 'https://www.youtube.com/results?search_query=uni+knot+fishing',
          videoLabel: 'Vidi video — Uni',
          steps: [
            ProcedureStep.ok('Provuci kraj kroz ušicu i ostavi 10–15 cm.',
                svg: kTieUni),
            ProcedureStep.ok('Vrati kraj ka ušici i napravi petlju uz stajaću '
                'strunu.', svg: kTieUni),
            ProcedureStep.ok('Radeći UNUTAR petlje, obmotaj kraj oko oba '
                'najlona pet puta.', svg: kTieUni),
            ProcedureStep.ok('Nakvasi, zategni da se petlja skupi, pa je '
                'privuci do ušice.', svg: kTieUni),
          ],
          mistakes: [
            LessonNote('Manje od pet namotaja — čvor klizi, posebno na '
                'upletenici.'),
            LessonNote('Privlačenje do ušice pre zatezanja namotaja. Prvo se '
                'skupi čvor, pa se pomera.'),
          ],
        ),
        notes: [
          LessonNote.ok('Uni-na-uni spaja dva najlona približno istog preseka '
              'i jači je od surgeon i blood čvora.'),
        ],
      ),
      LessonSection(
        title: '3 · Knotless (no-knot) — ušica',
        sequence: StepSequence(
          purpose: 'Za hair rig: mamac stoji na kratkoj niti PORED udice, ne '
              'na njoj. Bez ovoga nema method-a sa peletom i bojlijem.',
          videoUrl: 'https://www.youtube.com/results?search_query=knotless+knot+hair+rig',
          videoLabel: 'Vidi video — Knotless',
          steps: [
            ProcedureStep('Provuci predvez kroz ušicu odozgo i ostavi dužinu '
                'niti koliko ti treba za mamac.', svg: kTieKnotless),
            ProcedureStep('Namotaj predvez oko struka udice 7–8 puta nadole, '
                'gusto i bez preklapanja.', svg: kTieKnotless),
            ProcedureStep('Provuci kraj NATRAG kroz ušicu, ali sa spoljne '
                'strane — to je poenta čvora.', svg: kTieKnotless),
            ProcedureStep('Nakvasi i zategni. Nit sa mamcem mora da izlazi '
                'ispod ušice, ne sa strane.', svg: kTieKnotless),
          ],
          mistakes: [
            LessonNote('Kraj provučen u istom smeru kao na početku — čvor se '
                'ne zaključa i namotaji popuste.'),
            LessonNote('Predugačka nit. Mamac 1–2 cm od udice; kraće za '
                'wafter, duže za bojli.'),
          ],
        ),
        notes: [
          LessonNote('Mamac se na nit stavlja iglom, kroz izbušenu rupicu — '
              'vidi lekciju Montaže.'),
        ],
      ),
      LessonSection(
        title: '4 · Šnelovanje (snell) — ušica',
        sequence: StepSequence(
          purpose: 'Vuča ide u osi struka, ne pod uglom — udica se okreće i '
              'hvata za usnu. Za krupnije mamce i krupniju ribu.',
          videoUrl: 'https://www.youtube.com/results?search_query=snell+knot',
          videoLabel: 'Vidi video — Snell',
          steps: [
            ProcedureStep('Provuci strunu kroz ušicu i pusti je da legne uz '
                'struk udice.', svg: kTieSnell),
            ProcedureStep('Namotaj radni deo preko strune i struka, 6–7 puta '
                'ka kljunu.', svg: kTieSnell),
            ProcedureStep('Provuci kraj ispod namotaja i izvuci ga na dole, u '
                'osi struka.', svg: kTieSnell),
            ProcedureStep('Nakvasi i zategni tako da namotaji legnu jedan uz '
                'drugi.', svg: kTieSnell),
          ],
          mistakes: [
            LessonNote('Namotaji preko bodlje — čvor sedi na krivini i puca '
                'pod teretom.'),
            LessonNote('Retki namotaji koji se preklapaju. Moraju biti gusti '
                'i u jednom redu.'),
          ],
        ),
      ),
      LessonSection(
        title: '5 · Lopatica — udica BEZ ušice',
        sequence: StepSequence(
          purpose: 'Udice bez ušice imaju spljoštenu lopaticu na vrhu struka. '
              'Nema kroz šta da se provuče — namotaji su jedino što drži.',
          videoUrl: 'https://www.youtube.com/results?search_query=spade+end+hook+knot',
          videoLabel: 'Vidi video — Spade end',
          steps: [
            ProcedureStep('Položi strunu uz struk, tako da kraj gleda ka '
                'lopatici.', svg: kTieSpade),
            ProcedureStep('Namotaj radni deo oko struka i strune, 7–8 gustih '
                'namotaja.', svg: kTieSpade),
            ProcedureStep('Provuci kraj ispod svih namotaja i zategni ih ka '
                'lopatici.', svg: kTieSpade),
            ProcedureStep('Nakvasi, zategni i proveri da struna izlazi sa '
                'UNUTRAŠNJE strane struka — inače udica stoji ukoso.',
                svg: kTieSpade),
          ],
          mistakes: [
            LessonNote('Struna izlazi sa spoljne strane — udica se pri zabodu '
                'okreće u stranu i promašuje.'),
            LessonNote('Namotaji koji pređu preko lopatice mogu da se '
                'presecu o njenu ivicu.'),
          ],
        ),
        notes: [
          LessonNote('Lopatica se koristi u takmičarskom i finom ribolovu — '
              'čvor je manji i profil je tanji od ušice.'),
        ],
      ),
      LessonSection(
        title: 'Koju udicu — oblik i žica',
        notes: [
          LessonNote.ok('„Kristalke": dug struk, mali otvor. Za sitnu belu '
              'ribu i sitan mamac.'),
          LessonNote.ok('„Papagajke": kratak struk, širok otvor, zakrivljen '
              'vrh. Za krupnije ribe i krupnije mamce.'),
          LessonNote.ok('Tanka žica je lakša, oštrija i elastičnija, ali se '
              'lomi i tupi. Debela je teža i izdržljivija, i ne tupi se.'),
          LessonNote.ok('Po ribi: sitna bela riba → najsitnije, tanke, lake. '
              'Krupna bela riba (velika deverika, karaš, šaran, jaz) i method '
              '→ veće i jače.'),
          LessonNote.ok('Po mamcu: larve, pinkiji i sitni crvi → tanke i '
              'sitne; kukuruz, bojli i krupni mamci → veće.'),
          LessonNote.ok('Nosi više unaprijed vezanih udica u različitim '
              'veličinama, oblicima i dužinama predveza — dan se ne bira.'),
        ],
      ),
      LessonSection(
        title: 'Koju udicu — boja',
        notes: [
          LessonNote.ok('Tamna (crna, siva) — univerzalna, za većinu uslova.'),
          LessonNote.ok('Crvena — uz crvene mamce, pre svega crve.'),
          LessonNote.ok('Zelena — radi i u bistroj i u mutnoj vodi.'),
          LessonNote.ok('⚠ Srebrna i metalik — izbegavaj u bistroj vodi i po '
              'suncu; koristi u dubokoj i mračnoj.'),
          LessonNote.ok('Zlatna — odlična za kukuruz i bojli.'),
        ],
      ),
      LessonSection(
        title: 'Koji čvor kada',
        notes: [
          LessonNote('Sve osim method-a: Palomar. Mala ušica ili fina struna: '
              'uni. Pelet i bojli: knotless. Krupan mamac i krupna riba: '
              'šnelovanje. Takmičarski fino: lopatica.'),
          LessonNote.ok('Nakvasi svaki čvor pre zatezanja. Suvo zatezanje '
              'pregoreva najlon i gubi polovinu jačine.'),
          LessonNote('Vezuj udice kod kuće, na držaču, i nosi ih vezane u '
              'nekoliko veličina i dužina predveza — na obali se to ne radi '
              'mokrim rukama.'),
        ],
      ),
    ],
  ),

  // ── Iz druge žetve feeder.rs (oprema, method, živi mamci) ───────────────
  SchoolLesson(
    id: 'stapovi-masinice',
    emoji: '🎣',
    title: 'Štapovi i mašinice',
    subtitle: 'Klase, vrhovi, veličine, kočnica',
    tags: [Topic.feeder],
    level: Level.pocetnik,
    lead: 'Feeder štap se ne bira po dužini nego po klasi — koliko grama sme '
        'da baci. Klasa se bira po vodi, a mašinica po klasi štapa. Ako to '
        'troje ne ide u paru, ništa drugo ne pomaže.',
    sections: [
      LessonSection(
        title: 'Klase štapa',
        notes: [
          LessonNote.ok('Light (L): 10–30 g, 10–40 g ili 20–50 g.'),
          LessonNote.ok('Medium Heavy (MH): od 50–60 g do 80–90–100 g.'),
          LessonNote.ok('Heavy (H): 100 g i više.'),
          LessonNote.ok('Picker: 2,5–3,3 m, Light klasa, najviše 30–40 g, '
              'tanak blank i velika osetljivost — za sitnu ribu.'),
        ],
      ),
      LessonSection(
        title: 'Dužine',
        notes: [
          LessonNote.ok('3,3 m (11 ft) · 3,6 m (12 ft) — najčešća · '
              '3,9 m (13 ft). Preko 4,2 m samo za ekstremnu daljinu.'),
          LessonNote.ok('Duži štap na reci smanjuje pritisak struje na strunu, '
              'pa možeš lakšu hranilicu.'),
          LessonNote.ok('Blank je karbonski sa unakrsnim ojačanjem (kevlar, '
              'teflon, karbon), obično tri dela sa zamenljivim vrhom.'),
        ],
      ),
      LessonSection(
        title: 'Vrhovi (tipovi)',
        notes: [
          LessonNote.ok('Obično tri zamenljiva vrha po štapu. Na Light '
              'štapovima najčešće 0,5 · 0,75 · 1,0 oz. (1 oz = 28,35 g)'),
          LessonNote.ok('Karbonski vrh je oštriji — za jaku struju, veće '
              'hranilice i jaču ribu.'),
          LessonNote.ok('Fiberglas vrh je mekši i sporiji — za lakše hranilice '
              'i finiji ribolov.'),
        ],
      ),
      LessonSection(
        title: 'Prvi štap — šta uzeti',
        notes: [
          LessonNote.ok('Standard je 360 cm. Za reku ili veći domet 390–420 cm.'),
          LessonNote.ok('Stajaća voda: Light ili Medium (20–50 g), srednja do '
              'brza akcija.'),
          LessonNote.ok('Reka: MH, H ili XH, sporija akcija sa žilavom kičmom. '
              'Duboka i jaka struja traži 80–120 g.'),
          LessonNote.ok('Deverika i karaš imaju meka usta — pretežak štap ih '
              'gubi. Za njih Light/Medium.'),
          LessonNote.ok('⚠ Početnik ni u kom slučaju ne kupuje štap visokog '
              'cenovnog ranga. Srednja klasa je dovoljna da se nauči zabačaj; '
              'ali izbegavaj i najjeftinije, jer kratki zabačaji frustriraju.'),
          LessonNote.ok('Jedan Medium štap od 360 cm pokriva stajaću vodu, '
              'mešovite vrste, 30–50 m i hranilice 20–50 g.'),
        ],
      ),
      LessonSection(
        title: 'Mašinica',
        notes: [
          LessonNote.ok('Veličina po klasi štapa: Picker/UL/Light → 2500–3500; '
              'MH (najuniverzalnije) → 3500–5000; Heavy → 5000+.'),
          LessonNote.ok('Prenos 4:1 do 4,5:1 — niži nego na varaličarskim. '
              'Manja brzina, veća snaga; to treba za 100–200+ zabačaja po '
              'sesiji sa teškom montažom.'),
          LessonNote.ok('Špula „široka i plitka" — više najlona po obrtaju, pa '
              'je izvlačenje brže i pri nižem prenosu. Oba špula metalna, ne '
              'grafitna.'),
          LessonNote.ok('Prednja kočnica u 90% slučajeva: najprostija, '
              'najpouzdanija i najlakša za održavanje. Zadnja ima smisla uz '
              'ultralaganu opremu, baitrunner za šarana kad štap stoji.'),
          LessonNote.ok('⚠ Broj ležajeva je mit — često je 3+1 bolje od 12+1. '
              'Bitni su kvalitet i raspored, ne broj.'),
          LessonNote.ok('Klipsa: okrugla i metalna, sa oprugom. Trouglaste i '
              'plastične imaju oštre ivice i režu najlon pri klipovanju.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'zivi-mamci',
    emoji: '🪱',
    title: 'Živi mamci',
    subtitle: 'Larve, pinkiji, kasteri, gliste, trzalica',
    tags: [Topic.feeder, Topic.plovak],
    level: Level.srednji,
    lead: 'Živi mamac radi kad riba traži protein — posle zime, posle mresta i '
        'pred zimu. Ali radi samo ako je živ: pola posla je čuvanje, a druga '
        'polovina je kako ga nabodeš da se ne ubije pri prvom zabačaju.',
    sections: [
      LessonSection(
        title: 'Bele larve (crvi)',
        notes: [
          LessonNote.ok('Veličina 5–12 mm, ne veće.'),
          LessonNote.ok('Nabada se za surlicu — uži deo, gde je glava — da se '
              'larva najmanje povredi. Kad ih ide više, naizmenično glava-rep.'),
          LessonNote.ok('Čuvanje: frižider do 10 °C, perforirana posuda, '
              'nedeljno prosejavanje i izbacivanje mrtvih, uz dodatak '
              'kukuruznog griza ili mekinja. Tako traju do mesec dana.'),
          LessonNote.ok('Najbolje rade kad riba traži protein: posle zime, '
              'posle mresta i pred zimovanje.'),
          LessonNote.ok('Bojene larve: žuta, narandžasta, roze, crvena. Iznutra '
              'bojene traju duže od spolja bojenih.'),
        ],
      ),
      LessonSection(
        title: 'Pinkiji',
        notes: [
          LessonNote.ok('Larve zelene mesarke, izrazito roze; najviše 5 mm — '
              'manji od belih larvi.'),
          LessonNote.ok('U frižideru traju nekoliko meseci.'),
          LessonNote.ok('Prednost: ne uvlače se u mek mulj kao bele larve.'),
          LessonNote.ok('Rade u proleće i kasnu jesen, a za sitnu ribu cele '
              'godine. Nabadaju se sami ili u kombinaciji sa belim larvama.'),
        ],
      ),
      LessonSection(
        title: 'Kasteri',
        notes: [
          LessonNote.ok('Stadijum lutke larve mesarke, od svetložute do '
              'tamnobraon.'),
          LessonNote.ok('Priprema: prekrij žive larve kukuruznim grizom, drži '
              'na sobnoj temperaturi i prosejavaj svaki dan, najviše 5 dana.'),
          LessonNote.ok('Za prihranu ih drži mokre posle prosejavanja (da '
              'tonu); za udicu suve u frižideru.'),
          LessonNote.ok('U pojedinim fazama zrenja plutaju — dobro za '
              'prezentaciju u srednjem sloju.'),
          LessonNote.ok('Ciljaju krupnije primerke, pre svega deveriku.'),
        ],
      ),
      LessonSection(
        title: 'Gliste',
        notes: [
          LessonNote.ok('Najbolje kalifornijske (~10 cm) i đubretarke (5–8 cm).'),
          LessonNote.ok('Nabadanje: jedan dug ubod kroz gornji deo tela tako '
              'da glista legne uz struk, ili više uboda kroz pojas '
              '(clitellum).'),
          LessonNote.ok('Čuvanje u velikim posudama, uz praćenje vlage — ni '
              'presuho ni premokro — i pravilan odnos zemlje i glista.'),
          LessonNote.ok('Kalifornijske se gaje u raspadnutom lišću i biljnom '
              'otpadu; do polne zrelosti im treba 6–18 meseci.'),
        ],
      ),
      LessonSection(
        title: 'Trzalica (Chironomus plumosus)',
        notes: [
          LessonNote.ok('Dve kategorije: krupna do 30 mm i 3 mm debljine — za '
              'udicu; sitna do 15 mm i 1 mm — kao dodatak prihrani.'),
          LessonNote.ok('Nabada se 2–3 komada na udicu, u jednoj tački. Crvena '
              'boja štapa udice je poželjna.'),
          LessonNote.ok('Visok sadržaj mravlje kiseline pomaže varenje i '
              'povećava apetit ribe — otud njena efikasnost.'),
          LessonNote.ok('Čuvanje: vlažne novine, frižider oko 4 °C, najviše '
              'nedelju. Na vodi u posudi sa vodom i sunđerom, u senci.'),
          LessonNote.ok('⚠ Retko preživi drugi zabačaj — računaj na jedan '
              'zabačaj po nabadanju.'),
          LessonNote.ok('Teško se nabavlja i skupa je. Nalazi se u plitkim, '
              'toplim i muljevitim vodama — pojila, farme živine.'),
        ],
      ),
    ],
  ),

  SchoolLesson(
    id: 'method-prihrana',
    emoji: '🧪',
    title: 'Method prihrana i mamci',
    subtitle: 'Lepljivost, mikropelet, arome po sezoni',
    tags: [Topic.feeder],
    level: Level.napredni,
    lead: 'Method smeša nije feeder smeša sa više vode. Grublja je i znatno '
        'lepljivija, jer mora da se oblepi oko hranilice i preživi zabačaj — '
        'a onda da se raspadne na dnu. Aroma se menja po temperaturi vode, i '
        'to po jasnom redosledu.',
    sections: [
      LessonSection(
        title: 'Smeša',
        notes: [
          LessonNote.ok('Dva tipa: praškaste smeše i mikropelet.'),
          LessonNote.ok('Grublja granulacija i znatno lepljivija konzistencija '
              'od klasične feeder smeše.'),
          LessonNote.ok('Method traži VIŠE vode od standardne feeder prihrane, '
              'a količina se razlikuje od brenda do brenda. Kvasi u više faza, '
              'u sitnim dozama.'),
          LessonNote.ok('Najbolje: prvo natapanje veče pre izlaska, finalno '
              'doterivanje na vodi.'),
          LessonNote.ok('⚠ U praškaste smeše ne stavljaj krupniji partikl — '
              'zaglavljuje hranilicu. Sitno seme (konoplja, laneno, niger) u '
              'maloj količini je u redu. Mikropelet smeše primaju partikl bez '
              'rizika.'),
          LessonNote.ok('Boje: crvena, braon i crna kod nas; zelena je '
              'popularna u Engleskoj. Boja obično prati aromu.'),
        ],
      ),
      LessonSection(
        title: 'Mikropelet',
        notes: [
          LessonNote.ok('Prvo natapanje samo vodom, bez arome. Drugo '
              'natapanje aromatizovanom vodom, odvojeno.'),
          LessonNote.ok('Voda mora ravnomerno da prodre kroz celu strukturu '
              'peleta.'),
          LessonNote.ok('Pelet pumpa prevodi suv, plutajući pelet u zasićen i '
              'tonući u nekoliko poteza.'),
        ],
      ),
      LessonSection(
        title: 'Aroma po temperaturi — redosled',
        notes: [
          LessonNote.ok('Hladno: riblje brašno — fishmeal, halibut, lignja '
              '(squid), oktopod.'),
          LessonNote.ok('Voda se greje: začinske — vanila, karamela, čokolada, '
              'med, sir, anis, beli luk.'),
          LessonNote.ok('Najtopliji meseci: voćne — jagoda, ananas, banana, '
              'malina, tropske mešavine.'),
          LessonNote.ok('Voda se hladi: isti redosled unazad, natrag ka '
              'ribljem brašnu.'),
        ],
      ),
      LessonSection(
        title: 'Hookbait',
        notes: [
          LessonNote.ok('Prirodni: larve, kukuruz (šećerac), žive gliste. '
              'Umetni: pelet, bojli, wafteri, pop-up.'),
          LessonNote.ok('Udica ne sme biti značajno veća ni značajno manja od '
              'mamca. Ako udica premašuje mamac, stavi više mamaca na hair rig.'),
          LessonNote.ok('⚠ Premala udica daje promašene trzaje i plitak zabod.'),
          LessonNote.ok('Plutajući mamac kad riba stoji u srednjem sloju ili '
              'pri površini; tonući je standard za dno.'),
          LessonNote.ok('Wafteri se blago pomeraju po dnu, sa minimalnim '
              'uzmućivanjem — idealno za ribu pod pritiskom.'),
          LessonNote.ok('Praktična kutija: jedna sa plutajućim, jedna sa '
              'tonućim (uz obavezne larve i šećerac), jedna sa wafterima, plus '
              'tri tečne arome — mesna, začinska, voćna.'),
        ],
      ),
    ],
  ),
];

/// Lekcija po `id`-ju — Result ekran linkuje na pun postupak umesto da ga
/// prepisuje. Vraća `null` ako id ne postoji (npr. lekcija preimenovana).
SchoolLesson? lessonById(String id) {
  for (final l in schoolLessons) {
    if (l.id == id) return l;
  }
  return null;
}
