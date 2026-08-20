# Upecaj! — plan izlaska (Google Play + društvene mreže)

> Cilj: **maksimalan broj pecaroša koristi app**. Monetizacija = nije cilj u ovoj fazi.
> Datum plana: 2026-08-20. Stanje: Flutter 3.41.9, samo Android, `versionCode` 1.
> Metrika uspeha faze 1: **1.000 instalacija + D7 retention ≥ 25%** u prva 3 meseca.

---

## Stanje na 2026-08-20 (posle tehničke pripreme)

Urađeno u kodu: `applicationId rs.upecaj.app`, release signing wiring, SDK pinovi,
OSM atribucija na obe mape, slike primama 12 → 2.7 MB, `site/` (privacy + landing).
`flutter analyze` clean, `flutter build appbundle --release` prolazi.

**Ostalo pre uploada (samo ovo blokira Play):**
1. Generiši upload keystore + `android/key.properties` (lozinke su tvoje).
2. Objavi `site/` na GitHub Pages → dobij privacy URL.
3. ~~Support e-mail~~ ✅ `upecaj.rs@gmail.com` upisan u `site/*.html`.
4. Pisana potvrda od **vlasnika m-fishinga** (slike su sa njegovog sajta) — mejl/Viber
   sa „potvrđujem" je dovoljan, tekst je u `docs/legal/DOZVOLE.md`. Traper se ne kontaktira
   (odluka 2026-08-20). Ne blokira upload.
5. Ručni prolaz svih ekrana u light + dark na telefonu.
6. Store grafika: ikona 512, feature graphic 1024×500, 6 screenshot-ova.
7. Play Console: račun + verifikacija identiteta (pokreni prvo — traje najduže).

**Preporuka pre launcha, van blokera:** deljenje ulova kao slika (Faza 4.6 — petlja rasta),
in-app review prompt, onboarding 3 ekrana. To troje najviše utiče na cilj (broj korisnika).

---

## Rezime rokova

| Nedelja | Fokus | Ključni ishod |
|---|---|---|
| N1 | Tehnička priprema builda (Faza 0) | AAB potpisan release ključem, privacy policy live |
| N2 | Play Console setup + internal testing | app kreiran, listing popunjen, internal test link radi |
| N2–N4 | **Closed testing, 12+ testera, 14 dana neprekidno** | uslov za production pristup (lični račun) |
| N4 | Prijava za production + review | odobrenje |
| N5 | Staged rollout 20% → 100% | app javno na Play |
| N5+ | Društvene mreže, grupe, partneri | kontinuirano, po kalendaru iz Faze 4 |

⚠️ Najveći skriveni rok: **closed testing 12 testera / 14 dana** (Google pravilo za nove lične developer račune). Testere počni da skupljaš **odmah**, paralelno sa Fazom 0 — to je kritični put, ne kod.

---

# FAZA 0 — Tehnička priprema (blokira sve)

## 0.1 Application ID — ✅ urađeno
`applicationId` i `namespace` = **`rs.upecaj.app`** (`android/app/build.gradle.kts`).
Kotlin paket premešten: `android/app/src/main/kotlin/rs/upecaj/app/MainActivity.kt`.
`userAgentPackageName` usklađen na oba mesta (`map_screen.dart:208`, `method_screen.dart:79`).

Posle prve objave na Play ovaj ID se **ne može menjati** — ne diraj ga više.
Interni Dart paket ostaje `fishing_worthy` (nije vidljiv korisniku).

## 0.2 Release signing — ⚠️ kod spreman, ključ na tebi
`build.gradle.kts` čita `android/key.properties` i potpisuje release tim ključem;
ako fajla nema, pada na debug ključ i ispisuje upozorenje u Gradle logu
(**takav AAB Play odbija**). Šablon: `android/key.properties.example`.
Signing put je proveren privremenim test ključem — build prošao, AAB potpisan
(`keytool -printcert -jarfile ...` vratio test sertifikat); test ključ je obrisan.

Napravi svoj ključ (uradi sam, lozinke ne idu kroz mene):
```bash
keytool -genkey -v -keystore ~/upecaj-upload.jks -keyalg RSA -keysize 2048 \
        -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # popuni lozinke
```
`android/key.properties` i `*.jks` su u `.gitignore`.

