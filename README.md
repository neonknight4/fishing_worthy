# Upecaj! 🎣

Flutter Android aplikacija za **prognozu uslova za ribolov u Srbiji**, sa fokusom na
**feeder tehniku** (velike reke: Dunav, Sava, Tisa, Morava) i **method/flat feeder na jezerima**.
Spaja vremensku prognozu, pravu temperaturu vode i vodostaj sa nacionalnih izvora, srpski
ribolovni zakon (lovostaj, mere, zaštićena područja), pecaroški dnevnik, taktički savetnik i
**Traper preporuke primama** (kurirane kombinacije po vodi/sezoni, sa m-fishing.rs kupovinom).

> **Ime:** "Upecaj!" (display). Interni package/klasa ostaju `fishing_worthy` / `FishingWorthyApp`.
> **Stanje i mapa puta:** `docs/PROJECT_STATUS.md`. Starije istraživanje/planovi: `docs/archive/`.
> **Dizajn:** "moderan outdoor dashboard", light + dark (Baloo 2 + Manrope, brend tamno zelena).

---

## Tehnološki stek

- **Flutter / Dart** (Android), Material 3, custom tema (ThemeExtension, light+dark)
- Bez backend-a — sve preko javnih API-ja + offline bundlovanih podataka
- Lokalna baza: **sqflite** (dnevnik), **shared_preferences** (omiljene, nedavne, tema)
- Karta: **flutter_map** + OpenStreetMap pločice (`latlong2`)
- Mreža: `http`, lokacija: `geolocator` + `permission_handler`
- Tipografija: **google_fonts** (Baloo 2 + Manrope); linkovi: **url_launcher**
- Ikone: **flutter_launcher_icons** (adaptive, cream ribica na zelenom)

```yaml
dependencies: http, geolocator, permission_handler, intl,
  shared_preferences, sqflite, path, flutter_map, latlong2,
  url_launcher, google_fonts
dev_dependencies: flutter_launcher_icons
```

---

## Funkcije

### Prognoza i ocenjivanje
- **Ukupna ocena (0–100)** uslova za pecanje sa razlozima (povoljno/nepovoljno).
  Faktori: temperatura vode (težinski deverika/šaran/mrena), vetar (brzina **i smer** —
  J/JZ podstiče, I gasi), kiša, **trend pritiska** (pre-frontalni prozor), oblačnost,
  zamućenost (turbiditet), trend vodostaja.
- **Prognoza po intervalima (3h)** sa **filterom tehnike** (Feeder / Plovak / Varalica) —
  svaki slot se ocenjuje za izabranu tehniku + **zora/sumrak bonus** (varalica +12, feeder +6,
  plovak +5). Zlatni slot (⭐) i solunar markeri (🌙/🌛).
- **Zasebno ocenjivanje po tehnici** — grabljivice (varalica) vole bistro/talasanje/polumrak;
  bela riba (feeder) mir/blago mutno/porast vodostaja.

### Voda i lokacija
- Pretraga lokacija (**samo Srbija**, latinica) + GPS dugme.
- **Offline baza ~795 ribolovnih voda** (`serbia_waters.json`) — reke/jezera u krugu,
  filter radijusa 10/25/50 km, lista + **karta** (markeri, izbor vode).
- Auto-izbor najbliže **velike reke** za vodostaj (prioritet Dunav/Sava/Tisa/Morava…).

### Pravi podaci (RHMZ — hidmet.gov.rs)
- **Temperatura vode** sa najbliže hidrološke stanice (≤70 km, 132 stanice).
- **Prognoza vodostaja** (1–4 dana) — izlistava **sve reke u krugu 60 km** (jedna stanica po reci).
- Vodostaj/protok preko **Open-Meteo flood API (GloFAS)**.

### Feeder/method savetnik
- **"FEEDER PLAN / METHOD PLAN ZA DANAS"** — vođen pravim uslovima: mamac na udici, primama
  (+ odnos primama:pelet), količina hrane, tip hranilice + težina, podvez (dužina·debljina),
  udica, kadenca zabacivanja, kontekstualne napomene. Jezero → method/flat grana (plafon 1.8 m).

### Traper primame (m-fishing.rs)
- **Katalog 44 proizvoda** (`traper_baits.dart`) + **80 kuriranih kombinacija** = 20 voda × 4 sezone
  (`traper_combos.dart`, 10 reka + 10 jezera). Combo = baza + miks + odnos + pelet/aditivi + mamac +
  priprema + hranjenje; aktivnost ribe je modifikator.
