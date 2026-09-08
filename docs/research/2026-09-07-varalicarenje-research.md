# Varaličarenje u Srbiji — istraživanje (2026-09-07)

> Web istraživanje za budući **Varalica** feature. Fokus: UL (ultralight) i klasično varaličarenje
> na srpskim vodama. Sinteza + predlog za app na kraju.
> Vezano: `lib/logic/technique_advisor.dart`, `lib/data/fishing_seasons.dart`, `docs/METHOD_TAB.md`.
>
> **Status izvora:** srpski/regionalni ribolovački portali + prodavci. Nije peer-reviewed.
> Sve što je moja pretpostavka, a ne iz izvora, označeno je `⟨pretpostavka⟩`.

---

## 1. Ciljne vrste — kanonska lista

Varalicar.com (portal posvećen isključivo varaličarenju, aktivan 2006–2023) drži listu od
11 vrsta koje se u Srbiji ciljano love varalicom:

| Vrsta | Latinski | Gde (po izvoru) | Klasa |
|---|---|---|---|
| **Smuđ** | *Sander lucioperca* | Dunav, Sava, Tisa, Tamiš — dublji delovi | klasik |
| **Štuka** | *Esox lucius* | Dunav i donji tokovi pritoka | klasik |
| **Bucov** | *Aspius aspius* | Dunav, Sava, Tisa, donji tok Drine i V. Morave | UL **i** klasik |
| **Som** | *Silurus glanis* | Dunav, Sava, Tisa, Tamiš, Morava, donja Drina, DTD, akumulacije | teško |
| **Bas** | *Micropterus salmoides* | **Stari Bački kanal**, kanalski sistem Bačke | UL |
| **Mladica** | *Hucho hucho* | Drina, Lim, Uvac, Vapa, Tara, Piva | teško, ⚠ vidi §5 |
| **Mrena** | *Barbus barbus* | Dunav, Sava, Drina, V. Morava, Tisa | UL (nije grabljivica) |
| **Klen** | *Squalius cephalus* | male reke, sve do pastrmske zone | **UL — glavna meta** |
| **Potočna pastrmka** | *Salmo trutta* | Mlava, Rzav, Đetinja, Piva, Tara, Vapa, Uvac | UL |
| **Kalifornijska pastrmka** | *Oncorhynchus mykiss* | poribljene pastrmske reke | UL |
| **Bandar / grgeč** | *Perca fluviatilis* | donji tokovi, bare, kanali, jezera; **Vlasinsko jezero**, **Timok** | **UL — glavna meta** |

Bandar u Srbiji retko preko 0.8 kg; prosečna lovna težina 300–600 g (Timok).
Smuđ kamenjar (*S. volgense*) — retko preko 1 kg, **nije** predmet ciljnog varaličarenja.