**Backup ključa:** kopija `.jks` + lozinke na 2 mesta (password manager + eksterni disk).
Uz **Play App Signing** (uključi, default za nove aplikacije) izgubljen upload ključ
se može resetovati kroz support — ali ne računaj na to.

## 0.3 Build artefakt
Play zahteva **AAB**:
```bash
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols
```
- Sačuvaj `build/symbols` po verziji — bez toga su stack trace-ovi u Console-u nečitljivi.
- Uploaduj ih u Play Console (App bundle explorer → deobfuscation file).
- Trenutno stanje: `flutter build appbundle --release` prolazi, AAB **81.2 MB**
  (sve ABI arhitekture u jednom bundle-u; Play korisniku šalje samo njegovu —
  realna instalacija ≈ 40 MB, tačan broj vidiš u Console-u posle uploada).

## 0.4 SDK nivoi — ✅ pinovani
`compileSdk = 36`, `targetSdk = 36`, `minSdk = 24` (Android 7.0) — eksplicitno u
`build.gradle.kts`, više ne "plutaju" sa Flutter verzijom. Pre uploada proveri u
Console-u da je 36 još uvek dovoljan `targetSdk` (Google diže prag svake godine).

## 0.5 Veličina aplikacije — ✅ slike, ⚠️ PDF ostaje
Slike primama rekompresovane u mestu (ista imena, bez izmene koda): JPEG q4,
max stranica 900px → **11.5 MB → 2.7 MB**. Vizuelno bez razlike na 600px prikazu.
Originali su u git istoriji ako zatreba.

| Folder | Bilo | Sad |
|---|---|---|
| `assets/bait` (43 slike) | 12 MB | **2.7 MB** |
| `assets/catalog` (PDF) | 23 MB | 23 MB |
| `assets/icons` + `brand` | 2.3 MB | 2.3 MB |
| **assets ukupno** | 36 MB | **28 MB** |

PDF katalog se **ne može kompresovati** — već je prošao Ghostscript (23 MB → 22.9 MB,
bez efekta), a agresivnija rasterizacija bi upropastila katalog. Dve opcije:
1. Ostavi bundlovan za v1.0 — radi offline, jednostavno. **Preporuka za launch.**
2. Za v1.1: okači PDF na GitHub Pages (`site/`) ili m-fishing server i skini ga na
   zahtev — `catalog_screen.dart` je već napisan sa tom namerom (vidi komentar iznad
   `_prepare()`); menja se samo taj metod + `pubspec.yaml`. Ušteda **-23 MB**.

## 0.6 Dozvole i Data Safety
Manifest traži: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET`. Nema background lokacije, nema foreground servisa → **nema dodatnog Play review-a**. Zadrži tako.

Proveri šta pluginovi ubacuju u merged manifest:
```bash
flutter build appbundle --release
grep -E "uses-permission|queries" build/app/intermediates/merged_manifests/release/AndroidManifest.xml
```
**✅ provereno na release buildu** (`build/app/intermediates/merged_manifest/release/...`):
u finalnom manifestu su samo `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `INTERNET`
i `rs.upecaj.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (androidx interno, bezopasno).
Nema `READ_MEDIA_IMAGES` — `image_picker` koristi sistemski photo picker. Ništa ne treba dirati.

**Data safety forma (odgovori za trenutni kod):**
- Lokacija: *prikupljana? NE. Deljena? NE.* Koristi se na uređaju za odabir najbliže vode. (Ako geolokaciju šalješ Open-Meteo/RHMZ-u, to je "korišćena, ne prikupljana" — ali koordinate idu third-party API-ju; deklariši kao **App activity/Location → shared with third parties: no, used ephemerally**.)
- Fotografije: lokalno u SQLite/fs, nikad ne izlaze sa uređaja → nije prikupljanje.
- Nema računa, nema logina → **Account deletion policy nije potrebna**.
- Bez reklama, bez analytics SDK-ova (trenutno) → deklaracije ostaju minimalne. Ako kasnije dodaš Crashlytics/Analytics, **moraš ažurirati formu istog dana**.

## 0.7 Privacy policy + landing — ✅ napisano, ostaje objava
Folder **`site/`** u repou: `privacy.html` (puna politika, srpski), `index.html`
(landing sa opisom i Play badge-om), `style.css` u brend bojama, `site/README.md`
sa koracima za objavu.

Ostaje ti:
1. ✅ kontakt mejl upisan (`upecaj.rs@gmail.com`); ostaje `PLAY_URL` u `index.html` kad app izađe.
2. Novi javni repo `upecaj-site` → kopiraj sadržaj `site/` u root → push.
3. Settings → Pages → `Deploy from a branch`, `main`, `/root`.
4. URL `https://<user>.github.io/upecaj-site/privacy.html` → Play Console → Store settings.
5. Dodaj 4–6 screenshot-ova u `site/img/` i ubaci ih u `index.html`.

