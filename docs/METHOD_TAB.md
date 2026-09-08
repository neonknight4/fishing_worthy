# Method tab — plan i ideje

> **ODLUKA 2026-09-08: Method tab je ukinut.** Mapa komercijalnih revira je
> spojena sa glavnom Mapom (čip filter „Method"; reviri stoje i na „Sve"), a
> škola je dobila svoj tab (`lib/screens/school_screen.dart`,
> sadržaj u `lib/data/school_lessons.dart`). Sekcije 2, 3 i 6 ovog dokumenta
> su ušle u lekcije; sekcije 4 i 5 su i dalje otvorene.
> Bottom-nav: Početna · Mapa · Škola · Traper · Dnevnik.

> Radni plan za Method tab. Datum: 2026-07-27.
> Vezano: `docs/PROJECT_STATUS.md`, memory `future-commercial-lakes`, `docs/research/2026-06-25-bait-research.md`.

## Vizija
Method tab = **vodič za method/feeder lov + mapa komercijalnih revira**. Tvoja centralna ideja: mapa Srbije sa komercijalnim (plaćenim) method jezerima gde se peca šaran/amur.

---

## 1. 🗺 Mapa komercijalnih revira ⭐ (centar taba)
Mapa Srbije, pinovi = komercijalna/plaćena method jezera. Tap → detalj:
- naziv, grad/region, koordinate
- ciljne vrste (šaran / amur / tolstolobik / som)
- dubina, broj sektora/pegova
- cena dnevne dozvole (RSD), radno vreme
- pravila (no-kill / kg limit / dozvoljene tehnike)
- kontakt (telefon / Instagram / FB / sajt)
- (opciono) skor uslova za lokaciju — koristi postojeći forecast engine

**Podaci:** kuriran `assets/data/commercial_lakes.json` (poseban tip vode, uz reke/prirodna jezera).
Model (predlog):
```json
{
  "name": "…", "city": "…", "region": "…",
  "lat": 0.0, "lon": 0.0,
  "species": ["saran","amur"],
  "method": true,
  "depthM": "1.5–3", "sectors": 12,
  "permitRsd": 1500, "hours": "00–24",
  "rules": "no-kill preko 5kg; …",
  "contact": "+381…", "link": "https://…",
  "confidence": "verified|single|unsure"
}
```
> Podaci se istražuju (web) → `docs/METHOD_REVIRI.md` na pregled pre ubacivanja. NE izmišljati revire.

---

## 2. 📖 Method škola (iz istraživanja — verifikovano)
- **Mešanje:** dodavaj vodu malo-po-malo dok ne postane vlažno/teško (ne sve odjednom).
- Cilj smeše: **veže za zabačaj → raspadne na dnu** (⚠ ne "maksimalno suvo" — sporno).
- **Broj punjenja po temp:** hladno/zima 2–3 mala; toplo više/češće.
- **Traper Method linija:** GST Method (high-protein), READY (pre-vlažen), Pellet 2mm (vezuje), Pop-Up Dumbells (hookbait) — native veza sa Traper tabom.
- **Hookbait izbor:** bottom / wafter / pop-up po dnu (mulj → pop-up).

## 3. 🎣 Montaže (rigs)
Vizuelne kartice: inline vs free-running method, dužina hair-a, udica po mamcu, Ronnie/spinner za pop-up, safety montaža (riba ne vuče feeder ako pukne).

## 4. ⚡ "Method za danas" (kontekst)
Ako je izabrana voda → povuci postojeći `technique_advisor` method plan (feeder težina, količina, kadenca). Veže Method tab za živu prognozu.

## 5. 🐟 Ciljne vrste — šaran / amur
Method specifika po vrsti (temp, sezona, ponašanje na dnu). Iz planiranog carp/amur istraživanja.

---

## 6. 🎓 ŠKOLICA — škola ribolova (nova ideja, 2026-07-27)
Poseban tab ili segment: **škola feeder pecanja + ribolova uopšte**. Edukativni, korisno za početnike.
Predlog sadržaja (lekcije/kartice):
- **Osnove:** oprema (štap/rolna/najlon), čvorovi, postavljanje pribora.
- **Feeder ABC:** vrste hranilica (cage/open-end/method), kada koja, težine, montaže.
- **Primama 101:** mešanje, arome, boje, vezivanje, seckanje mamca.
- **Čitanje vode:** dubina, dno, gde je riba, uticaj vremena (veže se na naš skor).
- **Po vrstama:** deverika/šaran/amur — gde, kada, čime.
- **Bonton i zakon:** lovostaj, mere, no-kill, čuvanje ribe.
- **Video/ilustracije** (opciono kasnije).

Odluka: da li **zaseban tab** (pa nav ide na 6 → previše, treba reorg) ili **segment unutar Method taba** (npr. "Škola" sekcija). Preporuka: segment/sekcija u Method tabu ili ulaz iz Home "Alati", ne novi tab.

---

## Redosled (dogovoreno)
1. **Mapa revira** — skelet (model + ekran + JSON), pa puni pravim podacima kad istraživanje potvrdi.
2. Method škola + montaže (bez čekanja podataka).
3. Kontekst "method za danas".
4. Ciljne vrste.
5. Školica (segment) — kasnije.
