# FishingWorthy — Upgrade ideje v2 (Traper prezentacija + pop-up + nove feature)

> Deliverable iz deep research sesije #2 (2026-06-25). Fokus po zahtevu:
> (1) nove feature korisne pecarošima, (2) bolja prezentacija Traper hrane,
> (3) pop-up / wafter mamci kao recommender grana.
>
> **Napomena o pouzdanosti:** research verify faza prekinuta na session limitu, pa je
> sinteza ručna. Oznake:
> - ✓ = adversarijalno verifikovano (3-0 / 2-0 glasova)
> - ~ = iz reputabilnog izvora ali verify nije stigao (3 abstain)
> - ⚠ = izvori se **ne slažu** → ne kodirati kao tvrdo pravilo, prikazati kao opciju
>
> Izvori: tackleguru, Angling Times, Match Fishing Magazine (Darren Cox), Korda, DNA Baits,
> Fjuka, badangling, **feeder.rs**, **carpmania.co.rs** (Traper SR cenovnik), prakticni-ribolov.

---

## DEO 1 — Nove feature (gap vs konkurencija)

Konkurencija (BassForecast, Fishbox, Deeper, Fishbrain, MyCatch) = bass/lure + weather score +
catch-log + bathymetry. **Niko** ne radi: groundbait mix uputstvo vezano za uslove, pop-up logiku,
ni river-hidrologiju za coarse/feeder. To je već naša prednost — širi je dalje.

### Tier A — brzi, grade na postojećem

**N1. Groundbait "mixing coach" (najjači novi diferencijator)** — vidi DEO 2.
Korak-po-korak mešanje za preporučenu Traper smešu. Niko ovo nema u app-u. V: vrlo visok · T: M

**N2. Pop-up / wafter recommender grana** — vidi DEO 3. Dopuna postojećem `bait_recommender`.
V: visok · T: M

**N3. Feeder loading kalkulator (koliko hraniti)**
- *Šta:* "Početno X hranilica, pa dopuna svakih Y min" — broj zavisi od temp pojasa, tipa vode, vrste.
- *Pravila (~ norfolkfishingblog):* stajaćak/deverika toplo = **7–8 hranilica startno**, dopuna ~na sat;
  hladno/zima = **mali feeder + samo 2–3 hranilice** startno, retko dopunjavanje. Reka = manja
  zavisnost (struja raznosi) → stalan ritam umesto velikog starta.
- *Kako:* čista on-device logika, reuse temp pojas + venueType + cadence iz `technique_advisor`.
- V: visok · T: S

**N4. "Cast test" feeder težina pomoćnik (reka)** ✓
- *Šta:* umesto fiksne težine — uputstvo: "Probaj Ng, zabaci, proveri da hranilica **stoji** na dnu;
  ako je nosi struja → teža." Opseg **2–6 oz (≈60–170g)** za jaku reku. *(Angling Times, ✓3-0)*
- *Kako:* tekstualni helper + opseg umesto jedne vrednosti u feeder rig kartici.
- V: srednji · T: S

### Tier B — srednje

**N5. Catch-log foto + auto EXIF uslovi**
- Fotka ulova + auto-tag trenutnih uslova (temp/nivo/pritisak već hvatamo). Konkurencija ima foto-log;
  mi dodajemo auto-uslove povrh. V: srednji · T: M

**N6. "Slične sesije" iz dnevnika**
- Kad su današnji uslovi ≈ prošloj uspešnoj sesiji → "Sлично 14.5. kad si uhvatio deveriku na
  padajućem nivou — probaj istu primamu." Gradi na `diary_stats`. V: visok · T: M

**N7. Sezonski "šta sad radi" feed po reci**
- Kratki sezonski briefing po izabranoj vodi (koja vrsta aktivna, tipična taktika za mesec).
  Statičan content + temp gate. V: srednji · T: S-M

### NE raditi (potvrđeno kao paid/hardware gap konkurencije)
- Bathymetry / sonar mape (Navionics/Deeper) — paid feed ili hardver.
- Sea-surface temp overlay — ocean, neupotrebljivo za nas.

---

## DEO 2 — Bolja prezentacija Traper hrane (groundbait coach)