Politika tvrdi: nema servera, nema računa, dnevnik i fotografije ostaju na telefonu,
lokacija se ne čuva (samo prosleđuje Open-Meteo/RHMZ/GloFAS radi upita), nema reklama
ni analytics SDK-ova. **Ako dodaš Crashlytics/Analytics — moraš izmeniti i ovaj fajl
i Data safety formu istog dana.**

## 0.8 Pravno / atribucija (rizik reputacije i skidanja)
| Stvar | Šta treba |
|---|---|
| OSM tile-ovi | ✅ **urađeno** — `OsmAttribution` widget (`lib/widgets/components.dart`) stalno vidljiv dole-desno na obe mape (`map_screen`, `method_screen`), tap otvara `openstreetmap.org/copyright`; `userAgentPackageName` = `rs.upecaj.app`. |
| Open-Meteo | Non-commercial korišćenje slobodno; navedi izvor u "O aplikaciji". |
| RHMZ (hidmet.gov.rs) | Scrape javnih podataka; navedi izvor + "podaci informativni". |
| Slike proizvoda + katalog PDF | Dozvolu daje vlasnik m-fishinga — slike su sa njegovog sajta, on je uvoznik Trapera za Srbiju i nema primedbu. Traži samo da to potvrdi **u pisanom obliku** (`docs/legal/DOZVOLE.md`) i arhiviraj. |
| Traper recepti | U aplikaciji jasno označi **heuristika vs. verifikovano** (dug D1 iz PROJECT_STATUS). Ne predstavljaj kao zvanične recepte proizvođača. |
| Lovostaj / propisi | Disclaimer **već postoji** (`regulations_screen.dart:58`, tekst "datumi mogu varirati po ribolovnom području — proveri kod lokalnog udruženja") + `WarnBanner` "Poštuj lovostaj". Isti tekst je i u `site/privacy.html` (tačka 8). Ostaje samo da ga ne izgubiš u budućim redizajnima — pogrešan lovostaj = kazna korisniku. |

## 0.9 Stabilnost pre uploada
```bash
flutter analyze
flutter build appbundle --release
```
- Ručni prolaz po svim ekranima u **light i dark** (dug D6).
- Test na 2 uređaja različite veličine ekrana; posebno mapa i Dnevnik/foto.
- Prazna stanja: bez interneta, bez dozvole za lokaciju, GPS ugašen, voda bez kuriranog combo-a (fallback grana).
- Play **Pre-launch report** (dobija se automatski na internal testing) — pokreće app na farmi uređaja i vraća crash/ANR/accessibility nalaze. Besplatno i vredno.

## 0.10 Growth kuke u kodu (uradi PRE launcha — direktno utiču na cilj)
Ove tri stvari su najjeftiniji rast po uloženom satu:

1. **Deljenje ulova kao slika** — iz Dnevnika generiši kartu (riba, voda, težina, uslovi, mali "Upecaj!" logo) i `Share`. Svaki korisnik koji podeli ulov na FB je besplatna reklama sa socijalnim dokazom. **Najveći ROI feature za rast.**
2. **In-app review prompt** (`in_app_review`) — traži ocenu posle 3. uspešne upotrebe (ne pri prvom otvaranju). Ocene direktno dižu rang u Play pretrazi.
3. **Onboarding u 3 ekrana** (iz todo liste) — objasni ocenu 0–100, mapu, primame. Bez toga prvi ekran deluje kao "još jedna vremenska prognoza" i D1 retention pada.

---

# FAZA 1 — Google Play Console

