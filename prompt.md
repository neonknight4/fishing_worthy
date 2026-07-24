# Prompt za redizajn — "Upecaj!"

Redizajniraj mobilnu aplikaciju "Upecaj!" — pomažeš srpskim ribolovcima da odluče
da li i kako danas da pecaju (feeder/method/dubinski lov na belu ribu i šarana).
Aplikacija je na srpskom (latinica), mobile-first (Flutter, Android), data-gusta.

## BREND (fiksno, ne menjaj)
- Ime / wordmark: "Upecaj!" (imperativ, sa uzvičnikom kao delom logotipa)
- Logo: ribica u tamno zelenoj boji (deep green, ~#1D5A33 kao polazna)
- Tema mora da vodi tamno zelenom kao primarnom brend bojom; voda/plava sme kao
  sekundarni akcenat jer je domen ribolov na vodi

## TVOJ ZADATAK (kreativni pravac je NA TEBI)
Ti odlučuješ celokupnu estetiku — predloži je i obrazloži u par rečenica
(npr. moderan outdoor, minimal, dark dashboard...). Zatim izgradi kompletan
vizuelni sistem: paleta (light + dark), tipografija, mreža/razmaci, ikonografija,
i biblioteka komponenti (kartice, dugmad, čipovi, merači/gauge, liste, tabovi).
Sve mora da radi i u light i u dark modu.

## PRINCIPI
Čitljivost gustih podataka na malom ekranu; brend zelena dosledno; prijatno palcu
(touch targets); jasna hijerarhija "najvažnije danas" → detalji.

## STRANICE ZA DIZAJN
Svaka kao mobilni mockup + stanja (prazno/loading gde ima smisla).

### 1. POČETNA
- Logo "Upecaj!" + ribica. Velika CTA: "Gde pecaš danas?"
- Dugme lokacija (GPS) + pretraga vode po imenu
- Omiljene vode (kartice), skorije pretrage
- Ulaz u: mapu, dnevnik, propise/lovostaj

### 2. REZULTAT (glavni ekran, najvažniji)
- Veliki "score" 0–100 sa ocenom (npr. odlično/dobro/loše) — hero merač
- Pločice uslova: temp vazduha, pritisak (mbar), vetar, oblačnost, padavine,
  temperatura vode
- Lista faktora: pozitivni (+) i negativni (–) razlozi za skor
- "TEHNIKE ZA DANAS" — preporučene tehnike
- "FEEDER/METHOD PLAN" — plan hranjenja
- "KURIRANA TRAPER KOMBINACIJA" — brendirana kartica proizvoda (2–4 proizvoda
  sa sličicom, ulogom BAZA/DODATAK, odnosom miksa), čip ciljnih vrsta, mamac,
  collapsible "Kako pripremiti i hraniti", link "Kupi na m-fishing.rs"
- "AKTIVNE VRSTE" — ribe aktivne po sezoni (ikone)
- Upozorenje lovostaj (ako je vrsta zaštićena)
- Mesečeva mena + solunarni prozori (najbolji sati)
- Dugme "Sačuvaj u dnevnik"
- (ovo je dugačak skrol — osmisli ritam sekcija i "sticky" navigaciju/skor)

### 3. MAPA
Mapa Srbije sa vodama (markeri reke/jezero), tap → rezultat za tu vodu.

### 4. LISTA VODA
Pretraživa lista svih voda, filter reka/jezero, favorit toggle.

### 5. PROPISI / LOVOSTAJ
Spisak vrsta sa zaštitnim periodima i min. dimenzijama.

### 6. DNEVNIK — LISTA
Kartice prošlih izlazaka (datum, voda, uslovi, ulov).

### 7. DNEVNIK — UNOS
Forma: datum, voda, auto-popunjeni uslovi (temp/pritisak/nivo), beleške,
ulov (vrsta/količina), (kasnije foto).

### 8. DNEVNIK — STATISTIKA
Grafovi/uvidi iz dnevnika (uspeh po uslovima/sezoni).

## ISPORUKA
- Kratko obrazloženje odabrane estetike
- Vizuelni sistem (paleta light+dark, tipografija, komponente)
- Mockup svake od 8 stranica
- Napomena kako se komponente ponovo koriste između stranica
