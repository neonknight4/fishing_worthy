# FishingWorthy — Mogućnosti unapređenja (feeder + method na jezerima)

> Deliverable iz deep research sesije. Fokus: **feeder tehnika** (primarno, velike reke
> Dunav/Sava/Tisa/Morava) + **method/flat feeder na jezerima** (sekundarno).
> Bazirano na: match-pro izvorima (Preston, Guru, Dynamite, Angling Times, Match Fishing),
> naučnoj literaturi (Mohseni-Stefan air→water model), i analizi konkurencije.

## STATUS IMPLEMENTACIJE (ažurirano)

- ✅ **A1 Bait/feeder advisor** — `lib/logic/bait_advisor.dart` + `models/feeder_plan.dart`.
  Kartica "FEEDER PLAN / METHOD PLAN ZA DANAS" na result ekranu (mamac, primama, količina,
  hranilica+težina, podvez, udica, kadenca, kontekstualne napomene). Koristi pravu RHMZ temp.
- ✅ **A2 Feeder montaža** — uklopljeno u A1 (tip hranilice/težina/podvez/udica/kadenca po protoku+temp+bistrini).
- ✅ **A3 Pritisak bite-prozor** — već postojalo: `_PressureTrendCard` (kategorija + hPa/3h).
- ✅ **A4 Kadenca + tajming** — kadenca u feeder planu; solunar/izlazak-zalazak u postojećim karticama.
- ✅ **B1 Dnevnik statistika** — `lib/screens/diary_stats_screen.dart` (ulov po vrsti + najbolji
  uslovi: temp pojas / vodostaj / pritisak). Dnevnik sad pamti i pravu RHMZ temp (`waterTempReal`, DB v2).
- ✅ **B3 RHMZ prognoza nivoa** — `RhmzService.nearestLevelForecast` (scrape `prognoza_voda.php`,
  21 stanica/6 reka, 3–4 dana). Tile pod VODOSTAJ na result ekranu.
- ✅ **C1 Method-jezera (delom)** — isLake grana u `bait_advisor` (method/flat, plafon 1.8m, wafter/pelet,
  podvez 3"/4"); label "METHOD PLAN". Dovoljno za sekundarni fokus.
- ✅ **C3 Lovostaj upozorenje** — već postojalo: `_ClosedSeasonsCard` na result ekranu.

**Ostaje (zahteva odluku/infra, ne čista izmena):**
- ⏳ **B2 Mohseni air→water model** — treba kalibracione sparene serije (vazduh/voda kroz vreme).
  Trenutni fallback estimate = vazduh − sezonski offset. Prava RHMZ temp već pokriva ≤70km.
  Odluka: kako skupiti trening podatke (log RHMZ temp + Open-Meteo vazduh tokom vremena).
- ⏳ **B4 Notifikacije "feeder prozor"** — treba background scheduling (workmanager) + dozvole UX.
- ⏳ **C2 Slojevi karte** — bojenje markera po temp/nivou (marginalno).

---

## 0. Ključni strateški nalaz

**Konkurencija već postoji:** `Vodostaj.rs` i `FishingBalkan.com` drže "srpske podatke"
(RHMZ hidrometeo, protok m³/s, temp vode, 3-dnevna prognoza nivoa, lovostaj + minimalne mere,
dnevnik). Ako se takmičimo na sirovim podacima — pravimo lošiji klon.

**Gde je prazan prostor (niko ne radi):**
1. **Feeder/method-specifičan savetnik za montažu i mamac vođen živim uslovima.** Bait/rig
   advisori postoje (BassForecast, Fishbox) ali su **isključivo bass/lure** — niko ne savetuje
   tip hranilice, težinu, dužinu podveza, sastav primame, pelet vs kukuruz vs glista po
   temperaturi/bistrini/protoku. Znanje postoji samo na YouTube-u i u glavama match ribolovaca.