Trenutno recommender daje **šta** (proizvod + ratio). Fali **kako** — to gradi poverenje i čini
preporuku akcionom. Dodati expandable "Kako pripremiti" sekciju ispod combo kartice.

### 2.1 Verifikovani koraci mešanja (univerzalno) ✓

1. **Voda malo-pa-malo** ("little and often"), ne sve odjednom, dok smeša ne postane vlažna i teža. *(tackleguru ✓3-0)*
2. **Odmaranje 20–30 min** da upije vodu pre upotrebe. *(tackleguru ✓3-0)*
   → UX trik (~anglingdirect): smešaj **prvo po dolasku**, neka odmara dok postavljaš pribor.
3. **Sejanje kroz sito (riddle)** posle odmaranja → uklanja grudve, smeša "pufnasta" i ujednačena. *(tackleguru ✓3-0)*
4. **Test stiska (~anglingdirect):** stisni šaku — treba da se veže ali da se mrvi kad gurneš palcem.

### 2.2 Konzistencija po tehnici (codeable)

```
KONZISTENCIJA(venue, technique, temp):
  RIVER open-end/cage → vlažnija, da se veže i izdrži zabačaj + dno; "drži pa se otvara"
  RIVER bistra/spora → suvlja, brži raspad oblaka
  METHOD/FLAT → mora se vezati za feeder i preživeti zabačaj, pa se otvoriti na dnu
       ⚠ NE praviti "tako suvo da jedva drži" — sporno (1-2 opovrgnuto); cilj je
         vezivanje za cast + raspad na dnu, ne maksimalno suvo.
  + hladna voda → suvlja, manje lepljiva, manje hrane (inertna)
  + topla voda → može vlažnija/aktivnija, više peleta
```

### 2.3 River bream ratio (Darren Cox) ✓
- **2:1 baza** (dve smeše : jedna), namerno **suvlja** jer živi/mokri dodaci (dead reds, casteri,
  **sečeni crv**) sami unose vlagu. *(Match Fishing ✓3-0)*
- **Sečeni crv ključan u mutnoj/obojenoj vodi** — jak miris. Finoća sečenja = regulator:
  **fino seckano = privlači**, **krupnije = zadržava** ribu. *(✓2-0)* → ovo je odlično UI pravilo:
  prikaži "kako seckati crva" po turbidity-ju.

### 2.4 Predlog UI (Traper combo kartica → expand "Priprema")

```
┌ TRAPER COMBO (postojeće: proizvodi + ratio + razlozi) ┐
│  ▸ Kako pripremiti (novo, collapsible)                │
│    1. Sito + voda malo-pa-malo → vlažno, teže         │
│    2. Odmori 20–30 min  [⏱ taймer dugme]              │
│    3. Prosej kroz sito                                 │
│    4. Test stiska: veže se, mrvi pod palcem           │
│    • Voda:smesa ≈ <ratio po temp>                     │
│    • Dodaci po redu: <pelet/kukuruz/sečeni crv>       │
│    • Seckaj crva: <fino=privuci / krupno=zadrži>      │
│    • Hrani: <N startnih hranilica, dopuna /Y min>     │
└────────────────────────────────────────────────────────┘
```
- **⏱ Taймer dugme** za 20–30 min odmaranja = mala feature, veliki "trust" efekat.
- **Loading red** spaja N3 (koliko hraniti) direktno u karticu.
- Sve tekst/ikonice, bez nove infrastrukture.

### 2.5 Traper mapiranje (carpmania.co.rs cenovnik) ✓
| Proizvod | Uloga | Napomena |
|---|---|---|
| **GST Method 1kg** | method baza | high-protein, **treba malo vode** → naglasi u coach-u |
| **READY 0.75kg** | pre-vlažena | ready-to-use → preskoči korake 1–3, "samo napuni feeder" |
| **Pellet 2mm** | vezivo/sporo otpuštanje | dobro se vezuje, sporo se rastvara |
| **Pop Up Dumbells 8–10mm** | hookbait | više aroma/boja → DEO 3 |

→ Coach treba da **grana po proizvodu**: READY = drugačiji (kraći) flow nego suva GST baza.

