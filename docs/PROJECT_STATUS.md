# Upecaj! — stanje projekta i mapa puta

> Konsolidovan pregled: gde smo sada, šta je otvoreno, i predlozi za dalje.
> Datum: **2026-09-08**. Grana: `feature/traper-bait-recommender`.
> Ostali docs: `README.md` (tehnički), `docs/TRAPER_KOMBINACIJE.md` (recepti),
> `docs/METHOD_TAB.md` + `METHOD_REVIRI.md` (reviri — tab ukinut, mapa+Škola), `docs/archive/` (stari planovi/istraživanje).

---

## 1. Šta je urađeno

### Brend i dizajn (novo, 2026-07-24)
- App preimenovan **FishingWorthy → "Upecaj!"** (display; interni package `fishing_worthy` ostaje).
- **Pun redizajn** — vizuelni pravac "moderan outdoor dashboard", **light + dark**.
  - Tokeni: `lib/theme/app_colors.dart` (ThemeExtension, sve boje/senke light+dark), `AppRadius`.
  - Tema: `app_theme.dart` — **Baloo 2** (naslovi) + **Manrope** (UI) preko `google_fonts`.
  - `theme_controller.dart` — light default, toggle u headeru, pamti izbor.
  - Komponente: `lib/widgets/components.dart` (AppCard, AppChip, dugmad, HalfGauge,
    ConditionTile, FactorList, WarnBanner, Collapsible, MoonVis, ListRowCard, PageHeader…).
  - **Bottom-nav shell** (`app_shell.dart`): Početna · Mapa · Škola · Traper · Dnevnik.
  - Novi **logo** (Upecaj! lockup + cream ribica) + adaptive launcher ikona.
- Svi ekrani reskinovani na tokene: Home, Result, Map, Waters, Regulations, Diary (lista/unos/statistika).
- **15 ikonica riba** (dodat `tolstolobik`).

### Traper sistem primama (deal sa m-fishing ZATVOREN — realan proizvod)
- **Katalog: 44 proizvoda** (`traper_baits.dart`) — imena, linija, aroma/boja, opis, slika, m-fishing URL.
- **80 kombinacija = 20 voda × 4 sezone** (`traper_combos.dart`): 10 reka + 10 prirodnih jezera.
  - Svaki combo: baza + miks + odnos + pelet/aditivi + mamac + **priprema** + **hranjenje**.
  - Aktivnost ribe = modifikator (ne zaseban recept).
- **Hibridni recommender** (u `result_screen`): voda ima kuriran combo → prikaži; inače → algoritamski fallback (~775 nepokrivenih voda).
- **43/44 slike** proizvoda (skinute sa m-fishing og:image).
- **"Kupi na m-fishing.rs"** link na svakom proizvodu; **safe-case: 404/410 → `/shop/`**.

### Dnevnik: foto + deljenje (2026-08-20)
- **Više slika odjednom** iz galerije (`pickMultiImage(limit: free)`) — najviše 5 po izlasku;
  kamera ostaje jedna po jedna. Ako picker ignoriše `limit` (stariji Android), višak se odbaci + snackbar.
- **Pun ekran** (`lib/widgets/photo_viewer.dart`): swipe kroz slike, pinch i dupli tap zum, brojač.
- **Deljenje** (`lib/services/share_card.dart`, `share_plus`): kartica = fotografija +
  traka upečena u piksele (**samo voda + datum** — bez lokacije i ulova, pecaroši ne dele mesto)
  + `lockup-dark` logo, plus poluprozirni logo u uglu fotografije.
  Izlaz je **kvadrat 1080×1080** — IG feed pri više slika ionako nametne 1:1, pa mu odmah dajemo
  1:1 i ništa ne kropuje. Fotografija se **ne reže**: stoji cela (contain, zaobljene ivice),
  a pozadinu popunjava njena zamućena kopija (`ImageFilter.blur` 26 + crni sloj 30%) — radi isto
  za portret, pejzaž i panoramu, bez mrtvog praznog prostora.
  Deljenje više slika: „sve odjednom" (feed/karusel) ili „jednu po jednu" (FB story inače kolažira).
  Ulaz: ikonica u kartici Dnevnika (sve slike) ili share u pregledaču (tekuća slika).
  Tekst posta nosi i Play link (`kPlayUrl` — validan posle objave).

