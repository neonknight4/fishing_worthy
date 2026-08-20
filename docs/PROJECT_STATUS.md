# Upecaj! — stanje projekta i mapa puta

> Konsolidovan pregled: gde smo sada, šta je otvoreno, i predlozi za dalje.
> Datum: **2026-07-24**. Grana: `feature/traper-bait-recommender`.
> Ostali docs: `README.md` (tehnički), `docs/TRAPER_KOMBINACIJE.md` (recepti),
> `docs/METHOD_TAB.md` + `METHOD_REVIRI.md` (Method), `docs/TRAPER_KOMBINACIJE.md` (recepti), `docs/archive/` (stari planovi/istraživanje).

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
  - **Bottom-nav shell** (`app_shell.dart`): Početna · Mapa · Dnevnik · Propisi.
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
