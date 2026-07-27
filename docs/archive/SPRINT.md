# Upecaj! — Sprint plan

> **AŽURIRANJE 2026-07-24:** Živa mapa puta je prešla u **`docs/PROJECT_STATUS.md`**.
> Ovaj fajl je originalni Traper-coach/pop-up plan. Status ukratko:
> - **SPRINT 1 (groundbait coach)** — isporučeno kroz kurirane `WaterCombo` (priprema + hranjenje
>   u "Kako pripremiti" collapsible na Traper kartici). ✅ suštinski done (bez zasebnog timera 1.5).
> - **SPRINT 2 (pop-up/wafter)** — ⬜ nije rađeno (blokira verifikacija pravila S0.1/S0.2).
> - **SPRINT 3 (dnevnik inteligencija)** — ⬜ nije rađeno.
> - **SPRINT 4 (cast-test / notif / Mohseni)** — ⬜ nije rađeno.
> - Uz to, van ovog plana: pun **redizajn (light+dark) + rename "Upecaj!" + bottom nav + logo**.
>
> Detalji + prioriteti + moji predlozi → `docs/PROJECT_STATUS.md`.

---

> Izvor: `docs/UPGRADE_IDEAS_2.md` (deep research #2) + zaostalo iz `docs/UPGRADE_IDEAS.md`.
> Redosled po vrednosti + zavisnosti. Svaki task: **šta · fajlovi · acceptance · trud (S/M/L)**.
> Oznake pouzdanosti pravila: ✓ verifikovano · ~ sourced/neverif · ⚠ sporno (ne tvrdo pravilo).

Legenda statusa: ⬜ todo · 🔄 u toku · ✅ done

---

## SPRINT 0 — Priprema (pre kodiranja)

| # | Task | Acceptance | Trud |
|---|---|---|---|
| 0.1 | ⬜ Re-run verify pass deep-research (limit resetovan) da očvrsne pop-up/loading pravila (3.x, ~abstain). | Pop-up + loading tvrdnje imaju 2/3 glasa ili eksplicitno označene "heuristika". | S |
| 0.2 | ⬜ Potvrda Traper SKU/aroma liste (carpmania/m-fishing) za pop-up Dumbells boje/arome. | Lista SKU (ime, boja, aroma, slika) spremna za `traper_baits.dart`. | S |

> 0.1 nije blocker za Sprint 1 (groundbait coach je ✓ verifikovan). Blokira Sprint 2 (pop-up).

---

## SPRINT 1 — Groundbait "mixing coach" + loading  🎯 najveći trust dobitak

**Cilj:** ispod postojeće Traper combo kartice dodati collapsible "Kako pripremiti" + koliko hraniti.
Sve content + UI, **0 nove infrastrukture**. Sva pravila ovde su ✓ verifikovana.

| # | Task | Fajlovi | Acceptance | Trud |
|---|---|---|---|---|
| 1.1 | ⬜ Model `PrepGuide` (koraci, voda:smesa ratio, test stiska, dodaci redosled). | `lib/models/feeder_plan.dart` ili novi `lib/models/prep_guide.dart` | Model drži korake + napomene; const-friendly. | S |
| 1.2 | ⬜ Logika koraka po proizvodu/tehnici: READY = skip mešanje; suva GST = pun flow; konzistencija po venue+temp (⚠ ne "max suvo"). | `lib/logic/bait_recommender.dart` (proširi `BaitCombo` ili dodaj `prep`) | `recommend()` vraća `PrepGuide` za izabrani combo; READY grana kraća. | M |
| 1.3 | ⬜ Loading kalkulator (N3): startni broj hranilica + dopuna interval po temp pojasu / venueType / vrsti. ~ stajaćak toplo 7–8 + ~na sat; hladno 2–3 mali feeder; reka stalan ritam. | `lib/logic/bait_recommender.dart` ili `technique_advisor.dart` | Vraća `{startCount, refillMin}`; menja se sa temp i venue. | S |
| 1.4 | ⬜ UI: collapsible "Kako pripremiti" u `_TraperComboCard` — koraci 1–4, voda:smesa, dodaci, seckanje crva (fino/krupno po turbidity ✓), loading red. | `lib/screens/result_screen.dart` (`_TraperComboCard`) | Sekcija se expand/collapse; tekst se menja po combo/uslovima; nema overflow. | M |
| 1.5 | ⬜ ⏱ Timer dugme za 20–30 min odmaranje (lokalni countdown, opcioni notif). | `result_screen.dart` (+ `flutter_local_notifications` ako notif) | Dugme starta countdown; bez notifa radi in-app; sa notifom traži dozvolu. | S-M |

**Sprint 1 verify:** `flutter analyze` clean · ručni trace: combo → prep koraci tačni za GST vs READY · loading se menja hladno↔toplo.

---

## SPRINT 2 — Pop-up / wafter recommender grana

**Cilj:** dodati hookbait izlaz (bottom/wafter/pop-up) uz groundbait combo. **Zavisi od 0.1 + 0.2.**
Pravila su ~ (reputabilni izvori, neverif) → kodirati kao heuristiku, jasno označiti.

| # | Task | Fajlovi | Acceptance | Trud |
|---|---|---|---|---|
| 2.1 | ⬜ Model `HookbaitRec { type, sizeMm, color, flavorProfile, productSku? }`. | `lib/models/bait_product.dart` ili novi | Enum `HookbaitType{bottom,wafter,popUp}`; polja popunjena. | S |
| 2.2 | ⬜ Input `bottomType` (silt/gravel/firm/weed); default po venueType (lake→silt-prone, river→firm). | `lib/logic/bait_recommender.dart` | `recommend()` prima `bottomType` (opciono); default mapiran. | S |
| 2.3 | ⬜ Logika izbora tipa: čisto dno→bottom; method default→wafter; mulj/korov/hladno→pop-up (1–3" gore). | `lib/logic/bait_recommender.dart` | Tabela 3.1 iz UPGRADE_IDEAS_2 kodirana; deterministički izlaz. | M |
| 2.4 | ⬜ Veličina/boja/aroma po temp+turbidity+vrsti (13–14mm solo / 8–10mm dumbell; bistro=washed, mutno=jarka; hladno=fruity, toplo=fishmeal). | `lib/logic/bait_recommender.dart` | §3.2 pravila; izlaz konzistentan po uslovima. | M |
| 2.5 | ⬜ Map na Traper Pop Up Dumbells SKU (iz 0.2). | `lib/data/traper_baits.dart` | `productSku` razrešen na konkretan Dumbell (slika/aroma). | S |
| 2.6 | ⬜ UI kartica "HOOKBAIT" ispod combo-a, ista šema (slika + razlozi + rig napomena). | `result_screen.dart` | Prikazuje tip+veličinu+boju+aromu + kratak rig hint; errorBuilder na slici. | M |
| 2.7 | ⬜ Rig hint po tipu (method 10–12 udica kratak hair; pop-up balans putty/shot Ronnie; zig dug podvez). | `result_screen.dart` / `technique_advisor.dart` | Tekst se menja po hookbait tipu. | S |

**Sprint 2 verify:** `flutter analyze` clean · trace: lake+silt→pop-up jarka; river+firm bistro→bottom washed; method→wafter · SKU razrešen.

---

## SPRINT 3 — Dnevnik inteligencija

**Cilj:** pretvoriti dnevnik u lični savetnik (gradi na `diary_stats`).

| # | Task | Fajlovi | Acceptance | Trud |
|---|---|---|---|---|
| 3.1 | ⬜ N6 "Slične sesije": kad današnji uslovi ≈ prošloj uspešnoj → predlog iste taktike/primame. | `lib/services/diary_service.dart`, `result_screen.dart` | Match po temp pojas+nivo trend+pritisak; prikaže link na tu sesiju. | M |
| 3.2 | ⬜ N5 Foto ulova + auto-tag trenutnih uslova (temp/nivo/pritisak već hvatamo). | `diary_entry.dart`, `diary_service.dart` (DB v3 migrate), `diary_entry_screen.dart` | Foto path u DB; migracija aditivna; uslovi auto-popunjeni. | M |
| 3.3 | ⬜ N7 Sezonski "šta sad radi" briefing po izabranoj vodi (statički content + temp gate). | novi `lib/data/seasonal_briefing.dart`, `result_screen.dart` | Kratak tekst po mesecu+vrsti aktivnoj; menja se sezonom. | S-M |

**Sprint 3 verify:** DB migracija ne ruši staru bazu (test upgrade v2→v3) · `flutter analyze` clean.

---

## SPRINT 4 — Zaostalo iz v1 + cast-test + hardening

| # | Task | Fajlovi | Acceptance | Trud |
|---|---|---|---|---|
| 4.1 | ⬜ N4 Cast-test helper: reka feeder težina kao opseg 2–6oz + uputstvo (✓), umesto fiksne vrednosti. | `technique_advisor.dart`, `result_screen.dart` (feeder rig kartica) | Prikazuje opseg + "proveri da stoji"; bez tvrde jedne vrednosti. | S |
| 4.2 | ⬜ ⚠ Feeder tip na reci kao **opcija** (cage/open-end), ne tvrdo pravilo (izvori sporni 1-2). | `technique_advisor.dart` | Prikaz oba sa kratkim trade-off, ne forsira jedan. | S |
| 4.3 | ⬜ B4 (v1) Notifikacije "feeder prozor" — background check nivo+pritisak+temp za omiljene vode. | novi `lib/services/notif_service.dart` (+ `workmanager`) | Push kad se poklope uslovi; dozvole UX; off po defaultu. | L |
| 4.4 | ⬜ B2 (v1) Mohseni air→water model — traži kalibracione podatke (odluka, ne čista izmena). | `weather_data.dart` | Odložiti dok nema trening serija; ostaje ⏳. | L |

**Sprint 4 verify:** notifikacije ručno okinute u test modu · `flutter analyze` clean.

---

## Pregled redosleda / zavisnosti

```
S0 (priprema) ──┬─> S1 (groundbait coach)   [nezavisan, kreni odmah]
                └─> S2 (pop-up)              [blokira ga 0.1 + 0.2]
S1, S2 ─────────> S3 (dnevnik)               [nezavisan od S1/S2, može paralelno]
                  S4 (zaostalo)              [zadnje / po želji]
```

**Preporuka:** kreni **S1** odmah (verifikovano, najveći trust, 0 infra). Paralelno **S0.1/S0.2**
da otključaš S2. S3 može kad god. S4 (notifikacije/Mohseni) zahteva infra/odluku — zadnje.

## Definicija "Done" (svaki task)
- `flutter analyze` → No issues found.
- Ručni trace kroz call chain (servlet/bean → logic → UI nije relevantno; ovde: recommend/advisor → kartica).
- Pravila označena ✓/~/⚠ u kodu komentarom gde je heuristika (~) ili sporno (⚠).
- Nema regresije postojećih kartica (combo, feeder plan, vodostaj).