### Reorganizacija + offline (2026-09-08)
- **Method tab ukinut.** Komercijalni reviri su prešli u glavnu Mapu:
  četvrti čip **„Method"** (filteri skroluju), reviri stoje i na „Sve" uz reke
  i jezera, a „Method" odmiče kameru na celu Srbiju (44.1/20.8, zoom 6.6) i
  ostavlja samo revire. Sheet revira dobio **„Proveri stanje ovde"** (isti skor
  engine; reviri su stajaće vode → bez vodostaja). `method_screen.dart` obrisan.
- **Škola tab** (`school_screen.dart` + `data/school_lessons.dart`, model
  `models/school_lesson.dart`) — **31 lekcija** (459 pravila, 285 sa ✓ oznakom), tri taga:
  - **Tip** (`Kind`): **Učenje** (kako se radi) i **Blog** (naši originalni
    tekstovi). Bira se prekidačem na vrhu, ne filterom; **prekidač se ne
    prikazuje dok Blog nema sadržaj**, da tab ne vodi u prazno.
    **Blog je zasad prazan** — odluka 2026-09-08: tuđi tekstovi se ne koriste
    kao naš sadržaj, oni su istraživački ulaz. Matrica ≥2 po nivou važi za
    **Učenje**.
  - **Tema** (`Topic`, više po lekciji — čvorovi i uslovi služe svakoj tehnici;
    prva je primarna, po njoj se grupiše): Opšte · Feeder · Varalica · Plovak.
    Preslikava taksonomiju tabova tehnike na Result ekranu. **Method ide pod
    Feeder**, nije svoja tema (feeder varijanta; promovisati ako naraste >5 lekcija).
  - **Nivo** (`Level`): Početnik · Srednji · Napredni. Čip u boji na kraju reda
    (zelena/plava/zlatna) i sortiranje unutar teme po nivou — ali se **NE
    filtrira** (odluka 2026-09-08; filter je samo po temi).
  - **Pravilo: svaka tema ima ≥2 lekcije na svakom nivou** (4×3 matrica).
    Provera: `python3` parse `school_lessons.dart` — trenutno 6/2/2 · 9/8/4 ·
    4/4/3 · 4/5/3.
  - Svako pravilo nosi oznaku porekla: **✓ potvrđeno izvorom** (propis iz
    `fishing_seasons.dart`, `docs/research/`, `docs/METHOD_TAB.md`),
    **~ praksa/heuristika**. Pravila iz našeg skor engine-a NISU ✓ — to je naš
    model, ne izvor. Lekcija nosi ✓ u listi samo ako je svako pravilo u njoj ✓.
  - Lista je **direktorijum** (brzo traženje na vodi), lekcija je **članak**
    (lead pasus, sekcije, prored 1.55). Vreme čitanja se računa iz dužine teksta;
    „pročitano" se beleži kad korisnik stigne do DNA lekcije, ne na otvaranje
    (`services/school_progress_service.dart`).
- **Interaktivni comparator** (`ComparatorSet` + `_ComparatorView`) — biraš dva
  predmeta preko bottom sheet-a, vidiš ih jedan uz drugi i tabelu razlika sa
  **istaknutim redovima gde se razlikuju**.
  **Pravilo: svaka tema mora imati comparator sa dijagramima** — i svaka buduća
  (odluka 2026-09-08, posle potvrde da crtež radi na Hranilicama):
  - Opšte → **Najloni** (monofil · upletenica · fluorokarbon) u *Prva oprema*
  - Feeder → **Hranilice** (cage · open-end · window · method · pellet · hybrid)
    i **Montaže** (inline · free-running · paternoster)
  - Varalica → **Varalice** (shad · tvister · mino · dubokoronac · kašika · spinnerbait)
  - Plovak → **Plovci** (waggler · bolonjez · za otpuštanje) i
    **Olovljavanje** (bulk · stringer · struja)
