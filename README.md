# FishingWorthy 🎣

Flutter Android aplikacija za **prognozu uslova za ribolov u Srbiji**, sa fokusom na
**feeder tehniku** (velike reke: Dunav, Sava, Tisa, Morava) i **method/flat feeder na jezerima**.
Spaja vremensku prognozu, pravu temperaturu vode i vodostaj sa nacionalnih izvora, srpski
ribolovni zakon (lovostaj, mere, zaštićena područja), pecaroški dnevnik i taktički savetnik.

> Plan razvoja i prioriteti su u **`docs/UPGRADE_IDEAS.md`** (nije `plan.md`).

---

## Tehnološki stek

- **Flutter / Dart** (Android), Material 3
- Bez backend-a — sve preko javnih API-ja + offline bundlovanih podataka
- Lokalna baza: **sqflite** (dnevnik), **shared_preferences** (omiljene, nedavne pretrage)
- Karta: **flutter_map** + OpenStreetMap pločice (`latlong2`)
- Mreža: `http`, lokacija: `geolocator` + `permission_handler`

```yaml
dependencies: http, geolocator, permission_handler, intl,
  shared_preferences, sqflite, path, flutter_map, latlong2
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
  main.dart
  data/
    fishing_seasons.dart      # lovostaj, min. mere, zaštićena područja, FishReg (icon-fish)
  logic/
    technique_advisor.dart    # skoring feeder/plovak/varalica + scoreFor + sezonske ribe
    bait_advisor.dart         # FeederPlan iz uslova (mamac/primama/montaža/kadenca)
  models/
    weather_data.dart         # DailyForecast, HourlyWeather, turbiditet, proc. temp vode,
                              #   pressureTrendCategory, WaterBody, WaterLevelForecast
    fishing_score.dart        # FishingScore.calculate (+ windDirectionAdjustment, waterTempOverride)
    technique_score.dart      # TechniqueType, TechniqueScore
    feeder_plan.dart          # FeederPlan
    diary_entry.dart          # DiaryEntry, CatchItem
  services/
    weather_service.dart      # Open-Meteo forecast
    water_service.dart        # offline vode (serbia_waters.json) + GloFAS flood API
    rhmz_service.dart         # scrape hidmet.gov.rs: temp vode + prognoza nivoa
    location_service.dart     # Open-Meteo geocoding (RS) + Nominatim reverse
    favorites_service.dart, recent_searches_service.dart, diary_service.dart
  screens/
    home_screen.dart, result_screen.dart, waters_list_screen.dart, map_screen.dart,
    regulations_screen.dart, diary_list_screen.dart, diary_entry_screen.dart, diary_stats_screen.dart
  utils/
    moon_calc.dart, sun_calc.dart, fish_icons.dart
  widgets/
    score_gauge.dart, weather_param_tile.dart

assets/
  data/serbia_waters.json     # 795 voda (offline)
  data/rhmz_stations.json     # 132 hidrološke stanice + koordinate
  icons/*.png                 # 14 ikonica vrsta riba

docs/UPGRADE_IDEAS.md         # plan razvoja + status
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

**Implementirano:** prognoza + ocenjivanje (sa smerom vetra, pravom temp vode, zora/sumrak),
filter tehnike po intervalima, feeder/method savetnik, offline baza voda + karta, RHMZ temp +
prognoza nivoa, lovostaj/mere/zaštićena područja, dnevnik + statistika, omiljene/nedavne.

**Otvoreno (vidi `docs/UPGRADE_IDEAS.md`):**
- B2 Mohseni air→water model (treba kalibracione podatke; sad fallback = vazduh − sezonski offset)
- B4 push notifikacije "feeder prozor" (background scheduling)
- C2 slojevi karte (temp/nivo bojenje)

---

## Domen (srpski termini)

PURS/RHMZ = Republički hidrometeorološki zavod · vodostaj = water level · lovostaj = closed season ·
mera = minimalna dužina · primama = groundbait · feeder/method = tehnike dnevnog ribolova ·
deverika/šaran/mrena/skobalj/bodorka/babuška/klen/bucov/som/smuđ/štuka/amur/plotica/šljivar = vrste.

---

## Napomene
- Bez automatskih testova (verifikacija: `flutter analyze` + ručni trace).
- Svi podaci su informativni; lovostaj/mere proveriti kod lokalnog ribolovačkog udruženja.