## 1.1 Račun
- $25 jednokratno, **lični (individual) račun**.
- **Verifikacija identiteta**: lično ime, adresa, dokument, telefon. Traje od par dana do 2 nedelje → **pokreni prvo, pre svega ostalog**.
- Ime developera vidljivo na Play-u — biraj ono što želiš javno (npr. "Upecaj!" ili tvoje ime).
- Adresa se javno prikazuje kod ličnog računa — koristi adresu koju ti ne smeta da bude javna.

## 1.2 Testing lestvica (redosled je obavezan)
1. **Internal testing** — do 100 testera, odobrenje odmah, bez 14-dnevnog pravila. Koristi za lične provere i pre-launch report.
2. **Closed testing** — **≥12 testera koji su prihvatili poziv i ostali 14 dana neprekidno**. Google zatim otvara "Apply for production".
   - Praktično: zovi **20 ljudi**, računaj na osip. Zovi ih **po e-mailu ili Google Group** (Google Group je lakše za dodavanje).
   - Testeri moraju biti stvarni korisnici — daj im zadatke: "otvori mapu, nađi svoju vodu, oceni prognozu, upiši ulov".
   - Prati "Opted-in testers" broj u Console-u; ako padne pod 12, brojač se resetuje.
3. **Production** — posle odobrenja, staged rollout.

**Gde nalaziš 12+ testera:** kolege iz InMind-a, rodbina/prijatelji pecaroši, 2–3 FB grupe (post: "Tražim 15 pecaroša za beta test besplatne app za prognozu i primame — javi se u komentar"), m-fishing kontakt (prodavci/mušterije), lokalno ribolovačko udruženje.

## 1.3 Store listing — sadržaj (srpski primarni, engleski sekundarni)

**Ime aplikacije** (≤30 znakova) — najvažniji ASO faktor:
```
Upecaj! Pecanje i prognoza
```
(26 znakova; nosi brend + 2 ključne reči)

**Kratak opis** (≤80) — drugi po važnosti:
```
Prognoza za pecanje, vodostaj, primame i 795 voda u Srbiji. Offline mapa.
```

**Pun opis** (≤4000) — draft:
```
Upecaj! ti kaže kad i gde vredi izaći na vodu — i sa čime.

OCENA DANA 0–100
Za svaku vodu dobijaš ocenu uslova sa razlozima: pritisak, temperatura vode,
vodostaj, vetar, oblačnost, mesečeva faza i solunarni prozori. Prognoza po
intervalima od 3 sata, sa bonusom za zoru i sumrak.

795 VODA U SRBIJI, OFFLINE
Reke, jezera i kanali u bazi u samoj aplikaciji — radi i bez signala.
Mapa sa filterom po udaljenosti, omiljene vode, nedavno posećene.

PRAVI VODOSTAJ I TEMPERATURA VODE
Podaci sa RHMZ-a: izmerena temperatura vode i prognoza vodostaja, plus
protok. Ne procena — merenje.

PRIMAME — 80 kuriranih kombinacija
Za 20 najvećih reka i jezera, po sezonama: baza, miks, odnos, pelet i aditivi,
mamac, priprema i način hranjenja. Katalog od 44 proizvoda sa slikama.
Za ostale vode radi algoritamski predlog.

FEEDER I METHOD SAVETNIK
Predlog tehnike, montaže i dubine za date uslove.

LOVOSTAJ I PROPISI
Lovostaji, minimalne mere i zaštićena područja na jednom mestu.
(Informativno — zvaničan izvor su nadležne institucije.)

DNEVNIK ULOVA
Zapiši ulov sa tehnikom, mamcem i uslovima; statistika ti pokaže šta ti
zaista radi.

Bez reklama. Bez registracije. Napravio pecaroš, za pecaroše.

Predlog nove vode ili greška u podacima? Piši nam — dodajemo u svakoj verziji.
```

**Grafika:**
| Asset | Format | Napomena |
|---|---|---|
| Ikona | 512×512 PNG, 32-bit | imaš `assets/brand/app-icon-1024.png` → skaliraj |
| Feature graphic | 1024×500 PNG/JPG, bez alfe | logo + ribica + slogan; **bez sitnog teksta** (skalira se malo) |
| Screenshot-ovi telefon | 2–8, min 1080px kraća strana, 9:16 | vidi ispod |
| Promo video (opciono) | YouTube link | 15–30s screen recording |