- **Hibrid:** voda ima kuriran recept → prikaži ga; inače → algoritamski predlog (za ostalih ~775 voda).
- **"Kupi na m-fishing.rs"** na svakom proizvodu; ako je stranica uklonjena (404/410) → fallback `/shop/`.
- ⚠ Recepti su trenutno heuristika + 1 FB recept — **nisu zvanične Traper razmere** (vidi `PROJECT_STATUS.md`).

### Zakon
- **Lovostaj i dozvoljene mere** — ekran sa svim vrstama (sa ikonicama), trenutno zabranjene
  gore (crveno), minimalne mere, disclaimer (propisi RS).
- Kontekstualno upozorenje na lovostaj na ekranu rezultata.
- **Zaštićena područja** (~22) sa cenom posebne dozvole — match po imenu vode/lokacije.

### Pecaroški dnevnik (sqflite)
- Auto-hvata uslove tog dana (temp vazduha, **prava temp vode RHMZ**, pritisak, vetar,
  vodostaj trend, mesečeva faza).
- Unos ulova po vrsti + broj komada + max kg/cm, tehnika, mamac, beleške.
- **Statistika**: ulov po vrsti + **najbolji uslovi** (temp pojas / vodostaj / pritisak →
  riba po izlasku).

### Ostalo
- Omiljene lokacije + nedavne pretrage (dropdown).
- Mesečeva faza + solunar prozori, izlazak/zalazak sunca.
- Sezonske aktivne vrste po mesecu.

---

## Arhitektura

```
lib/
  main.dart                   # MaterialApp (light/darkTheme, themeMode) → AppShell
  theme/
    app_colors.dart           # AppColors ThemeExtension (light+dark tokeni) + AppRadius + context.c
    app_theme.dart            # ThemeData light/dark + Baloo2/Manrope (context.display/ui)
    theme_controller.dart     # ThemeMode (light default), toggle, persist
  data/
    fishing_seasons.dart      # lovostaj, min. mere, zaštićena područja, FishReg (icon-fish)
    traper_baits.dart         # 44 Traper proizvoda + baitById()
    traper_combos.dart        # 80 kombinacija (20 voda × 4 sezone) + comboFor()/seasonForMonth()
  logic/
    technique_advisor.dart    # skoring feeder/plovak/varalica + scoreFor + sezonske ribe
    bait_advisor.dart         # FeederPlan iz uslova (mamac/primama/montaža/kadenca)
    bait_recommender.dart     # algoritamski Traper predlog (fallback kad nema kuriranog combo-a)
  models/
    weather_data.dart         # DailyForecast, HourlyWeather, WaterBody, WaterLevelForecast, LocationInfo
    fishing_score.dart        # FishingScore.calculate (+ windDirectionAdjustment, waterTempOverride)
    technique_score.dart, feeder_plan.dart, diary_entry.dart (+ photos)
    bait_product.dart         # BaitProduct (katalog)
    water_combo.dart          # WaterCombo, Season, FishActivity
    commercial_lake.dart      # CommercialLake (Method revir)
  services/
    weather_service (+ fetchDay), water_service, rhmz_service, location_service,
    favorites_service, recent_searches_service, diary_service (+ diaryRevision),
    commercial_lakes_service
  screens/
    app_shell.dart            # bottom nav: Početna · Mapa · Method · Traper · Dnevnik
    home_screen, result_screen, waters_list_screen, map_screen, regulations_screen,
    favorites_screen, method_screen (revir mapa), traper_screen + catalog_screen (PDF),
    diary_list_screen, diary_entry_screen, diary_stats_screen
  utils/
    moon_calc.dart, sun_calc.dart, fish_icons.dart
  widgets/
    components.dart           # deljene komponente (AppCard/Chip/Button/HalfGauge/PageHeader…)
    nav_icons.dart            # custom SVG ikone bottom nav-a

assets/
  data/serbia_waters.json         # 795 voda (offline)
  data/rhmz_stations.json         # 132 hidrološke stanice + koordinate
  data/commercial_lakes.json      # 18 komercijalnih method revira (Method tab)
  icons/*.png                     # 15 ikonica vrsta riba (+ tolstolobik)
  bait/*.jpg                      # slike Traper proizvoda (43)
  brand/                          # logo lockup + ribica + app/adaptive ikona
  catalog/traper_katalog_2026.pdf # Traper katalog (bundlovan, 23MB)

docs/PROJECT_STATUS.md        # stanje + mapa puta + predlozi (glavni pregled)
docs/METHOD_TAB.md            # plan Method taba (+ školica ideja)
docs/METHOD_REVIRI.md         # komercijalni reviri (podaci + istraživanje)
docs/TRAPER_KOMBINACIJE.md    # recepti (human-readable)
docs/archive/                 # stariji planovi/istraživanje (SPRINT, UPGRADE_IDEAS)
tools/                        # build skripte za datasetove (build_waters.py, build_stations.py)
```