2. **Skoring vođen protokom reke** (ne solunar/plima prvo) — transparentan, podešen za srpske reke.
3. **Dnevnik koji auto-hvata uslove + analiza obrazaca na nivou tehnike** ("deverika ti ide
   najbolje na padajućem nivou + 12–16°C na tamnoj primami"). Nijedan app ovo ne radi za feeder.
4. **Offline-first** (loša mreža na obali) — već imamo offline bazu voda; konkurencija je web/PWA.

**Zaključak: pobeđujemo na feeder taktičkoj inteligenciji sloj iznad besplatnih RHMZ podataka,
offline, na srpskom.** Sve dole je rangirano po tom principu.

---

## 1. Šta već imamo (mapiranje na kod)

| Funkcija | Fajl | Status |
|---|---|---|
| Feeder/spin/plovak skoring | `lib/logic/technique_advisor.dart` (`_scoreFeeder`, `_scoreFloat`, `_scoreSpinning`) | ✅ ima turbidity switch |
| Preporuka feeder montaže | `technique_advisor.dart` (`feederRigRecommendation`) | ✅ osnovno |
| Ukupni skor + razlozi | `lib/models/fishing_score.dart` | ✅ |
| Turbiditet, proc. temp vode, pritisak trend | `lib/models/weather_data.dart` (`turbidity`, `estimatedWaterTemperature`, `pressureTrendCategory`) | ✅ |
| Prava temp vode (RHMZ) | `lib/services/rhmz_service.dart` | ✅ 132 stanice, 70km match |
| Vodostaj/protok (GloFAS) | `lib/services/water_service.dart` (`fetchWaterLevelForecast`) | ✅ |
| Offline baza voda (795) | `assets/data/serbia_waters.json` | ✅ |
| Lovostaj + min. mere + zaštićena područja | `lib/data/fishing_seasons.dart` | ✅ |
| Dnevnik (sqflite) | `lib/models/diary_entry.dart`, `lib/services/diary_service.dart` | ✅ |
| Mesec/solunar, izlazak/zalazak | `lib/utils/moon_calc.dart`, `sun_calc.dart` | ✅ |
| Karta | `lib/screens/map_screen.dart` (flutter_map) | ✅ |

---

## 2. Research sažetak — pravila spremna za kodiranje

### 2.1 Temperatura vode = glavni okidač (riba je hladnokrvna)

| Pojas | °C | Aktivnost | Mamac | Količina hrane |
|---|---|---|---|---|
| Hladno | <8 (gašenje <4) | dormant; klen/bodorka još jedu | sitan, lako svarljiv: 1 crv, kasterm, mikropelet 2mm, kukuruz, hleb | **minimalno** — prehranjivanje "ubija" jato |
| Sveže | 8–14 | umereno; mrena žestoko na rastu temp | crv, kaster, pelet, kukuruz | umereno, gradi sporo |
| Blago | 14–20 | optimum počinje ~15°C | ceo asortiman: boila, pelet, meso, kukuruz | izdašno |
| Toplo | >20 | visok metabolizam, kompeticija | veći mamci, boile, partikl, površinski | obilno |

**Trend > apsolut:** nagli PAD temp (>1–2°C preko noći) gasi ribu jače nego stabilna hladnoća.
Rastući trend = hrani više; brz pad = smanji. *(Angling Times, Match Fishing)*

### 2.2 Method/flat feeder na jezerima

- **Plafon dubine za method ≈ 1.8m (6ft)** — dublje hranilica se prazni u sloju → cage/PVA. *(baitsuperstore)*
- **Flat method** = tvrdo/koso dno, blizu ostrva; **round** = mulj. Default na komercijalcima.
- **Vrste i temp pragovi:** šaran 12–20°C (pad <8, torpid <4); F1 jede do ~6°C; deverika voli mulj/dubinu, niska svetlost; linjak 12–14°C+ (zima dormant); bodorka/skobalj jedu i na hladnom.
- **Primama:groundbait : mikropelet odnos** = glavni regulator: hladno → više primame (privlači, ne siti); toplo → više peleta (hrana). Zimi ~70/30 GB:micro → leto pelet-vođeno.
- **Kadenca zabacivanja:** hladno/sporo svakih 8–15 min; toplo/aktivno svakih 4–6 min.

### 2.3 Hranilica / podvez / udica (pravila)

| Promenljiva | Pravilo |
|---|---|
| Težina hranilice | reka: najlakša koja drži dno (leto 30–60g, raste na velikoj vodi/distanci). Jezero: blizu 20–25g, distanca/vetar/dublje 30–40g |
| Dužina podveza | feeder reka: 30cm start, +10cm do 60cm ako je riba plašljiva/voda bistra/hladna. Method: 4" (toplo) / 3" (hladno) |
| Debljina podveza | leto 0.18–0.22mm; zima 0.15mm; fini 0.12mm na ekstremno bistrom/hladnom |
| Udica | method 10–12 (6–8mm wafter/pelet), 14–16 hladno/sitnija riba; reka 16 za belu ribu |
| Tip hranilice | cage (privlači, oblak) → window (sitno, kad riba digne sa dna). "Privuci cage-om, uhvati window-om." |

### 2.4 Barometar / vetar / svetlo

- **Pritisak (šaran, pridneno):** <1010 hPa optimalno; >1030 loše (riba diže u stub vode).
  **Padajući** (pred front, oblačno + kiša) = vršni prozor hranjenja; **stabilan** = pouzdano;
  **brzi rast/ekstremi** = potisnuto. Modeluj **trend**, ne apsolut.
- **Vetar:** SW/S najbolje, E najgore. Riba se hrani na **niz-vetar obali** (toplo + hrana se gomila).
- **Svetlo/vreme:** zora (prva 2h) i sumrak najjači; leti sumrak > zora. Oblačno bolje od sunca.
  Hladna kiša gasi pridnene ugrize. Uzastopni mrazevi = stabilno; naizmenično toplo/mraz = teško.

### 2.5 Mamac po vrsti (srpski kontekst — velike reke)

| Vrsta | Hook mamci | Primama |
|---|---|---|
| Šaran | boila, kukuruz, tigrica, meso, crv, palenta | method/pelet, konoplja+kukuruz+sečena boila |
| Deverika | crv + kaster/kukuruz, 2–3 crva (maggot), kukuruz | **inertna** primama na dnu, izdašno; slatki braon krum |
| Mrena | 10–16mm halibut/fishmeal pelet (hair), meso kocka, boila | open-end + natopljen pelet/konoplja; voli halibut u mutnom |
| Bodorka | maggot, kaster, zrno kukuruza, hleb punch, konoplja | **aktivna** (konoplja fizz, fini krum), malo i često |
| Klen | kaster, meso, hleb, crv, pelet, sir-pasta | lagano, mašeni hleb; "kralj hladne vode" |
| Skobalj | zrno kukuruza, maggot, crv, palenta pasta | palenta+krum+konoplja+kukuruz, stalan trag |
| Babuška | crv, glista, kukuruz, hleb | fina slatka, male količine; vrlo oprezna |
| Som | mrtva/živa ribica, snop crva, džigerica, velika boila | miris-vođeno, krv/ulje trag; bez fine primame |
| Bucov (asp) | **samo varalica** — površinski spineri, kašike | n/a (grabljivica) |

---

## 3. Prioritizovana lista upgrade-a

Legenda: **V**=vrednost (feeder fokus), **T**=trud (S/M/L), 🎯=jasan prazan prostor vs konkurencija.

### TIER A — Brzi dobici (S, visok V)

**A1. 🎯 Savetnik za mamac i primamu po vrsti + uslovima**
- *Šta:* nova kartica/ekran "Mamac za danas" — input: izabrana voda (tip), prava temp vode (RHMZ),
  turbiditet, sezona → output: hook mamci + sastav primame + GB:pelet odnos + boja/aroma.
- *Kako:* nova `bait_advisor.dart` u `lib/logic/`, tabele iz §2.5 + §2.1. Reuse `WaterTurbidity`,
  `RhmzService` temp, `selectedWaterBody.type`. Prikaz sa fish ikonicama koje već imamo.
- *Zašto:* **najjači diferencijator** — nijedan app to ne radi za feeder.
- V: vrlo visok · T: M

**A2. Feeder-specifične preporuke montaže nadograditi**
- *Šta:* proširiti `feederRigRecommendation` → vrati i: dužinu podveza, debljinu, udicu, kadencu
  zabacivanja, tip hranilice (cage/window/open/method) — sve po §2.3.
- *Kako:* `technique_advisor.dart` — dodati polja u `TechniqueScore`/novi model; input flow
  (GloFAS discharge), dubina (proc.), temp vode, distanca (default).
- V: visok · T: S

**A3. Pritisak-trend bite skor (pravi trend, ne apsolut)**
- *Šta:* iskoristiti `pressureTrendPer3h` koji već imamo → eksplicitan "prozor hranjenja"
  indikator: padajući >2hPa/3h = 🟢 vršni; stabilan = 🟡; brzi rast = 🔴.
- *Kako:* već postoji `pressureTrendCategory`; dodati u skor i kao jasan badge na result ekranu.
- V: srednji · T: S

**A4. Kadenca zabacivanja + "prozor dana" tajming**
- *Šta:* prikaz preporučene kadence (4–6 / 8–15 min) i najboljih sati (zora/sumrak + solunar
  kao sekundaran) za izabranu vodu.
- *Kako:* `sun_calc` + `moon_calc` već daju podatke; kombinovati sa temp pojasom (§2.2).
- V: srednji · T: S

### TIER B — Srednje (M, visok V)

**B1. 🎯 Dnevnik koji auto-hvata uslove + analiza obrazaca**
- *Šta:* dnevnik već pamti uslove. Dodati: (1) auto-snimanje **prave RHMZ temp** + protoka +
  nivoa trenda u trenutku unosa, (2) ekran statistike: "tvoj ulov po temp pojasu / nivou /
  pritisku / primami" → "X ti ide najbolje na padajućem nivou + 12–16°C".
- *Kako:* `DiaryEntry` već ima polja; dodati `waterTempReal`, `discharge`. Nova
  `diary_stats_screen.dart` — grupisanje po opsezima, jednostavni agregati (count po vrsti × uslov).
- *Zašto:* niko ovo ne radi za coarse/feeder. Pretvara dnevnik u lични savetnik.
- V: vrlo visok · T: M

**B2. Air→water temp model (Mohseni-Stefan) za vode bez stanice**
- *Šta:* mnoge vode nemaju RHMZ stanicu <70km → trenutno fallback na grubu procenu. Zameniti
  kalibrisanim modelom: `Tw = μ + (α−μ)/(1+e^(γ(β−Ta)))`, fitovan na našim RHMZ serijama +
  Open-Meteo vazduh, **lagged 3–7 dnevni prosek** vazduha (toplotna inercija).
- *Kako:* offline fit (ovde, kao za dataset-e) → koeficijenti po regionu/tipu vode u JSON;
  runtime u `weather_data.dart` zameni `estimatedWaterTemperature`. Trening set = naš RHMZ scrape.
- *Zašto:* znатно tačnija temp svuda; koristi ono što već skupljamo.
- V: visok · T: M

**B3. RHMZ prognoza vodostaja (2–4 dana) za velike reke**
- *Šta:* `prognoza_voda.php` daje prognozu nivoa za ~20 stanica (Dunav/Tisa/Sava/Morava).
- *Kako:* isti scrape pattern kao `stanje_voda.php` u `RhmzService`. Prikaz uz GloFAS protok.
- *Zašto:* feeder na velikoj reci = nivo trend je sve. Forward-looking.
- V: visok (velike reke) · T: M

**B4. Notifikacije "feeder prozor"**
- *Šta:* push kad se poklope dobri uslovi za sačuvanu omiljenu vodu: "Sava pada 20cm + pritisak
  opada → jak feeder prozor sutra ujutru."
- *Kako:* `flutter_local_notifications` + periodični background check (workmanager). Kombinuje
  nivo-trend + pritisak-trend + temp pojas.
- V: srednji-visok · T: M-L (background scheduling je gnjavaža)

### TIER C — Veliko / kasnije (L)

**C1. Method feeder modul za jezera**
- *Šta:* zaseban tok kad je izabrana voda jezero: method vs flat izbor, plafon dubine 1.8m
  upozorenje, GB:pelet kalkulator po temp, izbor jata (niz-vetar obala, margine leti).
- *Kako:* grananje u `technique_advisor` po `type=='lake'`; nova logika iz §2.2.
- V: srednji (sekundaran fokus) · T: M-L

**C2. Karta sa slojevima (protok/temp/zaštićeno)**
- *Šta:* na postojećoj `map_screen` dodati bojenje markera po temp vode / nivou trendu, prikaz
  RHMZ stanica, zaštićenih područja, lovostaj indikator.
- V: srednji · T: M

**C3. Offline-first hardening + lovostaj kontekstualna upozorenja**
- *Šta:* sve ključno radi bez mreže (već većina); + aktivno upozorenje na result/diary ekranu
  "som u lovostaju do 15.6 — pusti" (podaci već u `fishing_seasons.dart`).
- V: srednji · T: S-M

### TIER D — Aspiraciono / slab osnov

- **Rastvoreni kiseonik (DO)** — SEPA/RHMZ objavljuju ali kao PDF/periodični izveštaji, ne živi feed. Krhko.
- **Termoklina jezera** — nema javnih podataka; samo heuristika (sezona + dužina dana).
- **Nivoi akumulacija** (Gazivode/Vlasina/Ćelije) — interno EPS/Srbijavode, nije otvoreno.
- **Solunar kao primarni driver** — nema naučne podloge; držati kao kozmetički/sekundarni indikator.
- **Air quality / Marine API** (Open-Meteo) — marginalno/ocean-only, neupotrebljivo.

---

## 4. Konkretni rule-set dodaci (za `technique_advisor.dart` / novi `bait_advisor.dart`)

```
INPUT: species?, waterTempC (RHMZ ili Mohseni), venueType (river/lake),
       turbidity, dischargeTrend, month, pressureTrendPer3h

TEMP GATE (master):
  <8°C   → feed=MIN, baitSize=small, baits=[crv, kaster, mikropelet2mm, kukuruz1zrno], GB:pellet=80:20, GB=tamna/fina
  8–14   → feed=LOW-MED, baits=[crv, kaster, pelet, kukuruz], GB:pellet=70:30
  14–20  → feed=MED-HIGH, baits=[boila, pelet, meso, kukuruz, crv], GB:pellet=50:50
  >20    → feed=HIGH, baits=[boila, partikl, veći pelet], GB:pellet=pellet-led

FLOW (reka, GloFAS discharge trend):
  rastući/obojen → feeder=open-end/cage TEŽI (+), podvez kraći, mamac jak/svetao (halibut, meso)
  stabilan       → najlakši koji drži dno
  padajući/bistar→ podvez duži+finiji, mamac prirodan (konoplja+kaster), GB tamna low-feed

TURBIDITY:
  clear      → prirodne boje, fini/tamni GB, duži podvez
  turbid+    → svetao/jak miris, kraći podvez OK

PRESSURE (pressureTrendPer3h):
  < -2 hPa/3h → 🟢 vršni prozor
  -2..+2      → 🟡 neutralno
  > +2        → 🔴 potisnuto (probaj plići/up-in-water)

VENUE lake (method):
  depth>1.8m → upozorenje "method se prazni, koristi cage/PVA"
  flat ako tvrdo/kosivo dno; round ako mulj
  niz-vetar obala; margine leti/zora-sumrak

PREDATOR branch (som/bucov): preskoči GB logiku → deadbait/varalica
```

---

## 5. Data izvori za integraciju (prioritet)

**Integriši odmah (visok ROI):**
1. **Pritisak-trend** iz Open-Meteo `pressure_msl` (već imamo `pressureTrendPer3h`) → bite skor.
2. **RHMZ prognoza nivoa** (`prognoza_voda.php`) — isti scrape kao temp.
3. **Air→water Mohseni model**, kalibrisan na našem RHMZ scrape-u — pokriva sve vode bez stanice.
4. **Open-Meteo dodatno:** `soil_temperature_*` (proksi za plitke vode), `cloud_cover`, `uv_index`,
   `past_days`/Historical API za lagged padavine (runoff/turbiditet).

**Semi (batch/krhko):**
5. SEPA dnevni kvalitet površinskih voda (rastvoreni kiseonik) — scrape ako je strukturisano.
6. Vode Vojvodine "ribarska područja" — metapodaci o legalnim/poribljenim vodama.
7. ZJZ Subotica — monitoring Palić/Ludaš.

**Tvrdo NE:** Open-Meteo DO/inland water-temp (ne postoje), Marine API (ocean), RDV/Srbijavode
(administrativno, bez realtime).

**Validacija meseca/solunara:** USNO AA API v4 (`aa.usno.navy.mil/data/api`) — za proveru, ne runtime.

---

## 6. Predlog redosleda implementacije

1. **A1 Bait advisor** (najjači diferencijator, srednji trud) →
2. **A2 + A3 + A4** feeder rig/pritisak/tajming (brzi, dopunjuju A1) →
3. **B2 Mohseni temp model** (tačnija temp svuda, koristi postojeći scrape) →
4. **B1 Dnevnik statistika** (lični savetnik — drugi veliki diferencijator) →
5. **B3 RHMZ prognoza nivoa** →
6. **C1 Method jezera modul** →
7. ostalo (notifikacije, slojevi karte) po želji.

> Sve A+B stavke su feeder-fokusirane i grade na onome što već imamo (RHMZ, GloFAS, turbiditet,
> dnevnik). C1 pokriva method-na-jezerima sekundarni fokus. Nijedna ne zavisi od neizvesnih izvora.