**Screenshot strategija** (redosled = redosled ubeđivanja; dodaj kratak naslov iznad slike u editoru):
1. Home sa ocenom npr. 82/100 → *"Da li vredi izaći danas?"*
2. Prognoza po intervalima → *"Najbolji prozor: 18–21h"*
3. Recept za primamu → *"Šta da mešaš, u kom odnosu"*
4. Mapa sa vodama → *"795 voda, radi offline"*
5. Vodostaj/temp vode → *"Pravi podaci sa RHMZ-a"*
6. Dnevnik + statistika → *"Zapiši ulov, vidi šta radi"*

**Kategorija:** Sports (alternativa: Weather — Sports je bolji za pretragu "pecanje").
**Tags:** Fishing, Outdoors, Weather.
**Kontakt:** `upecaj.rs@gmail.com`, website = GitHub Pages landing, privacy policy URL.

## 1.4 Ostale obavezne forme
- **Content rating** (IARC upitnik) → dobiće se 3+ / PEGI 3.
- **Target audience**: 18+ (izbegava Families policy komplikacije; pecanje je odraslo).
- **Ads**: "No ads".
- **In-app purchases**: none.
- **Government apps / Financial features / Health**: none.
- **Data safety**: kako je u 0.6.
- **Countries**: Srbija + BiH, Hrvatska, Crna Gora, Sl. Makedonija, Slovenija + dijaspora (Nemačka, Austrija, Švajcarska). Praktično — pusti **sve zemlje**, jezik filtrira sam.

## 1.5 Rollout
- Prvo izdanje: **staged rollout 20%**, 48h praćenja (crash-free rate, ANR).
- Ako je crash rate < 1% → 50% → 100%.
- Uključi **"Managed publishing"** ako želiš da uskladiš objavu sa FB postovima.

---

# FAZA 2 — Beta zajednica (paralelno sa Fazom 1)

1. **Google Forms** anketa za testere: 5 pitanja (šta je zbunilo, da li je ocena tačna po tvom iskustvu, koja voda ti fali, da li bi platio, oceni 1–10).
2. **Viber ili FB Messenger grupa** "Upecaj! beta" — direktan kanal, brz feedback. Testeri koji ostanu su tvoji prvi ambasadori.
3. Traži od svakog testera: **ostavi ocenu na Play-u prvog dana launcha**. 12 ocena u prvom danu = drastično bolji rang od 0 ocena.
4. Popravi top 3 stvari iz feedback-a pre production izdanja. Ne sve — samo top 3.

---

# FAZA 3 — Launch nedelja (dan po dan)

| Dan | Akcija |
|---|---|
| D-3 | Landing page live (screenshots + Play badge + privacy). FB Page + IG profil kreirani, popunjeni (cover, opis, 3 posta unaprijed). |
| D-1 | Poruka beta testerima: "sutra izlazimo, molim ocenu". Pripremi 5 postova + 2 reels-a u draftu. |
| D0 | Production 20% rollout. Post na sopstvenoj FB Page. Post u **2 grupe** (ne više — testiraj reakciju). Poruka m-fishing-u da podele. |
| D1 | Odgovori na SVE komentare i ocene. Postavi 1. Reels/TikTok. |
| D2–D3 | Rollout 100%. Post u sledeće 3–4 grupe (rotiraj sadržaj, ne copy-paste). |
| D7 | Prvi izveštaj: instalacije, retention, top pitanja iz komentara → lista za v1.1. |

---

# FAZA 4 — Društvene mreže i plasiranje (jezgro rasta)

## 4.1 Kanali po prioritetu za srpske pecaroše

| # | Kanal | Zašto | Napor |
|---|---|---|---|
| 1 | **Facebook grupe** | Pecaroši u Srbiji žive u FB grupama; demografija 30–60, tačno tvoja publika | nizak, visok efekat |
| 2 | **Sopstvena FB Page** | dom za redovan sadržaj, deljenje iz grupa vodi tu | srednji |
| 3 | **Instagram + TikTok Reels** | mlađi feeder/method segment; algoritam još daje organski domet | srednji |
| 4 | **Viber grupe / lokalna udruženja** | hiper-lokalno, ogromno poverenje | nizak |
| 5 | **YouTube Shorts** | recikliraj iste vertikalne klipove | ~nula dodatnog |
| 6 | **Partneri (m-fishing, ribolovačke prodavnice, komercijalna jezera)** | tuđa publika, već kvalifikovana | srednji, najveći skok |
| 7 | **YouTube pecaroški kanali (influenseri)** | jedan dobar spomen = stotine instalacija | visok |
| 8 | **Forumi / portali** | dugoročan SEO, mali ali stabilan dotok | nizak |