---

## Izvori podataka

| Izvor | Šta | Pristup |
|---|---|---|
| **Open-Meteo Forecast** | vreme (temp, vetar, pritisak, oblačnost, padavine) | REST, besplatno |
| **Open-Meteo Flood (GloFAS)** | protok reke / vodostaj trend | REST `river_discharge` |
| **Open-Meteo Geocoding** | pretraga mesta (filter `country_code=RS`, `sr-Latn`) | REST |
| **Nominatim (OSM)** | reverse geocoding (GPS → ime mesta) | REST |
| **RHMZ — hidmet.gov.rs** | prava temp vode + prognoza vodostaja | scrape HTML (vidi napomene) |
| **Overpass / OSM** | baza voda (izvučeno **jednom**, sada offline) | bundlovano |

### Napomene o RHMZ scrape-u
- `stanje_voda.php` → temp vode; `prognoza_voda.php` → prognoza nivoa (21 stanica, 6 reka).
- **TLS:** hidmet ima nepotpun cert lanac → `HttpClient.badCertificateCallback` samo za taj host.
- **`&nbsp;` je literalni entitet** u HTML-u (`&nbsp;21.8`) — mora se ukloniti pre `double.tryParse`.
- Koordinate stanica nisu na stranici → bundlovane (`rhmz_stations.json`, geocodovane jednom).

---

## Build & pokretanje

```bash
flutter pub get
flutter run                                   # debug na povezanom uređaju

# Release APK (po ABI — manji)
flutter build apk --release --split-per-abi
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (~19 MB, moderni telefoni)

adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Osvežavanje offline datasetova (povremeno)
```bash
# Vode (Overpass → assets/data/serbia_waters.json)
python3 tools/build_waters.py        # zahteva data_raw/ dump-ove

# RHMZ stanice (parse + geocode → assets/data/rhmz_stations.json)
python3 tools/build_stations.py      # zahteva data_raw/stanje_voda.html
```

---

## Status

**Implementirano:** prognoza + ocenjivanje (smer vetra, prava temp vode, zora/sumrak),
filter tehnike po intervalima, feeder/method savetnik, offline baza voda + karta, RHMZ temp +
prognoza nivoa, lovostaj/mere/zaštićena područja, dnevnik + statistika, omiljene/nedavne,
**Traper primame (44 katalog + 80 kombinacija + m-fishing kupovina)**, **pun redizajn light+dark**,
bottom-nav shell, novi logo/ikona.

**Otvoreno (vidi `docs/PROJECT_STATUS.md` za pun spisak + prioritete):**
- D1 Traper recepti nisu zvanični (heuristika + 1 FB) — treba potvrda razmera
- D2 3 delistovana m-fishing proizvoda (River u 9 combo-a) — buy-link pada na `/shop/`, treba SKU
- SPRINT 2 pop-up/wafter hookbait grana; SPRINT 3 dnevnik inteligencija
- B2 Mohseni air→water model; B4 push "feeder prozor"; C2 slojevi karte

---

## Domen (srpski termini)

PURS/RHMZ = Republički hidrometeorološki zavod · vodostaj = water level · lovostaj = closed season ·
mera = minimalna dužina · primama = groundbait · feeder/method = tehnike dnevnog ribolova ·
deverika/šaran/mrena/skobalj/bodorka/babuška/klen/bucov/som/smuđ/štuka/amur/plotica/šljivar = vrste.

---

## Napomene
- Bez automatskih testova (verifikacija: `flutter analyze` + ručni trace).
- Svi podaci su informativni; lovostaj/mere proveriti kod lokalnog ribolovačkog udruženja.