Izvor: [varalicar.com/ribe](http://www.varalicar.com/ribe/)

---

## 2. UL vs klasik — gde je granica

**Međunarodna klasifikacija** (7 klasa: UL, L, ML, M, MH, H, XH):
UL štap = varalice **1/32–1/4 oz ≈ 0.9–3.5 g**, struna 2–6 lb, dužina 5–7 ft, fast/extra-fast akcija.

**Srpska/regionalna praksa je šira** — iz intervjua sa dvojicom vrhunskih bucovaša
(Ivan Samardžić „Blik", SRB; Marijan Jambrešić „Maki", HR) na varalicar.com, štapovi koje
stvarno koriste za UL bucova:

- Smith Interboron X 66MT — **3–8 lb, 3–10 g**
- St.Croix Avid AVS66LF2 — fast, 4–8 lb, **1/16–1/4 oz** (1.8–7 g)
- St.Croix Avid AVS66ULF2 — fast, 2–6 lb, **1/32–3/16 oz** (0.9–5.3 g)
- Palms Egeria Native Erns-53 UL — **2–6 g**
- Major Craft Go Emotion — **3.5–10 g** (za površince / dalji zabačaj)

**Zaključak za app ⟨pretpostavka⟩:** praktična granica u Srbiji je

```
UL      ≈  1–10 g test          (klen, bandar, bas, pastrmka, bucov, mrena)
klasik  ≈  10–40 g test         (smuđ, štuka, bucov)
teško   ≈  40 g+ / džerk / big bait   (som, velika štuka, mladica)
```

**Struna (UL, iz istog izvora):**
- pletenica 5–8 lb (Sunline, Varivas, Power Pro 5 lb, YGK G-Soul)
- **fluorokarbonski predvez OBAVEZAN** — 4 lb, ~50 cm; manje uočljiv u bistroj jesenjoj vodi + otporniji na habanje
- najlon alternativa: 0.16 mm (Owner Broad, Stroft GTM)
- razlog za tanku strunu: UL štap ne baca teške terete — **samo tanka struna izbacuje lagane varalice dovoljno daleko**

---

## 3. Po vrsti — uslovi, mesta, varalice

### 3.1 Smuđ (klasik) — najbolje dokumentovan

Izvor: [sportskiribolov.co.rs/varalicarenje-koje-je-pravilo](https://www.sportskiribolov.co.rs/varalicarenje-koje-je-pravilo)
(autor sa 30 g. iskustva, Dunav/Sava/Tisa/Tamiš; magazin „Reviri Srbije" br.14)

**Mesta:**
- dublji delovi reke, jači protok bogat kiseonikom
- prelazi brze i tihe vode; špicevi, naperi, uvale
- povratni tok — tu se varalica vuče **niz tok** (obrnuto od logike)
- prelaz plićaka u dubinu **i obrnuto** (sprud 10–20 m od obale)
- **kamenito i peščano dno sa preprekama**; užasava se ravnog muljevitog dna
- „Gde nema zakački nema ni smuđa"

**Varalice po dubini:**
- do ~5 m → dubokoronci (jača vibracija; dubinu zaranjanja regulisati sporijim povlačenjem + podizanjem vrha štapa)
- **preko 5–6 m → vobleri beskorisni** → tvisteri, šedovi, glavinjare
- „najlakša moguća glava za tu vodu"

**Uslovi (ovo je direktno mapirljivo na naš scoring):**

| Faktor | Šta izvor kaže |
|---|---|
| **Vodostaj** | Porast donosi smuđa, ALI najbolje je **2–3 dana POSLE porasta**, kad voda „legne" (stagnira ±par cm). Ako se voda posle porasta vrati na staro ili niže — „bolje da nije ni dolazila". |
| **Zamućenje** | Umereno zamućenje **pogoduje** (ne može da razgleda varalicu). Jako blatnjava — ne. Prolećne bujice snežnice (hladne) — ne. |
| **Mesec** | Punjenjem meseca aktivniji i agresivniji, penje se u gornje slojeve. Praznjenjem „smanjuje gas". **Mirne noći punog meseca = vrh.** |
| **Vetar** | Preferira bonacu / blagi povetarac. Po košavi — naći zavetrinu ili tražiti obalu **prema kojoj** vetar duva (sabija sitnu ribu uz obalu). |
| **Nagla promena vremena** | Vetar naglo stane ili krene, kišica počne pa stane, naglo razvedravanje ili naoblačenje, krupan sneg — **smuđ se diže i kreće u lov**. Noću = sigurno. |
| **Doba dana** | Sumrak i noć; danju se povlači ka sredini reke. Kad je voda manje providna — vraća se bliže obali; kad je jako zamućena — **veoma blizu obale**. |

**Sezona:** varaličarenje kreće **kraj marta / početak aprila**, sa prvim porastom vode
([telegraf.rs](https://www.telegraf.rs/lov-i-ribolov/ribolov/3605992-varalicarenje-smudja-i-cug)).
Tehnike: džigovanje (dizanje glave sa dna) i „rusifikacija" (motanje sa pauzama), ili kombinacija.
Gumeni mamci 20–70 mm.

### 3.2 Štuka (klasik → teško) — jak temperaturni gradijent po veličini

Izvor: [varalicar.com/tekstovi/varalicarenje-stuke-tokom-zime](http://www.varalicar.com/tekstovi/varalicarenje-stuke-tokom-zime/)

**Ključni uvid: temperaturni afiniteti se drastično razlikuju po veličini ribe.**

| Kategorija | Ponašanje |
|---|---|
| sitna (~0.5 kg) | radi toplije; **početkom zime kao da nestane** |
| krupna (4–7.5 kg) | vrhunac u **mlakom jesenjem** okruženju; početkom zime metabolizam usporava |
| kapitalna (15+ kg) | **leti u niziji praktično neulovljiva** (post 2–2.5 meseca); zimi u svom elementu, hrani se i **dobija na težini čak i pod ledom** |

**Zima — lokacije:** duboko, **60–70 % maksimalne dubine** (pridneni sloj je zimi i najtopliji i najbogatiji kiseonikom, ~4 °C).
Četiri tipa: (L1) najdublji podvodni plato uz liniju promene, (L2) brežuljci na ravnom dnu
(bolji sa granjem, i bolji okružen muljem nego na glini), (L3) rupa 2–4× prosečne dubine, nagib oboda **30–45°**,
(L4) podvodni rt — forsirati sunčanu stranu, noću mesečinom prelivenu.

**Zima — prezentacija:** *„Što je voda toplija, sme da je brži."* Neutralna štuka pomeriće se najviše za dužinu tela.
- P1 **suspending vobler**, parkiran; **šed silueta > mino** (jedan veći i širi, ne tri manja i uža); paternoster sa otežanjem na kraćem predvezu
- P2 **soft-džerk** na worm udici 4/0–5/0; „karolina" rig; džigovanje sporih i niskih odskoka, ne dalje od 0.6 m od dna; **pauze 15–20 s** na hot-spotovima
- P3 **velika tanka kašika**, sporo motanje bez pauza (primer: Lavov Spoon MD Light 83 mm / 24 g)
- P4 **džig sa štitnikom**, king-size, crno-plava suknja; horizontalno spljoštena gumica da usporava tonjenje
- ⚠ **miris:** „Ako je varalica brza, miris je nevažan. Kako prezentacija usporava, on dobija na važnosti. Spor mamac treba, a nepokretan MORA da miriše."

### 3.3 Bucov (UL — flagship UL riba)

Izvor: [varalicar.com/tekstovi/varalicarenje-bucova-ultra-light-priborom](http://www.varalicar.com/tekstovi/varalicarenje-bucova-ultra-light-priborom/)

- Prosečna ciljana težina na UL: **1.5–3.5 kg** (SRB), 1–2 kg (HR); preko 3 kg svakih 4–5 izlazaka
- Zašto UL radi: bucov se bori **sirovom snagom na otvorenoj vodi**, ne zavlači se u prepreke.
  Kritičan je prvi udarac — kočnica mora pravovremeno da proklizne.
- **Mesta (SRB, V. Morava):** delovi sa **sporijim protokom, bez prepreka**; ulaz u vir; duži i dublji šljunčani sprudovi
- **Mesta (HR, Sava):** gde se meša voda, prelazi plićeg u dublje, spoj mirne vode i matice, preljevi, slapovi — **sve blizu obale** (UL nema domet)
- **Obala mora biti blaga i pristupačna** — riba se vadi rukom, nema navlačenja
- **Sezona:** SRB → **jesen** (niži vodostaj = sva bucovska mesta dostupna UL-u; bucov se sjati i aktivno traži hranu). HR → **jun–avgust**.
- **Varalice:** Megabass X-70, Fantasia Fugitive 75, Megabass Dog-X Jr (zara 7 g, walking-the-dog),
  Rapala SSR 5, Rapala F7 / F9, Daiwa 1061, Ito.Craft Jamai 50s, OSP Bent Minnow

### 3.4 Klen (UL — najdostupnija UL riba)

Izvori: [plovak-varalica.blogspot.com](https://plovak-varalica.blogspot.com/2016/07/varalicarenje-klena-na-malim-rekama.html), varalicar.com/ribe/klen

- Male reke, sve do pastrmske zone; u salmonidnim vodama u sporijem toku
- **Leto, bistra mala voda: rano ujutru i kasno popodne >> po danu**
- Plitke zone → plivajuće varalice u obliku **skakavca**; dublje → klasične „kruškaste" rotirajuće kašike
- **Kašika se baca preko toka i uvodi u maticu sa suprotne strane**
- Napada na **granici brze i spore vode**, na dubljim delovima male vode
- ⚠ **Ne zadržavati se dugo na jednom mestu** — klen uzima u prvih par zabačaja ako je tu i ako jede
- Mikro tvisteri i gumice **do 5 cm**; mikro kašike za UL

### 3.5 Som (teško)

Dunav, Sava, Tisa, Tamiš, Morava, donja Drina, DTD, akumulacije. Do 150 kg / 3 m / 45 godina.
Često se zaleti na smuđarski pribor na dubokim terenima (preko 5–6 m) — pribor „na ozbiljne muke".

### 3.6 Bandar / bas (UL)

Bandar: donji tokovi, plavna područja, bare, kanali, jezera. **Vlasinsko jezero na 1230 m** — uspešno se
razmnožava. **Timok** — živi sa klenom, prosečna lovna težina 300–600 g.
Bas: **Stari Bački kanal** ima najgušću populaciju u Srbiji.

---

## 4. Sezonski kalendar (sinteza izvora ⟨pretpostavka gde nije eksplicitno⟩)

| Mesec | UL | Klasik |
|---|---|---|
| I–II | bandar (jezera/kanali) | **kapitalna štuka** (duboko, sporo), smuđ |
| III | pastrmka od 1.3. | smuđ (kraj marta — start sezone sa prvim porastom) |
| IV | klen, mrena (do 15.4.), pastrmka | štuka (lovostaj do 31.3.), smuđ (lovostaj 1.3–30.4.) |
| V | klen (lovostaj do 31.5.), pastrmka | bucov (lovostaj 15.4–15.6.), som (lovostaj 1.5–15.6.) |
| VI | klen, bandar, bas, pastrmka | som (od 16.6.), bucov (od 16.6.) |
| VII–VIII | **vrh UL sezone** — klen, bandar, bas, bucov | som; ⚠ velika štuka u niziji praktično nedostupna |
| IX–X | **bucov na UL (vrh, SRB)**, klen | **štuka — krupna u vrhu**, smuđ |
| XI | bucov, bandar | štuka, smuđ |
| XII | bandar | **kapitalna štuka**, smuđ |

---

## 5. Propisi — šta app već ima i šta fali

`lib/data/fishing_seasons.dart` **pokriva:** štuka, smuđ, smuđ kamenjar, šaran, mrena, plotica/klen,
deverika/jaz, skobalj, bucov, som.

⚠ **NEDOSTAJU salmonidi i UL vrste** ([buckaros.com](https://buckaros.com/lovostaj-riba-i-dozvoljene-lovne-duzine-u-srbiji)):

| Vrsta | Lovostaj | Min. mera |
|---|---|---|
| **Mladica** (*Hucho hucho*) | **1.3 – 31.8.** | **100 cm** |
| **Potočna pastrmka** | **1.10 – 1.3.** | **25 cm** |
| **Ohridska pastrmka** | 1.10 – 1.3. | 40 cm |
| **Lipljen** | **1.3 – 31.5.** | **30 cm** |
| Grgeč / bandar | nema lovostaja | 10 cm |

⚠ **Noćna zabrana za salmonide:** ribolov zabranjen **21:00–03:00 (letnje)** / **18:00–05:00 (zimsko)**
za mladicu, sve vrste pastrmke i lipljena. — *Ovo app trenutno uopšte ne pominje, a direktno je
UL/varaličarska stvar.*

Trajno zaštićene: kečiga, moruna, linjak, zlatni karaš, čikov, crnka. (App ima ovu listu.)

**Pastrmski reviri:** pravila variraju po reviru — C&R, samo veštački mamci, udice bez kontre,
ograničenje veličine strimera. **NE hardkodovati** — prikazati upozorenje „proveri pravila revira".

---

## 6. Šta app već ima (2026-09-07)

`TechniqueAdvisor._scoreSpinning()` — jedan skor za celo „varaličarenje":

```
temp vazduha        0.24    _predatorTempSub: opt 8–20 °C
pritisak            0.15
vetar               0.18    0.7·windChopSub + 0.3·windDirSub  (voli blago talasanje)
zamućenje           0.20    turbiditySubPredator
oblačnost           0.11    cloudSub(20, 60)
vodostaj            0.12    levelSubPredator
```

Vraća samo `targetFish` listu po mesecu (`_spinningFish`). **Nema:** UL/klasik podelu, izbor varalice,
težinu, boju, vođenje, tip vode, temperaturu **vode** (koristi temp vazduha!), mesečevu fazu,
salmonidne vrste.

🐛 **Typo:** `lib/models/technique_score.dart` → `'Varalicarenje'` bez `č`. Treba **`Varaličarenje`**.
Isto i u `technique_advisor.dart` `_fishForMonth()` (8 pojava).

---

## 7. Vrste varalica — taksonomija

Varalicar.com deli varalice u 7 porodica: **Buzzbait · Spinnerbait · Vobleri ·
Silikonci · Površinci · Metalne varalice · Jerk & swimbait**.
Razrada (varalicar.com + zanimljiv.org):

| Porodica | Srpski nazivi / podvrste | Kako radi | Mete |
|---|---|---|---|
| **Vobleri** | mino (izdužen), šed (zdepast), krank, zglobni; plivajući / tonući / **suspending**; plitko- i dubokoronci | usna (kljun) određuje dubinu; imitira ranjenu ribicu | sve grabljivice |
| **Silikonci** | tvister (uvijeni rep), šed, creature, imitacije crva/žabe | montiraju se na **jig glavu**; fleksibilnost = jačina vibracije | smuđ, štuka, som |
| **Metalne** | **kašike**, **leptiri** (rotirajuće; „meps"), **čikade** (metalne glavinjare), **kastmasteri/spinkasteri**, **pilkeri** | najjednostavnije i najjeftinije; hvataju sve | sve |
| **Površinci** | **poperi**, **zare** (walking-the-dog), buzzbait | rade samo gornji sloj; traže uvežbanu tehniku | štuka, som, bandar, bucov |
| **Glavinjare** | lipless krank sa zvečkom (Orka, Varga, Draško, Brzotrz, Vida, KZV — domaći) | brzo tone, zvuk + vibracija | štuka, bandar |
| **Spinnerbait** | žica + listić + silikonska suknja | ne kači se u travi i granju | štuka, bas |
| **Jerk & swimbait** | tvrdi džerk, swimbait | krupan profil, agresivan potez štapom | velika štuka, som |

Bitno za app: **spinnerbait i glavinjare su rešenje za zakrčen/zatravljen teren**,
gde se klasične varalice stalno kače — to je izbor po TERENU, ne po vrsti ribe.

---

## 8. Plovkarenje — dva odvojena sveta

### 8.1 Klasičan plovak
Stajaće vode i spori tokovi, hranjeno mesto, waggler / bolonjez.
Mete: deverika, bodorka, karaš, šaran, amur. Ovo je već pokriveno logikom
temperaturnih pojaseva iz `BaitAdvisor`.

### 8.2 Plovak na otpuštanje (rečno vođenje) ⭐

Mete: **skobalj, mrena, plotica, klen** (usput bucov, deverika, pa i mladica).
Reke: **Drina** je najbogatija skobaljem; isto i Lim, Morava, Ibar.

**Pribor** ([plovkarenje.blogspot](https://plovkarenje.blogspot.com/2010/01/rijeka-drina-plovkarenje-ribolov.html)):
- štap **4–6 m sa mašinicom**, ili ~7 m bez mašinice
- najlon **0.16–0.20 mm** (za finiji lov skobalja 0.12–0.14 mm)
- plovak **3–9 g** zavisno od terena; do ~10 g u gruboj vodi
- udice **9–14**; za travu sitnije, sa **namotajem umesto ušice**

**Mamci:**
- **trava = alga kladofora (*Cladophora glomerata*)**, bere se sa kamenja u TOJ reci
- hleb (kora i sredina), **pen sajo / testo**, crv / glista, kaster
- ⚠ **Na travu se NE prihranjuje** — riba je već na algi. Na „bele" mamce prihrana je **obavezna** (loptice hleba/primame, bačene malo uzvodno).
- Trava varira po vodi: „negde lovi čisto drečavo zelena, negde trula smeđe-žuta". **Meka, raspadnuta alga sa sitnim organizmima > sveža.**
- „Maskirna" (crno-pegava zeleno-žuta) alga: **rano leto i kasna jesen** = vrh.
- Namotavanje: algu obmotaš oko struka udice, **donji deo ostaviš slobodan da leprša**.

**Četiri načina vođenja** ([sportskiribolov.co.rs](https://www.sportskiribolov.co.rs/tehnika-plovkarenja-na-brzim-rijekama)):

| Tehnika | Kada | Kako + olovljavanje |
|---|---|---|
| **Štopovanje** | brza ujednačena voda, sitan šljunak/pesak | ritmično pridrži pa pusti; mamac „češlja" dno sporije od struje. Bulk **30 cm iznad udice** + 1–2 sitne tik iznad. Plovak **10–20 cm dublje od izmerene dubine**. |
| **Španovanje** | ujednačen tok i dubina; **najbolje za travu** | struna blago zategnuta, plovak se NE zaustavlja. Plovak na **tačnoj** dubini. |
| **Zadržavanje** | krševito dno, kanali između gromada, nagle promene dubine | kratka pauza pred svaku prepreku da voda podigne postavku. Bulk **odmah ispod plovka** + 5–6 sitnih nanizanih ka udici (slalom preko 25–80 cm razlike). |
| **Slobodno puštanje** | spora travnata voda, plotica, zimski skobalj u virovima | bez zatezanja. Plotica je oprezna — svaka korekcija plovka u zoni uzimanja je odbija. |

**Predvez:** što brža, plića i ravnija voda → kraći (**ispod 30 cm**);
umereno → 30–50 cm; duboko i nepravilno → **do 70 cm, ne preko**.

**Uslovi:**
- **Zima je bolji deo sezone od leta.** Leti radi samo rano ujutru i kasno uveče.
- Šljunkovit teren sa brzom vodom; izbegavati **preko 5 m dubine** i čisto muljevito dno.
- **Mutna voda → riba uz obalu. Bistra → riba se povlači u maticu.**
- ⚠ Vodostaj: **Drina raste → pomeraj plovak na VEĆU dubinu; opada → smanjuj.**
- ⚠ Lovostaj: skobalj, mrena, plotica i klen — svi **15.4–31.5**. Ceo maj je mrtav za ovu tehniku.

---

## Izvori

- [varalicar.com — Ribe](http://www.varalicar.com/ribe/)
- [varalicar.com — Varaličarenje bucova ultra light priborom](http://www.varalicar.com/tekstovi/varalicarenje-bucova-ultra-light-priborom/)
- [varalicar.com — Varaličarenje štuke tokom zime](http://www.varalicar.com/tekstovi/varalicarenje-stuke-tokom-zime/)
- [sportskiribolov.co.rs — Varaličarenje: Koje je pravilo?](https://www.sportskiribolov.co.rs/varalicarenje-koje-je-pravilo)
- [telegraf.rs — Varaličarenje smuđa: presudan je cug](https://www.telegraf.rs/lov-i-ribolov/ribolov/3605992-varalicarenje-smudja-i-cug)
- [plovak-varalica.blogspot.com — Varaličarenje klena na malim rekama](https://plovak-varalica.blogspot.com/2016/07/varalicarenje-klena-na-malim-rekama.html)
- [buckaros.com — Lovostaj riba i dozvoljene lovne dužine u Srbiji](https://buckaros.com/lovostaj-riba-i-dozvoljene-lovne-duzine-u-srbiji)
- [sportskiribolov.co.rs — Lovostaj riba i lovne dužine](https://www.sportskiribolov.co.rs/lovostaj-riba-lovne-duzine-srbija)
- [ultralightanglers.com — What is Ultralight Fishing](https://www.ultralightanglers.com/what-is-ultralight-fishing/)
- [allfishingbuy.com — Fishing Rod Power Chart](https://www.allfishingbuy.com/Fishing-Rods-Power.php)
- [plovkarenje.blogspot.com — Rijeka Drina](https://plovkarenje.blogspot.com/2010/01/rijeka-drina-plovkarenje-ribolov.html)
- [sportskiribolov.co.rs — Tehnika plovkarenja na brzim rijekama](https://www.sportskiribolov.co.rs/tehnika-plovkarenja-na-brzim-rijekama)
- [zanimljiv.org — Saveti za lov skobalja](https://zanimljiv.org/sportski-ribolov/133-saveti-za-lov-skobalja)
- [ribolov.de — Tajni mamci za skobalja](https://ribolov.de/tajni-mamci-za-skobalja)
- [varalicar.com — Varalice (taksonomija)](http://www.varalicar.com/varalice/)
- [zanimljiv.org — Vrste varalica](https://zanimljiv.org/sportski-ribolov/137-vrste-varalica)