## 4.2 Facebook grupe — kako da ne budeš banovan
Pravila igre:
- **Prvo pitaj admina** privatno: "Napravio sam besplatnu app za pecaroše, bez reklama, da li smem da podelim?" Uz "da" često dobiješ i **pinovan post**. To vredi 10 običnih postova.
- **Nikad goli link.** Post = korisna informacija, link u prvom komentaru ili na kraju.
- **Screenshot je udica.** Konkretno: "Sava kod Šapca, sutra 18–21h ocena 84 — pritisak stabilan, voda pada 4cm. Primama: bazna + crna, 1:3, pelet 2mm."
- **Odgovaraj na svaki komentar.** Kritiku uzmi javno i ozbiljno ("dodajem tu vodu u sledećoj verziji") — to je najbolja reklama.
- Ritam: **1 post na 7–10 dana po grupi**, rotiraj temu. Ne isti tekst u 6 grupa isti dan (FB to detektuje kao spam).

Tipovi grupa koje treba naći (traži po nazivu na FB):
- opšte: "Pecanje", "Ribolovci Srbije", "Sportski ribolov Srbija"
- po tehnici: "Feeder pecanje", "Method feeder", "Šaranski ribolov", "Grabljivice / spining"
- po vodi: Dunav, Sava, Tisa, Velika/Zapadna Morava, Drina, Tamiš, Begej, DTD kanali
- po jezerima: Vlasina, Perućac, Zlatar, Palić, Ludaš, Bela Crkva, Šumarice, Garaši, Borsko
- komercijalna jezera: svaka veća komercijala ima svoju grupu/Page — tu je method publika
- regionalne: Vojvodina, Šumadija, Mačva, Braničevo…

Cilj: **lista od 25–30 grupa** u tabeli (naziv, članovi, admin kontakt, datum posta, rezultat). Napravi tabelu i vodi je — to je tvoj distribucijski kanal.

## 4.3 Sadržajni motor (da ne ostaneš bez ideja)
App sam proizvodi sadržaj. 4 formata koja se ponavljaju u nedelji:

1. **"Vikend prognoza"** (čet/pet) — 3 vode sa najboljom ocenom za vikend + zašto. Screenshot iz appa.
2. **"Recept nedelje"** (sreda) — jedan kurirani combo, cela priprema. Označi m-fishing.
3. **"Ulov korisnika"** (nedelja/pon) — repost deljene kartice iz Dnevnika (uz dozvolu). Socijalni dokaz.
4. **"Znaš li"** (kad zatreba) — mikro-edukacija: kako pritisak utiče na klen, zašto pad vodostaja pokreće ribu, solunar. Bez pominjanja appa svaki put.

Sezonske kuke (upiši u kalendar — ovo su dani kad pecaroši najviše traže informacije):
- **početak i kraj lovostaja** po vrstama → post "šta sme, šta ne sme od danas" = najviše deljenja u godini
- prvi veliki **skok Dunava/Save** u proleće
- letnja vrućina → noćno pecanje, amur/tolstolobik
- jesenji **žor** — deveriika/mrena, feeder sezona
- zima → method na komercijalnim jezerima
- početak prodaje **godišnjih dozvola**

## 4.4 Reels / TikTok — format koji radi
- **9:16, 12–25 sekundi**, screen recording telefona + krupan tekst na ekranu.
- Prve 2 sekunde nose sve: *"Ne izlazi sutra na Dunav."* → pa objašnjenje.
- 3 dokazano dobre teme:
  1. "Aplikacija mi je rekla 84/100 — evo šta sam upecao" (rezultat, ne feature)
  2. "Primama za Savu u avgustu, 15 sekundi" (praktična vrednost)
  3. "Da li smeš da loviš som u maju?" (lovostaj, edukacija)