- **24 SVG dijagrama** (`tools/school_diagrams.py` → generiše
  `lib/data/school_diagrams.dart`, regeneracija `python3 tools/school_diagrams.py --dart`).
  Sopstveni crteži — nema autorskih prava trećih lica, rade offline. Jednobojni
  preko `currentColor` + `fill-opacity`, pa isti crtež radi u light i dark
  (`SvgPicture.string` + `colorFilter`). Crta se **ono što predmet RADI**, ne
  obris — inače sve familije izgledaju isto (prvi pokušaj je dao Method/Pellet/
  Hybrid kao tri iste kupole). Otud tačkice (primama), strelice (izlaz), linija
  dna i površine. **Bez teksta u SVG-u** — prelama se preko crteža, a comparator
  ionako ispisuje ime i opis ispod. Preview za iteraciju:
  `python3 tools/school_diagrams.py out.html` + headless Chrome screenshot —
  crtati naslepo ne radi.
- **Overflow sweep** — `SectionLabel` je imao `Row` sa neograničenim `Text`-om
  (dugi naslovi sekcija prelivali red na 6 mesta, 3–209 px) i `AppButton` isto
  sa `block: true` i dugom labelom. Oba popravljena u `components.dart`, pa
  popravka pokriva ceo app. Nov **`AppSheet`** (`components.dart`) je zajednička
  školjka za bottom sheet — hvatalica, opcioni naslov, skrolabilno telo,
  prikovano podnožje, `viewInsets` + `padding.bottom`; `showModalBottomSheet`
  podrazumevano seče na pola ekrana pa je lista od 6 hranilica prelivala 45 px.
  Prebačeni na nju: comparator picker, `_AddCatchSheet` (15 vrsta + polja pod
  tastaturom), `_LakeSheet` (pravila revira su slobodan tekst).
  Verifikacija je bio privremeni widget sweep na 320 i 360 px koji renderuje
  listu, sve lekcije i comparator sheet i pada na overflow — 56 provera prošlo.
  Fajl NIJE ostavljen u repou (po dogovoru nema test infrastrukture); stoji u
  scratchpad-u ako se traži.
- **`flutter_map` 8.3.0 → 8.3.2** — pinch zum je pucao sa
  `LatLng is not finite, latitude: NaN`. Bug je u biblioteci, ne u našem kodu;
  8.3.2 changelog: „Prevent NaN fling direction when tracked pointer offsets
  are zero" + „Don't apply `initialCameraFit` on a zero-sized camera".
  Rešeno nadogradnjom, bez zakrpe u `map_screen.dart`.