---

## DEO 3 — Pop-up / wafter recommender (nova grana)

### 3.1 Kada koji (codeable odluka)

```
HOOKBAIT_TIP(bottomType, species, temp, turbidity):
  BOTTOM BAIT (tone)   → čisto/tvrdo dno (šljunak, glina), riba sigurno na dnu, bistro
  WAFTER (neutralan)   → DEFAULT na method/flat; uravnotežen, "usisava se" lako,
                         dobar preko tankog mulja, oprezna riba (deverika, F1)
  POP-UP (pluta)       → mulj/korov/debris (~badangling, Korda): diže mamac 1–3" iznad
                         dna da se vidi/ne utone; hladna voda + mala aktivnost (single
                         bright nad praznim dnom); zig-style za ribu u sloju vode
```
*(Korda ~: pop-up prezentuje mamac iznad dna preko mulja/korova, tipično 1–3 inča gore.)*

### 3.2 Veličina / boja / aroma (codeable)

```
SIZE:
  pop-up solo            → 13–14mm (~Korda)
  method/flat dumbell    → 8–10mm (Traper Dumbells opseg ✓)
  oprezna/sitnija riba   → manji 6–8mm wafter

BOJA:
  bistra voda / oprezno  → "washed out" / prirodna, match-the-freebies
  mutna/obojena/hladno   → jarka (žuta/roze/bela), high-vis "single"  (~Korda: bright ILI match)
  mulj                   → fluoro da se vidi iznad tamnog dna

AROMA:
  hladno  (<10°C)        → low-oil, fruity/sweet, washed (sporije otpuštanje)
  toplo   (>16°C)        → fishmeal/spice/visok oil, jak signal
  mutno                  → jača aroma bez obzira na temp (kompenzuje vidljivost)
```

### 3.3 Rig implikacije (~Korda)

```
balansiranje: pop-up = putty/shot/tungsten da tone sporo i "usisava se";
              wafter = sam po sebi gotovo neutralan, minimalan balans
hair/hook:    method 8–10mm → udica 10–12, kratak hair (mamac uz olovo)
              pop-up Ronnie/spinner-style → counterbalance obavezan
              zig (riba u sloju) → dugačak podvez do dubine ribe
```

### 3.4 Traper mapiranje
- **Pop Up Dumbells 8–10mm** (više aroma/boja, 459–549 RSD ✓) = direktan kandidat za hookbait izlaz.
- Recommender izlaz: `{tip: wafter|popup|bottom, velicina, boja, aroma}` → preslikaj na konkretan
  Traper Dumbell SKU (boja/aroma) kao što već radimo za groundbait.

### 3.5 Integracija u kod
- Proširiti `BaitCombo` modelom `HookbaitRec { type, sizeMm, color, flavorProfile, productSku? }`.
- `BaitRecommender.recommend(...)` već prima temp/turbidity/species/waterBody → dodati `bottomType`
  (novi input; default po venueType: lake→silt-prone, river→gravel/firm) i vratiti `hookbait`.
- Nova mala kartica "HOOKBAIT" ispod groundbait combo-a, ista vizuelna šema (slika + razlozi).

---

## Redosled implementacije (predlog)
1. **DEO 2 groundbait coach** (N1) — najveći trust dobitak, čist content+UI, 0 nove infra.
2. **N3 loading kalkulator** — mala logika, uklapa se u istu karticu.
3. **DEO 3 hookbait/pop-up grana** (N2) — proširenje recommender-a, novi model.
4. **N4 cast-test helper** (reka feeder težina) — tekstualni.
5. **N6 "slične sesije"** iz dnevnika — kad bude vremena.

> ⚠ Otvoreno (research nedovršen — verify pao na limitu): tip feeder-a na reci (cage vs open-end)
> **sporan** u izvorima → ostaviti kao korisničku opciju, ne tvrdo pravilo. Pop-up/wafter detaljna
> pravila (3.x) iz reputabilnih izvora ali NEVERIFIKOVANA — pre kodiranja preporučujem ponovni
> verify pass (limit se resetuje), ili potvrda od Traper/lokalnog match ribolovca.