- Isti fajl objavi na TikTok + IG Reels + YT Shorts. Bez vodenog žiga druge platforme (algoritam kažnjava).
- Ritam: **2–3 klipa nedeljno** prvih mesec dana; zatim 1 nedeljno.

## 4.5 Partneri — najveći pojedinačni skok
| Partner | Ponuda njemu | Šta tražiš |
|---|---|---|
| **m-fishing** (deal već postoji) | app vodi kupce direktno na njihove proizvode; besplatan promo njihovog kataloga | post na njihovoj FB/IG strani, mejl newsletter, QR kod na pultu/paketima |
| Ribolovačke prodavnice (lokalne) | besplatan promo njihovih artikala u budućim receptima | nalepnica/flajer sa QR kodom kod kase |
| Komercijalna method jezera | app im dovodi pecaroše, oni dobiju svoj profil u appu (modul iz roadmap-a #9) | QR kod na tabli/ulazu, post u njihovoj grupi |
| Ribolovačka udruženja / savez | app širi informacije o lovostaju i propisima | spomen na sajtu/FB, distribucija uz dozvole |
| Pecaroški YouTuberi/IG (5–50k) | ekskluzivan sadržaj: nazovi jedan recept po njihovom kanalu, rani pristup novoj verziji | 30s spomen u videu ili story |

Pristup influenserima — kratak DM, bez korporativnog tona:
> "Zdravo, napravio sam besplatnu app za pecaroše u Srbiji — prognoza uslova, vodostaj sa RHMZ-a i recepti za primame po vodi i sezoni. Bez reklama, ne prodajem ništa. Ako ti se učini korisno, poslao bih ti pristup da probaš — a mogu i da po tvom kanalu nazovem jedan recept. Bez obaveze."

QR kod: generiši Play link kao QR, stavi na landing page da partneri mogu sami da štampaju.

## 4.6 Petlja rasta (ovo je razlika između 200 i 5.000 instalacija)
```
korisnik upiše ulov → deli karticu sa logotipom na FB grupu
     → grupa vidi socijalni dokaz + brend → instalira → upiše svoj ulov → ...
```
Zato je "deljenje ulova kao slika" (0.10.1) prioritet nad svim ostalim feature-ima za rast. Dodaj i:
- **"Predloži vodu"** formu u appu → korisnici sami dopunjuju bazu (795 → hiljade) i vezuju se za proizvod.
- **"Podeli prognozu"** — tekstualna kartica dana, spremna za paste u grupu.

## 4.7 ASO — održavanje
- Ključne reči idu u **ime + kratak opis** (najveća težina), pa u pun opis prirodno: *pecanje, ribolov, prognoza, vodostaj, primama, feeder, method, šaran, som, deverika, lovostaj, Dunav, Sava, Tisa, Morava*.
- **Odgovaraj na svaku ocenu** — Play to meri, a i podiže konverziju.
- **Ažuriraj app svakih 2–4 nedelje** — svežina utiče na rang i vraća korisnike (What's new na srpskom, ljudskim jezikom: "Dodato 40 novih voda, ispravljen lovostaj za soma").
- Prati u Console-u: **store listing conversion rate**, uninstall rate, D1/D7/D30 retention, top zemlje. Ako je konverzija < 15%, problem su screenshot-ovi/ikona, ne saobraćaj.

---

# FAZA 5 — Posle launcha, ritam rada

**Nedeljno:** 3–4 posta + 2 klipa; odgovori na sve ocene/komentare; zapiši tražene vode i bug-ove.
**Dvonedeljno:** izdanje sa 1 vidljivim poboljšanjem + popravkama; objavi changelog u grupama ("po vašoj molbi dodato…") — to ubedljivo vraća ljude.
**Mesečno:** pregled metrika, 1 novi partner, 1 sezonska kampanja.

Prvi kandidati za v1.1–v1.3 (iz postojećeg roadmap-a, poređani po efektu na rast, ne po tehničkoj lepoti):
1. Deljenje ulova kao slika (rast) · 2. Onboarding + Settings (retention) · 3. Push "feeder prozor" za omiljene vode (najjača kuka za vraćanje) · 4. Verifikovani Traper recepti (poverenje) · 5. Foto ulova (angažman) · 6. Širenje kuriranih combo-a na 40+ voda (pokrivenost).

---

# Kontrolna lista (redom)

**Tehnički**
- [x] `applicationId` = `rs.upecaj.app` + `namespace` + Kotlin paket + `userAgentPackageName` (2 mesta)
- [x] release signingConfig + `key.properties.example` + `.gitignore` (kod spreman, signing put testiran)
- [ ] **Generiši svoj keystore** (`keytool`), popuni `android/key.properties`, backup ključa na 2 mesta
- [x] `minSdk 24` / `targetSdk 36` / `compileSdk 36` pinovani
- [x] OSM atribucija (`OsmAttribution`) na mapi i method ekranu
- [x] Slike primama rekompresovane (12 MB → 2.7 MB)
- [ ] (opciono, v1.1) PDF katalog na remote → -23 MB
- [x] Disclaimer na lovostaj/propise ekranu (već postojao)
- [ ] Označeno "heuristika vs verifikovano" na receptima
- [x] `flutter analyze` clean · `flutter build appbundle --release` prolazi (81.2 MB AAB)
- [ ] Ručni prolaz light/dark + prazna stanja na telefonu (uključi novi OSM potpis na mapi)
- [ ] Deljenje ulova kao slika · in-app review prompt · onboarding
- [ ] `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`
- [x] Merged manifest proveren — samo 3 dozvole, nema `READ_MEDIA_IMAGES`

**Pravno / sadržaj**
- [ ] Pisana potvrda od vlasnika m-fishinga (tekst u `docs/legal/DOZVOLE.md`)
- [ ] Potvrdu arhiviraj kao PDF/screenshot u `docs/legal/`
- [x] Privacy policy + landing napisani (`site/`)
- [ ] Objavi `site/` na GitHub Pages, zameni `PLAY_URL` po izlasku
- [ ] Screenshot-ovi u `site/img/` + QR kod Play linka na landingu
- [x] Javni e-mail za podršku — `upecaj.rs@gmail.com`

**Play Console**
- [ ] Račun + $25 + **verifikacija identiteta pokrenuta prvog dana**
- [ ] App kreiran, listing (ime/kratak/pun opis) popunjen
- [ ] Ikona 512, feature graphic 1024×500, 6 screenshot-ova
- [ ] Data safety, content rating, target audience 18+, ads: no
- [ ] Internal testing → pre-launch report čist
- [ ] **Closed testing: 12+ testera opted-in, 14 dana neprekidno**
- [ ] Apply for production → odobreno
- [ ] Staged rollout 20% → 100%

**Distribucija**
- [ ] Tabela 25–30 FB grupa (naziv/članovi/admin/datum/rezultat)
- [ ] FB Page + IG + TikTok profili, 3 posta unaprijed
- [ ] Adminima 5 grupa poslata molba za dozvolu/pin
- [ ] m-fishing zamoljen za post/newsletter/QR na pultu
- [ ] 5 influensera kontaktirano
- [ ] Sadržajni kalendar za 4 nedelje + sezonske kuke upisane

---

## Šta može da ode naopako (i šta uraditi)

| Rizik | Verovatnoća | Odgovor |
|---|---|---|
| Verifikacija identiteta se oduži | srednja | pokreni prvog dana, radi Fazu 0 paralelno |
| Ne skupi 12 testera → nema production pristupa | **visoka** | zovi 20+; oglas u grupama u N1, ne u N3 |
| Ban u FB grupi zbog "reklame" | srednja | pitaj admina prvo, link u komentaru, sadržaj > promocija |
| Pogrešan lovostaj → besna reakcija | niska/velika šteta | disclaimer + hitno izdanje + javno izvinjenje u grupi |
| OSM blokira tile-ove zbog saobraćaja/atribucije | niska | atribucija + ispravan UA; plan B: MapTiler/Thunderforest free tier |
| App odbijen zbog Data safety neslaganja | niska | formu popuni tačno; bez analytics SDK-ova nema šta da promašiš |
| Velika instalacija odbija korisnike | niska (posle -8 MB) | slike već smanjene; ako Play prikaže > 40 MB download → PDF na remote (v1.1) |
| Loš D1 retention (nema onboardinga) | srednja | onboarding pre launcha, ne posle |