- **feeder.rs požnjet kao istraživački izvor** →
  `docs/research/2026-09-08-feeder-rs-research.md`. Mapa preko
  `wp-sitemap.xml` (≈40 tehničkih stranica); požnjeto 10, ostatak popisan.
  Činjenice u našim rečima, sa URL-om po sekciji — pravila odavde smeju da nose
  ✓. **Tekst se ne prepisuje**: sajt nosi „©2026 Feeder.rs", zahtev za dozvolu
  poslat 2026-09-08 preko njihove kontakt forme, bez odgovora (sajt zadnji put
  ažuriran 2021) — neodgovaranje nije dozvola.
  Dokument nosi tabelu **G1–G15 rupa** koje je otkrio u našoj Školi.
  **Zatvoreno G1–G6, G10, G12, G14** (2026-09-08):
  - nove lekcije **`sloj`** (traženje sloja predvezom 50→75→125 cm sa
    štopericom + comparator sa 3 dijagrama), **`zemlja`** (černozem vs les,
    odnos do 1:5, zemlja ide POSLEDNJA u navlaženu smešu) i
    **`hladna-sezona`** (2–4 hranilice bez početnog hranjenja, ritam 5–15 min,
    predvez 0,10–0,12 mm od 50 cm, mesni mamac)
  - **maggot hranilica** kao 7. tip u `hranilice` comparator-u (nov SVG:
    poklopci na krajevima + crvi unutra) plus „tunelka" za jaku struju
  - **sprega dijametra i tereta** (0,16/15–20 g · 0,18/40 g · 0,22–0,25/60–80 g)
    u `oprema` i `feeder-abc`, plus održavanje najlona
  - ispravke: **sita 2–3 i 4–5 mm** u `primama-101` (bilo samo „prosej") i
    **domet pellet hranilice** (bilo „srednji", tačno je ~50 m i loša
    preciznost leta)

  **Sve rupe G1–G15 su zatvorene.** Drugi krug: boja i oblici udica
  (kristalke vs papagajke) → `vezivanje-udice`; gornji stoper i samozabod
  (0–3 cm plašljiva, 10+ cm aktivna) → `montaze`; pet načina montiranja
  method mamca → `montaze`; melasa u vodu, prezle, konoplja, voda sa mesta
  pecanja → `primama-101`.
- **Druga žetva feeder.rs** (još 10 stranica, §12 research doca) → tri nove
  lekcije i tri dopune:
  - **`stapovi-masinice`** (feeder, početnik) — klase L/MH/H sa gramažama,
    dužine 3,3/3,6/3,9 m, tri vrha 0,5/0,75/1,0 oz, karbon vs fiberglas,
    picker; mašinice po klasi štapa (2500–5000+), prenos 4:1–4,5:1, široka
    plitka metalna špula, prednja kočnica u 90%, „broj ležajeva je mit",
    okrugla metalna klipsa. Plus savet za prvi štap i šta NE kupovati.
  - **`zivi-mamci`** (feeder+plovak, srednji) — cela lekcija je bila rupa:
    bele larve 5–12 mm i nabadanje za surlicu, čuvanje do 10 °C mesec dana;
    pinkiji max 5 mm koji se ne uvlače u mulj; kasteri (5 dana prosejavanja,
    mokri za prihranu / suvi za udicu); gliste; trzalica do 30 mm, 2–3 na
    udicu, mravlja kiselina, retko preživi drugi zabačaj.
  - **`method-prihrana`** (feeder, napredni) — lepljivost, mikropelet i pelet
    pumpa, **aroma po temperaturi vode u jasnom redosledu** (riblje brašno →
    začinske → voćne → unazad), hookbait pravila i „tri kutije" postavka.
  - dopune: **sitan pribor** u `oprema` (vrtila, quick-change, stoperi,
    vadilica, hair rig alat), **method kontekst** u `method-skola` (šta ga
    razlikuje, gde radi — Tamiš/Tisa/spori Sava-Dunav — i gde ne, pribor),
    **deverika** u `po-vrstama` (riba dna, predvez do 1,5 m).
  Nepožnjeto ostaje 18 stranica, popisano u §13.
- **Korak-po-korak komponenta** (`StepSequence` + `ProcedureStep` u modelu,
  `_SequenceView` u ekranu) — jedan korak u kadru, listaš prstom ili
  strelicama, brojač `n/N` + tačke, „ponovi" na kraju, tekst koraka ispod
  kadra (fiksna visina kadra, pa se sadržaj ne pomera), opciono „Vidi video"
  i sekcija **najčešće greške** posle koraka. Prima `svg` ILI `imageAsset`,
  pa fotografije ulaze bez prepravke koda; dok slike nema, kadar prikazuje
  veliki broj koraka umesto lažnog crteža.
- **Dve lekcije o čvorovima**, razdvojene po zahtevu:
  - **`vezivanje-udice`** (opšte+feeder, početnik) — **5 načina**: Palomar ·
    Uni/grinner · Knotless (no-knot) · Šnelovanje (snell) · **Lopatica za
    udice BEZ ušice**. 20 koraka, svaki sa greškama i video linkom.
  - **`cvorovi`** (sve teme, početnik) — spajanje najlona: dupla petlja ·
    loop-to-loop · uni-na-uni · Albright. 16 koraka.
- **4 nova dijagrama vezivanja** (`kTieUni`, `kTieKnotless`, `kTieSnell`,
  `kTieSpade`) + `hook()` i `spade()` helperi. **Naučeno:** namotaj oko struka
  se crta kao dijagonala PREKO prave linije i čita se odmah — pa cela
  familija bandažiranja radi. Palomar se **ne crta shematski**: petlja preko
  udice je prostorna i dva pokušaja su dala nečitljivu topologiju (udica je
  bila tačna, odnos strune nije).
- **Palomar dobio ilustracije po koraku** — korisnik je doneo dve AI generisane
  slike; **jedna je bila pogrešna** (čvor iz clinch/uni familije, bez udice,
  ne Palomar) i odbačena je, druga je tačna sekvenca od 4 panela sa udicom.
  `tools/knot_images.py` je cepa na 4 PNG-a u `assets/knots/`: belo ide u
  **alfu preko luminancije** (anti-aliasing ostaje gladak), linije ostaju crne,
  pa se u app-u boje sa `Image.asset(color: c.ink, colorBlendMode: srcIn)` —
  **jedna slika radi u light i dark**, isto kao SVG. Rezovi su zategnuti da ne
  uvuku susedni panel; slike smanjene na max 820 px (ukupno 464 KB).
  Kadar sekvence podignut 132 → 168 px, jer su paneli široki.
- **Ispravka**: lekcija Montaže je tvrdila (i obeležila ✓) da se *free-running*
  hranilica otkači kad najlon pukne. Obrnuto je — **inline** je napravljena da
  spadne s najlona (najlon prolazi kroz centar), zato i postoji; free-running je
  bezbedna na drugi način (otpor je vrh štapa, nema samozaboda o težinu).
  Oba pravila prepisana.
- **Skor na day-chipovima** (Home) — 7 dana sa brojem u boji (`c.score`),
  najbolji dan se vidi bez ulaska u Result.
- **„Danas na vodi" briefing** (Home) — skor za danas + najbolja tehnika +
  jedan razlog + ciljne vrste; tap vodi na Result za danas.
- **Offline keš** (`services/api_cache.dart`, SharedPreferences):
  prognoza (Open-Meteo, ključ po zaokruženim koordinatama), protok (GloFAS) i
  RHMZ izvodi (temp + nivoi) idu na disk. Bez mreže se servira keš do 3 dana
  star (RHMZ 2), prošli dani se odbacuju iz keširanog prozora, a Home prikazuje
  **„Nema mreže — offline podaci"** banner sa vremenom upisa.
- **UTM na m-fishing linkovima** (`services/shop_link.dart`) — jedan helper za
  oba call-site-a (katalog + recept): `utm_source=upecaj`, `utm_medium=app`,
  `utm_campaign=traper`, `utm_content=<mesto klika>`; postojeći query se čuva,
  404/410 fallback na `/shop/` nosi `-fallback` oznaku.

### Osnovna aplikacija (od ranije, i dalje radi)
- Ocena 0–100 + razlozi, prognoza po intervalima (3h) sa filterom tehnike, zora/sumrak bonus.
- Offline baza ~795 voda + karta (FlutterMap), radijus filter.
- RHMZ: prava temp vode + prognoza vodostaja; GloFAS protok.
- Feeder/method savetnik. Lovostaj/mere/zaštićena područja. Dnevnik + statistika.
- Omiljene/nedavne, mesečeva faza + solunar, sezonske vrste.

**Build:** debug APK prolazi · `flutter analyze` clean · testira se na Samsung SM S911B.

---

## 2. Otvoreno / tehnički dug

| # | Stavka | Ozbiljnost | Napomena |
|---|---|---|---|
| D1 | **Traper recepti nisu zvanični** — moja heuristika + 1 FB recept | visoka | treba potvrda odnosa (Traper/m-fishing ili FB) |
| D2 | **3 delistovana m-fishing proizvoda** (od jun scrape-a): `gst-competition-river-1kg-traper` (u **9 combo-a**), `gst-competition-alborella-zuta` (0), `gold-champion-primama` (0) | srednja | buy-link sad pada na `/shop/`; River treba zameniti aktuelnim SKU |
| D3 | **1 slika fali** — `gold-champion-primama` (0 combo-a, delistovan) | niska | placeholder ikona |
| D4 | Kurirani combo pokriva **samo 20 od 795 voda** | srednja | ostalo ide na algoritamski fallback |
| D5 | **FB crawl mrtva ulica** — login wall; samo šačica indeksiranih permalink-ova | srednja | user lepi URL-ove/tekst ili m-fishing daje listu |
| D6 | **Result accent dark-mode** doteran; proveri sve kartice u dark | niska | većina migrirana ovog turnusa |
| D7 | Nema automatskih testova (po dogovoru) | — | verifikacija = analyze + ručni trace |
| D8 | Samo **Android** platforma (nema iOS/web foldera) | srednja | ako se cilja App Store, treba setup |

---

## 3. Šta ostaje da se radi (po prioritetu)

1. **Verifikuj/proširi Traper recepte (D1)** — najveći trust dobitak.
   - Ubaci prave odnose kad stignu (FB permalink-ovi / tekst / m-fishing lista); označi verifikovane vs heuristika.
2. **Reši River SKU (D2)** — naći aktuelni "GST Competition River" na m-fishing ili zameniti bazni proizvod u 9 combo-a.
3. **Pop-up / wafter hookbait grana** (SPRINT 2) — hookbait izlaz uz combo (bottom/wafter/pop-up); blokira verifikacija pravila (S0.1/S0.2).
4. **Dnevnik inteligencija** (SPRINT 3):
   - N6 "Slične sesije" — kad današnji uslovi ≈ prošloj uspešnoj → predlog iste taktike.
   - N5 Foto ulova (+ auto-tag uslova) — DB v3 migracija.
   - N7 Sezonski briefing po vodi.
5. **Proširi kurirane combo-e** preko 20 voda (D4) — dodati još reka/jezera po prioritetu prometa.
6. **Push notifikacije "feeder prozor"** (B4) — background provera nivo/pritisak/temp za omiljene vode.
7. **Mohseni air→water temp model** (B2) — traži kalibracione serije (odloženo).
8. **Slojevi karte** (C2) — bojenje temp/nivo.
9. **Komercijalna method jezera** (future) — poseban modul (vidi memory).
10. **Onboarding + Settings ekran** — tema/jezik/dozvole/notif na jednom mestu.

---

## 4. Predlozi (moja preporuka, van postojećih todo-a)

- **Monetizacija je već tu — iskoristi je.** m-fishing buy-linkovi su srce deala. Predlog:
  - dodati UTM/affiliate parametre na linkove (praćenje klikova/konverzija),
  - "sponzorisano" tag na Traper kartici (transparentno + brend),
  - mesečni izveštaj klikova za m-fishing (argument za produženje/plaćanje deala).
- **"Danas na vodi" home briefing** — kad korisnik otvori app, kratak dnevni sažetak za omiljenu vodu (skor + jedna rečenica taktike). Povećava dnevni retention.
- **Deljenje rezultata** (share kartica sa skorom + brendom) — organski rast, jeftino.
- **Widget / notifikacija "danas vredi"** — jutarnji push kad je skor visok za omiljenu vodu.
- **Kalibracija skora iz dnevnika** — kad se skupi dovoljno unosa, "tvoj lični obrazac" (koji uslovi tebi rade) — diferencijator koji Vodostaj.rs nema.
- **Konkurentska prednost = feeder inteligencija** (vidi memory competitive-positioning) — dupliraj na tome, ne na sirovom vodostaju.
- **iOS** ako se cilja šire tržište — ali prvo validirati na Android bazi.

---

## 5. Definicija "done" (za svaki task)
- `flutter analyze` → No issues found.
- Ručni trace kroz call chain (recommend/advisor → kartica).
- Pravila označena ✓ (verifikovano) / ~ (sourced, neverif) / ⚠ (sporno) komentarom gde je heuristika.
- Nema regresije postojećih ekrana (light **i** dark).
