import '../models/water_combo.dart';

/// Kurirani Traper recepti po vodi + sezoni (m-fishing brend).
///
/// ŠABLON: za sad samo Dunav (reka) + Palić (prirodno jezero), sve 4 sezone.
/// Posle potvrde formata širi se na 10 reka + 10 jezera (po 4 sezone = 80).
/// Aktivnost ribe NIJE zaseban unos — primenjuje se kao modifikator preko
/// `activityMod()` (vidi water_combo.dart).
///
/// `baseFoodId` / `secondFoodId` / `pelletId` / `additiveIds` referenciraju
/// `traperBaits` (traper_baits.dart) po id-ju; UI iz njih vadi m-fishing link.
const List<WaterCombo> traperCombos = [
  // ════════ DUNAV (velika reka, jaka struja) ════════
  WaterCombo(
    waterName: 'Dunav',
    waterType: 'river',
    season: Season.prolece,
    species: {'deverika', 'mrena', 'bodorka'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri (po koji na udici, ostalo u smešu).',
    prep:
        'Voda:smesa ~1:3, odmori 20–30 min pa ponovo prosej. Krupnije mlevenje za '
        'reku; smeša treba da je teška i lepljiva da izdrži struju.',
    loading:
        'Početak: 6–8 punih hranilica u kratkom ritmu da napraviš mrlju, pa dopuna '
        'na svaki zabačaj. Jak protok — stalan ritam.',
  ),
  WaterCombo(
    waterName: 'Dunav',
    waterType: 'river',
    season: Season.leto,
    species: {'deverika', 'mrena', 'saran'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Pelet na vlas, kukuruz ili bojli; crvi/kasteri kao dodatak.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla voda — slobodno jača aroma i riblji '
        'profil; ubaci pelet u smešu za zadržavanje krupnije ribe.',
    loading:
        'Početak: 8–10 hranilica, pa dopuna na 3–5 min. Aktivna riba leti traži '
        'stalan dotok hrane.',
  ),
  WaterCombo(
    waterName: 'Dunav',
    waterType: 'river',
    season: Season.jesen,
    species: {'deverika', 'bodorka', 'mrena'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Crvi i trzalice; po koji kaster.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finija nota (Grand Prix), ali zadrži '
        'vezivanje za struju; čestice srednje krupnoće.',
    loading:
        'Početak: 5–6 hranilica, pa umerena dopuna na 4–6 min. Riba se još hrani, '
        'ali ne preteruj sa količinom.',
  ),
  WaterCombo(
    waterName: 'Dunav',
    waterType: 'river',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica (krvavi crv) ili 1–2 sitna crva — diskretno.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna i fina smeša, bez jakih aroma.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 10–15 min. Hladno — riba '
        'jede malo, prehranjivanje ubija ujed.',
  ),

  // ════════ PALIĆ (plitko prirodno jezero) ════════
  WaterCombo(
    waterName: 'Palićko jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'bodorka', 'deverika', 'babuska'},
    baseFoodId: 'feeder-serija-dynamic-i-turbo-1-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po koje zrno kukuruza za babušku.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Plitko jezero — lakša, aktivnija smeša koja '
        'pravi oblak; ne previše teško.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 5–8 min. Proleće — riba se budi, '
        'umereno hranjenje.',
  ),
  WaterCombo(
    waterName: 'Palićko jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'babuska', 'linjak'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'mf-peleti-2mm-vise-aroma',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels/wafter, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti (stisak drži), bez odmaranja kao kod feedera. '
        'Pakuj na flat/method frame oko mamca.',
    loading:
        'Method: 3–4 punjenja za start na isto mesto, pa zamena na 10–15 min. Toplo — '
        'jak trag, ali method drži kompaktno hranilište.',
  ),
  WaterCombo(
    waterName: 'Palićko jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'bodorka', 'deverika', 'babuska', 'saran'},
    baseFoodId: 'primama-specijal-serija-2-5-kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Crvi, kasteri ili kukuruz.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Jesen — univerzalna baza + finiji Magic '
        'za belu ribu; srednja granulacija.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Palićko jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna fina smeša, diskretno.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladna stajaća '
        'voda — vrlo malo hrane.',
  ),

  // ════════ REKE (batch) ════════
  WaterCombo(
    waterName: 'Sava',
    waterType: 'river',
    season: Season.prolece,
    species: {'deverika', 'mrena', 'bodorka'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po koja glista za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min pa prosej. Umerena struja velike reke — smeša '
        'srednje-krupna, teška i dobro vezana da legne na dno.',
    loading:
        'Početak: 6–7 punih hranilica da napraviš mrlju, pa dopuna na svaki zabačaj. '
        'Hladna prolećna voda — ne preteruj sa količinom.',
  ),
  WaterCombo(
    waterName: 'Sava',
    waterType: 'river',
    season: Season.leto,
    species: {'deverika', 'mrena', 'saran'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Pelet na vlas ili kukuruz; crvi/glista kao dodatak.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla voda — pojačaj riblji profil i ubaci '
        'pelet; zadrži vezivanje za umerenu struju.',
    loading:
        'Početak: 8–9 hranilica, pa dopuna na 3–5 min. Leti riba aktivna — stalan '
        'dotok hrane drži jato.',
  ),
  WaterCombo(
    waterName: 'Sava',
    waterType: 'river',
    season: Season.jesen,
    species: {'deverika', 'bodorka', 'mrena'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Crvi i trzalice; glista za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finija nota Grand Prix, ali drži '
        'vezivanje za struju; srednja granulacija.',
    loading:
        'Početak: 5–6 hranilica, pa umerena dopuna na 5–6 min. Voda hladi — smanji '
        'količinu kako sezona odmiče.',
  ),
  WaterCombo(
    waterName: 'Sava',
    waterType: 'river',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili 1–2 sitna crva, diskretno.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — tamna fina smeša, bez '
        'jakih aroma, tek toliko teška da izdrži spori zimski tok.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — riba '
        'jede malo, prehranjivanje gasi ujed.',
  ),
  WaterCombo(
    waterName: 'Tisa',
    waterType: 'river',
    season: Season.prolece,
    species: {'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'giant-river-primama-2-5-kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; glista za krupnu deveriku.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Sporija muljevita reka — teška vezana baza '
        'koja se ne raspline prebrzo; srednje mlevenje.',
    loading:
        'Početak: 6–7 hranilica za mrlju, pa dopuna na svaki zabačaj. Proleće — '
        'umereno, riba se tek razigrava.',
  ),
  WaterCombo(
    waterName: 'Tisa',
    waterType: 'river',
    season: Season.leto,
    species: {'deverika', 'saran', 'som'},
    baseFoodId: 'giant-river-primama-2-5-kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'expert-big-catfish-som-peleti-traper',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Pelet ili kukuruz za šarana; gomila crva/glista za soma.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla muljevita voda — jak proteinski profil '
        'i som-pelet; smeša teška i lepljiva.',
    loading:
        'Početak: 8–10 hranilica, pa dopuna na 3–5 min. Toplo — krupna riba traži '
        'obilan i stalan dotok.',
  ),
  WaterCombo(
    waterName: 'Tisa',
    waterType: 'river',
    season: Season.jesen,
    species: {'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'giant-river-primama-2-5-kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Crvi i kasteri; trzalica kako zahladi.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic za belu ribu uz tešku '
        'baznu reku; drži vezivanje za muljevito dno.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 5–7 min. Riba se još hrani, ali smanjuj '
        'kako voda pada.',
  ),
  WaterCombo(
    waterName: 'Tisa',
    waterType: 'river',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv, diskretno.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, tamna '
        'fina smeša na sporoj hladnoj Tisi, bez aroma.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladna spora voda '
        '— vrlo malo hrane.',
  ),
  WaterCombo(
    waterName: 'Velika Morava',
    waterType: 'river',
    season: Season.prolece,
    species: {'deverika', 'mrena', 'klen'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Crvi i glista; sir za klena.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Umerena struja srednje reke — smeša srednje '
        'granulacije, dovoljno vezana da izdrži zabačaj.',
    loading:
        'Početak: 5–6 hranilica za mrlju, pa dopuna na svaki zabačaj. Prolećna voda '
        'još hladna — umereno.',
  ),
  WaterCombo(
    waterName: 'Velika Morava',
    waterType: 'river',
    season: Season.leto,
    species: {'deverika', 'skobalj', 'saran'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Pelet ili kukuruz za šarana; crvi/glista za belu ribu.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Toplo — riblji profil i pelet; smeša teža da '
        'zadrži krupniju ribu u struji.',
    loading:
        'Početak: 7–8 hranilica, pa dopuna na 3–5 min. Leti aktivna riba traži stalan '
        'dotok.',
  ),
  WaterCombo(
    waterName: 'Velika Morava',
    waterType: 'river',
    season: Season.jesen,
    species: {'deverika', 'mrena', 'klen'},
    baseFoodId: 'gst-competition-river-1kg-traper',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Crvi, glista i sir; trzalica kako zahladi.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz reku bazu; srednja '
        'granulacija, zadrži vezivanje za umerenu struju.',
    loading:
        'Početak: 5 hranilica, pa umerena dopuna na 5–6 min. Smanjuj količinu kako '
        'voda hladi.',
  ),
  WaterCombo(
    waterName: 'Velika Morava',
    waterType: 'river',
    season: Season.zima,
    species: {'deverika', 'klen'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv; komadić sira za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — fina tamna smeša, bez '
        'aroma, tek toliko da legne u sporu zimsku struju.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 10–15 min. Hladno — vrlo '
        'malo hrane.',
  ),
  WaterCombo(
    waterName: 'Zapadna Morava',
    waterType: 'river',
    season: Season.prolece,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Glista i crvi; sir za klena.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Brža reka preko šljunka — teško vezana smeša '
        'krupnije granulacije da ne otplovi nizvodno.',
    loading:
        'Početak: 6 dobro stisnutih hranilica, pa dopuna na svaki zabačaj. Hladna '
        'prolećna voda — umereno.',
  ),
  WaterCombo(
    waterName: 'Zapadna Morava',
    waterType: 'river',
    season: Season.leto,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Glista, crvi ili sir; pelet na vlas za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla brza voda — pojačan riblji profil i '
        'pelet; smeša lepljiva i teška da izdrži šljunkoviti tok.',
    loading:
        'Početak: 8 hranilica, pa dopuna na 3–4 min. Leti riba aktivna na struji — '
        'stalan ritam.',
  ),
  WaterCombo(
    waterName: 'Zapadna Morava',
    waterType: 'river',
    season: Season.jesen,
    species: {'mrena', 'klen', 'deverika'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Glista, crvi i sir; trzalica kasnije.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz tešku reku bazu; '
        'drži vezivanje za brzu vodu, srednja granulacija.',
    loading:
        'Početak: 5 hranilica, pa umerena dopuna na 5–6 min. Smanjuj kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Zapadna Morava',
    waterType: 'river',
    season: Season.zima,
    species: {'mrena', 'klen'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Sitan crv ili trzalica; komadić sira za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — fina tamna smeša, bez '
        'aroma; teže stisni da izdrži brzu hladnu vodu.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — '
        'minimalno hrane.',
  ),
  WaterCombo(
    waterName: 'Južna Morava',
    waterType: 'river',
    season: Season.prolece,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Glista i crvi; sir za klena.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Brža srednja reka — teško vezana smeša '
        'krupnije granulacije da odoli struji.',
    loading:
        'Početak: 6 stisnutih hranilica, pa dopuna na svaki zabačaj. Hladna prolećna '
        'voda — umereno.',
  ),
  WaterCombo(
    waterName: 'Južna Morava',
    waterType: 'river',
    season: Season.leto,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Glista, crvi ili sir; pelet na vlas.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla brza voda — riblji profil i pelet; '
        'smeša lepljiva i teška za struju.',
    loading:
        'Početak: 8 hranilica, pa dopuna na 3–4 min. Leti aktivna riba — stalan ritam.',
  ),
  WaterCombo(
    waterName: 'Južna Morava',
    waterType: 'river',
    season: Season.jesen,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Glista, crvi i sir; trzalica kasnije.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz reku bazu; zadrži '
        'vezivanje za brzu vodu.',
    loading:
        'Početak: 5 hranilica, pa umerena dopuna na 5–6 min. Smanjuj kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Južna Morava',
    waterType: 'river',
    season: Season.zima,
    species: {'mrena', 'klen'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Sitan crv ili trzalica; sir za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — fina tamna smeša bez '
        'aroma; jače stisni za brzu hladnu vodu.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — '
        'minimalno hrane.',
  ),
  WaterCombo(
    waterName: 'Ibar',
    waterType: 'river',
    season: Season.prolece,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Glista i crvi; sir za klena.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Brza šljunkovita reka — vrlo teško vezana '
        'smeša krupne granulacije, inače je struja odnese.',
    loading:
        'Početak: 6 čvrsto stisnutih hranilica, pa dopuna na svaki zabačaj. Hladna '
        'prolećna voda — umereno.',
  ),
  WaterCombo(
    waterName: 'Ibar',
    waterType: 'river',
    season: Season.leto,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Glista, crvi ili sir; pelet na vlas za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla brza voda preko šljunka — riblji profil '
        'i pelet; smeša maksimalno lepljiva i teška.',
    loading:
        'Početak: 8 hranilica, pa dopuna na 3–4 min. Leti riba aktivna na struji — '
        'stalan dotok.',
  ),
  WaterCombo(
    waterName: 'Ibar',
    waterType: 'river',
    season: Season.jesen,
    species: {'mrena', 'klen', 'deverika'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Glista, crvi i sir; trzalica kasnije.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz tešku reku bazu; '
        'zadrži snažno vezivanje za brzu vodu.',
    loading:
        'Početak: 5 hranilica, pa umerena dopuna na 5–6 min. Smanjuj kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Ibar',
    waterType: 'river',
    season: Season.zima,
    species: {'mrena', 'klen'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Sitan crv ili trzalica; komadić sira za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — fina tamna smeša bez '
        'aroma; jako stisni da izdrži brzu hladnu vodu.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — '
        'minimalno hrane.',
  ),
  WaterCombo(
    waterName: 'Drina',
    waterType: 'river',
    season: Season.prolece,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Glista i crvi; sir za klena.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Brza bistra hladna reka — teško vezana krupna '
        'smeša, diskretnija aroma jer je voda providna.',
    loading:
        'Početak: 5–6 čvrstih hranilica, pa dopuna na svaki zabačaj. Hladna bistra '
        'voda — ne preteruj, riba je oprezna.',
  ),
  WaterCombo(
    waterName: 'Drina',
    waterType: 'river',
    season: Season.leto,
    species: {'mrena', 'klen', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Glista, crvi ili sir; pelet na vlas za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Hladnija bistra voda i leti — umerena aroma '
        'uz betain i pelet; smeša teška i lepljiva za brzi tok.',
    loading:
        'Početak: 7 hranilica, pa dopuna na 3–5 min. Leti aktivna riba, ali bistra '
        'voda traži malo opreza sa količinom.',
  ),
  WaterCombo(
    waterName: 'Drina',
    waterType: 'river',
    season: Season.jesen,
    species: {'mrena', 'klen', 'deverika'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Glista, crvi i sir; trzalica kasnije.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz reku bazu; diskretna '
        'nota za bistru hladnu Drinu, zadrži vezivanje.',
    loading:
        'Početak: 4–5 hranilica, pa umerena dopuna na 5–6 min. Smanjuj kako voda '
        'hladi.',
  ),
  WaterCombo(
    waterName: 'Drina',
    waterType: 'river',
    season: Season.zima,
    species: {'mrena', 'klen'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Sitan crv ili trzalica; komadić sira za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — vrlo fina tamna smeša '
        'bez aroma; jako stisni za brzu ledenu bistru vodu.',
    loading:
        'Početak: 2 male hranilice, pa retka dopuna na 15 min. Hladna bistra voda — '
        'najmanje hrane, maksimalan oprez.',
  ),
  WaterCombo(
    waterName: 'Nišava',
    waterType: 'river',
    season: Season.prolece,
    species: {'klen', 'mrena', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-grand-prix-primama',
    mixRatio: '70 : 30',
    additiveIds: ['binder-vezivac-traper-400g', 'melasa-deverika-700g'],
    hookbait: 'Sir i glista za klena; crvi za skobalja.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Manja brža reka — teško vezana smeša, ali '
        'manje zapremine; krupnija granulacija da legne na dno.',
    loading:
        'Početak: 4–5 hranilica za mrlju, pa dopuna na svaki zabačaj. Mala reka — '
        'manje hrane nego na velikim tokovima.',
  ),
  WaterCombo(
    waterName: 'Nišava',
    waterType: 'river',
    season: Season.leto,
    species: {'klen', 'mrena', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gst-protein-fish-prihrana',
    mixRatio: '60 : 40',
    pelletId: 'gst-pellet-feeder-2-4-6mm-500g',
    additiveIds: ['expert-betain-200g-traper', 'melasa-traper'],
    hookbait: 'Sir, glista ili crvi; pelet na vlas za mrenu.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla mala brza reka — riblji profil i sitan '
        'pelet; smeša lepljiva, ali umerena zapremina.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 3–4 min. Leti klen aktivan — stalan '
        'ritam, ali pazi da ne prehraniš malu vodu.',
  ),
  WaterCombo(
    waterName: 'Nišava',
    waterType: 'river',
    season: Season.jesen,
    species: {'klen', 'mrena', 'skobalj'},
    baseFoodId: 'zaneta-reka-1kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g', 'binder-vezivac-traper-400g'],
    hookbait: 'Sir i glista za klena; trzalica kasnije.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — finiji Magic uz reku bazu; srednja '
        'granulacija, zadrži vezivanje za brzu malu reku.',
    loading:
        'Početak: 4 hranilice, pa umerena dopuna na 5–6 min. Smanjuj kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Nišava',
    waterType: 'river',
    season: Season.zima,
    species: {'klen', 'mrena'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Komadić sira ili sitan crv; trzalica.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — fina tamna smeša bez '
        'aroma; jače stisni za brzu hladnu vodu male reke.',
    loading:
        'Početak: 2 male hranilice, pa retka dopuna na 15 min. Hladno na maloj reci — '
        'vrlo malo hrane.',
  ),
  WaterCombo(
    waterName: 'Tamiš',
    waterType: 'river',
    season: Season.prolece,
    species: {'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'giant-river-primama-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po zrno kukuruza za babušku.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Spora nizijska reka — lakša, aktivnija smeša '
        'koja pravi oblak; bez teškog vezivanja jer struja gotovo da nema.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 5–8 min. Proleće — riba se budi, '
        'umereno hranjenje.',
  ),
  WaterCombo(
    waterName: 'Tamiš',
    waterType: 'river',
    season: Season.leto,
    species: {'saran', 'babuska', 'som'},
    baseFoodId: 'zeneta-saran-saran-linjak-babuska-2-5-kg',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'expert-big-catfish-som-peleti-traper',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Kukuruz, pelet ili bojli za šarana; gomila crva za soma.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Topla spora voda — slatka šaranska baza uz '
        'riblje brašno i som-pelet; jak miris u stajaćem koritu.',
    loading:
        'Početak: 6–8 hranilica, pa dopuna na 5–8 min. Spora topla voda — gradi '
        'mirisni trag, ali bez prebrze potrošnje.',
  ),
  WaterCombo(
    waterName: 'Tamiš',
    waterType: 'river',
    season: Season.jesen,
    species: {'deverika', 'babuska', 'bodorka', 'saran'},
    baseFoodId: 'primama-specijal-serija-2-5-kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-traper'],
    hookbait: 'Crvi, kasteri ili kukuruz.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — univerzalna baza + finiji Magic za '
        'belu ribu; srednja granulacija, lagano vezivanje za sporu reku.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda hladi.',
  ),
  WaterCombo(
    waterName: 'Tamiš',
    waterType: 'river',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv, diskretno.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, tamna '
        'fina smeša na sporoj hladnoj nizijskoj vodi, bez aroma.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladna spora voda '
        '— vrlo malo hrane.',
  ),

  // ════════ JEZERA (batch) ════════
  WaterCombo(
    waterName: 'Ludaško jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'bodorka', 'deverika', 'babuska'},
    baseFoodId: 'feeder-serija-dynamic-i-turbo-1-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po koje zrno kukuruza za babušku.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Vrlo plitko muljevito jezero — laka, '
        'rastresita smeša koja pravi oblak, da ne potone u mulj.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Hladnija prolećna voda — '
        'umereno, riba tek izlazi iz mulja.',
  ),
  WaterCombo(
    waterName: 'Ludaško jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'babuska', 'saran', 'bodorka', 'deverika'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'metod-feeder-peleti-2mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti (stisak drži), bez odmaranja. Toplo plitko '
        'jezero brzo zagreje — sitan 2mm pelet da ne prehraniš babušku.',
    loading:
        'Method: 3–4 punjenja za start, pa zamena na 12–15 min. Plitka topla voda '
        'lako se prehrani — drži kompaktno hranilište.',
  ),
  WaterCombo(
    waterName: 'Ludaško jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'bodorka', 'deverika', 'babuska'},
    baseFoodId: 'primama-specijal-serija-2-5-kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Crvi, kasteri ili sitan kukuruz.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Jesen — univerzalna baza + finiji Magic '
        'za belu ribu; nešto tamnija smeša nad muljem.',
    loading:
        'Početak: 4–5 hranilica, pa dopuna na 7–9 min. Voda se hladi — postepeno '
        'smanjuj količinu.',
  ),
  WaterCombo(
    waterName: 'Ludaško jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimum hrane, tamna '
        'fina smeša; plitka voda hladna do dna.',
    loading:
        'Početak: 2 male hranilice, pa retka dopuna na 15 min. Plitko i hladno — '
        'riba jede malo, ne prehranjuj.',
  ),
  WaterCombo(
    waterName: 'Belo jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'feeder-serija-dynamic-i-turbo-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po koje zrno kukuruza.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Prirodno zrenjaninsko jezero — srednje laka '
        'smeša, aktivna ali da drži na umerenoj dubini.',
    loading:
        'Početak: 6 hranilica da napraviš mrlju, pa dopuna na 5–7 min. Proleće — '
        'deverika se grupiše, hrani umereno.',
  ),
  WaterCombo(
    waterName: 'Belo jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'babuska', 'deverika'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '50 : 50',
    pelletId: 'metod-feeder-peleti-4mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels/wafter, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja, pakuj na frame oko mamca. '
        'Toplo — jak riblji profil i krupniji 4mm pelet za šarana.',
    loading:
        'Method: 4 punjenja za start na isto mesto, pa zamena na 10–15 min. Leto — '
        'jak trag, ali method drži kompaktno.',
  ),
  WaterCombo(
    waterName: 'Belo jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'deverika', 'babuska', 'bodorka', 'saran'},
    baseFoodId: 'primama-specijal-serija-2-5-kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Crvi, kasteri ili kukuruz.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — univerzalna baza + finiji Magic za '
        'belu ribu; srednja granulacija za dublju vodu.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda '
        'hladi.',
  ),
  WaterCombo(
    waterName: 'Belo jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili 1–2 sitna crva.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna i fina smeša bez jakih aroma.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladna stajaća '
        'voda — vrlo malo hrane.',
  ),
  WaterCombo(
    waterName: 'Srebrno jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'deverika', 'babuska', 'bodorka', 'saran'},
    baseFoodId: 'feeder-serija-carp-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; kukuruz za šarana i babušku.',
    prep:
        'Voda:smesa ~1:3, odmori 20 min. Dunavac/rukavac — gotovo bez struje, '
        'srednje teška smeša koja drži na mestu.',
    loading:
        'Početak: 6 hranilica, pa dopuna na 5–7 min. Proleće — riba se budi, '
        'umereno hranjenje uz belu ribu.',
  ),
  WaterCombo(
    waterName: 'Srebrno jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'babuska', 'deverika'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '50 : 50',
    pelletId: 'metod-feeder-peleti-4mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels, bojli, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja. Mirni rukavac leti zna da '
        'cveta — jak riblji profil i betain za šarana.',
    loading:
        'Method: 4 punjenja za start, pa zamena na 10–15 min. Toplo — stalan trag, '
        'method drži kompaktno hranilište.',
  ),
  WaterCombo(
    waterName: 'Srebrno jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'saran', 'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'primama-specijal-saran-babuska-linjak-25kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Kukuruz, crvi ili kasteri.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — baza za šarana/babušku + finiji '
        'Magic za belu ribu; srednja granulacija.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Voda se hladi — postepeno '
        'smanjuj količinu.',
  ),
  WaterCombo(
    waterName: 'Srebrno jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka', 'babuska'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna fina smeša; dublji rukavac drži nešto toplotnije dno.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — riba '
        'jede malo, prehranjivanje ubija ujed.',
  ),
  WaterCombo(
    waterName: 'Borsko jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'saran', 'babuska', 'bodorka', 'deverika'},
    baseFoodId: 'feeder-serija-carp-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; kukuruz za šarana.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Akumulacija — proletnja voda još hladna, '
        'srednje laka smeša koja pravi blag oblak.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 6–8 min. Proleće — riba se budi, '
        'umereno hranjenje.',
  ),
  WaterCombo(
    waterName: 'Borsko jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'babuska', 'deverika'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '50 : 50',
    pelletId: 'metod-feeder-peleti-4mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels/wafter, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja, pakuj na frame oko mamca. '
        'Toplo — jak riblji profil i krupniji 4mm pelet za šarana.',
    loading:
        'Method: 4 punjenja za start na isto mesto, pa zamena na 10–15 min. Leto — '
        'jak trag, method drži kompaktno.',
  ),
  WaterCombo(
    waterName: 'Borsko jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'saran', 'babuska', 'bodorka', 'deverika'},
    baseFoodId: 'primama-specijal-saran-babuska-linjak-25kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Kukuruz, crvi ili kasteri.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — baza za šarana/babušku + finiji '
        'Magic za belu ribu; srednja granulacija za dublju vodu.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda '
        'hladi.',
  ),
  WaterCombo(
    waterName: 'Borsko jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna i fina smeša; akumulacija hladna i bistra.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 15 min. Hladno i bistro — '
        'vrlo diskretno hranjenje.',
  ),
  WaterCombo(
    waterName: 'Vlasinsko jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Sitni crvi i kasteri; trzalica diskretno.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25–30 min, fino prosej. Visoko planinsko jezero — '
        'voda ledena u proleće, fina i diskretna smeša.',
    loading:
        'Početak: 3 male hranilice, pa retka dopuna na 10–12 min. Hladno planinsko '
        'jezero — vrlo malo hrane, bela riba pasivna.',
  ),
  WaterCombo(
    waterName: 'Vlasinsko jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'gold-grand-prix-primama',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Planinska voda i leti ostaje hladnija — '
        'umereno aktivna fina smeša, bez jakih aroma.',
    loading:
        'Početak: 4 hranilice, pa dopuna na 8–10 min. I leti hladnije — umereno '
        'hranjenje bele ribe.',
  ),
  WaterCombo(
    waterName: 'Vlasinsko jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi, kasteri ili trzalica.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25 min, fino prosej. Jesen na planini brzo zahladi '
        '— fina tamna smeša, mala količina.',
    loading:
        'Početak: 3 male hranilice, pa retka dopuna na 12 min. Brzo hlađenje — '
        'smanji hranu, riba se povlači.',
  ),
  WaterCombo(
    waterName: 'Vlasinsko jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'bodorka', 'deverika'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili jedan sitan crv.',
    prep:
        'Voda:smesa ~1:4, odmori 30 min, vrlo fino prosej. Visoka planina zimi — '
        'ekstremno hladno, minimum hrane, tamna fina smeša.',
    loading:
        'Početak: 1–2 male hranilice, pa vrlo retka dopuna na 15–20 min. Ledena voda '
        '— jedva hraniti, ujed je redak i nežan.',
  ),
  WaterCombo(
    waterName: 'Zlatarsko jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'deverika', 'bodorka', 'saran'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'feeder-serija-dynamic-i-turbo-1-kg',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; po koji kukuruz za šarana.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25 min, fino prosej. Planinska akumulacija — '
        'proletnja voda hladna, finija i diskretna smeša.',
    loading:
        'Početak: 3–4 hranilice, pa retka dopuna na 9–11 min. Hladnije planinsko '
        'jezero — umereno, riba još troma.',
  ),
  WaterCombo(
    waterName: 'Zlatarsko jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'deverika', 'bodorka'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'metod-feeder-peleti-2mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja. Planinska voda i leti '
        'umerena — sitan 2mm pelet i blaža doza arome.',
    loading:
        'Method: 3 punjenja za start, pa zamena na 12–15 min. Hladnije leto — drži '
        'kompaktno, ne prehranjuj.',
  ),
  WaterCombo(
    waterName: 'Zlatarsko jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'deverika', 'bodorka', 'saran'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi, kasteri ili kukuruz.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25 min, fino prosej. Jesen na planini brzo zahladi '
        '— fina tamna smeša, smanjena količina.',
    loading:
        'Početak: 3 hranilice, pa retka dopuna na 12 min. Brzo hlađenje — riba se '
        'povlači u dublje, hrani malo.',
  ),
  WaterCombo(
    waterName: 'Zlatarsko jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:4, odmori 30 min, vrlo fino prosej. Planinska zima — ledeno i '
        'bistro, minimum hrane, tamna fina smeša.',
    loading:
        'Početak: 1–2 male hranilice, pa vrlo retka dopuna na 15–20 min. Hladno i '
        'bistro — jedva hraniti.',
  ),
  WaterCombo(
    waterName: 'Jezero Perućac',
    waterType: 'lake',
    season: Season.prolece,
    species: {'deverika', 'bodorka', 'saran', 'klen'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'feeder-serija-dynamic-i-turbo-1-kg',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; kukuruz za šarana, sir/glista za klena.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25 min, fino prosej. Duboka hladna akumulacija na '
        'Drini — proletnja voda ledena, finija smeša, srednja granulacija za dubinu.',
    loading:
        'Početak: 4 hranilice, pa retka dopuna na 9–11 min. Duboko i hladno — '
        'umereno, riba još pasivna.',
  ),
  WaterCombo(
    waterName: 'Jezero Perućac',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'deverika', 'bodorka', 'klen'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '60 : 40',
    pelletId: 'metod-feeder-peleti-2mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels, kukuruz ili pelet na vlas; klen na glistu.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja. Duboka drinska voda ostaje '
        'hladna — sitan 2mm pelet i umerena aroma.',
    loading:
        'Method: 3 punjenja za start, pa zamena na 12–15 min. Hladna duboka voda — '
        'drži kompaktno hranilište.',
  ),
  WaterCombo(
    waterName: 'Jezero Perućac',
    waterType: 'lake',
    season: Season.jesen,
    species: {'deverika', 'bodorka', 'saran', 'klen'},
    baseFoodId: 'gold-concours-primama',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi, kasteri ili kukuruz.',
    prep:
        'Voda:smesa ~1:3,5, odmori 25 min, fino prosej. Jesen — duboka hladna voda, '
        'fina tamna smeša koja drži pri dnu; smanjena količina.',
    loading:
        'Početak: 3 hranilice, pa retka dopuna na 12 min. Voda se brzo hladi — riba '
        'u dubini, hrani malo.',
  ),
  WaterCombo(
    waterName: 'Jezero Perućac',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili jedan sitan crv.',
    prep:
        'Voda:smesa ~1:4, odmori 30 min, vrlo fino prosej. Duboka hladna akumulacija '
        'zimi — minimum hrane, tamna fina smeša bez aroma.',
    loading:
        'Početak: 1–2 male hranilice, pa vrlo retka dopuna na 15–20 min. Ledeno i '
        'duboko — jedva hraniti, ujed redak.',
  ),
  WaterCombo(
    waterName: 'Gružansko jezero',
    waterType: 'lake',
    season: Season.prolece,
    species: {'saran', 'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'feeder-serija-carp-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; kukuruz za šarana i babušku.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Akumulacija — proletnja voda umereno '
        'hladna, srednje laka smeša koja pravi oblak.',
    loading:
        'Početak: 5–6 hranilica, pa dopuna na 6–8 min. Proleće — riba se budi, '
        'umereno hranjenje.',
  ),
  WaterCombo(
    waterName: 'Gružansko jezero',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'babuska', 'deverika'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '50 : 50',
    pelletId: 'metod-feeder-peleti-4mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels/wafter, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja, pakuj na frame oko mamca. '
        'Toplo — jak riblji profil i krupniji 4mm pelet za šarana.',
    loading:
        'Method: 4 punjenja za start na isto mesto, pa zamena na 10–15 min. Leto — '
        'jak trag, method drži kompaktno.',
  ),
  WaterCombo(
    waterName: 'Gružansko jezero',
    waterType: 'lake',
    season: Season.jesen,
    species: {'saran', 'deverika', 'babuska', 'bodorka'},
    baseFoodId: 'primama-specijal-saran-babuska-linjak-25kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Kukuruz, crvi ili kasteri.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — baza za šarana/babušku + finiji '
        'Magic za belu ribu; srednja granulacija.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda '
        'hladi.',
  ),
  WaterCombo(
    waterName: 'Gružansko jezero',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna i fina smeša; akumulacija hladna i bistra.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 12–15 min. Hladno — riba '
        'jede malo, ne prehranjuj.',
  ),
  WaterCombo(
    waterName: 'Jezero Ćelije',
    waterType: 'lake',
    season: Season.prolece,
    species: {'saran', 'deverika', 'bodorka'},
    baseFoodId: 'feeder-serija-carp-2-5-kg',
    secondFoodId: 'gold-concours-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-deverika-700g'],
    hookbait: 'Crvi i kasteri; kukuruz za šarana.',
    prep:
        'Voda:smesa ~1:3, odmori 20–25 min. Akumulacija — proletnja voda još hladna, '
        'srednje laka smeša koja pravi blag oblak.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Proleće — riba se budi, umereno '
        'hranjenje.',
  ),
  WaterCombo(
    waterName: 'Jezero Ćelije',
    waterType: 'lake',
    season: Season.leto,
    species: {'saran', 'deverika', 'bodorka'},
    baseFoodId: 'method-feeder-primama-750g-traper',
    secondFoodId: 'gst-method-feeder-riblje-brasno',
    mixRatio: '50 : 50',
    pelletId: 'metod-feeder-peleti-4mm',
    additiveIds: ['buster', 'expert-betain-200g-traper'],
    hookbait: 'Dambels, kukuruz ili pelet na vlas.',
    prep:
        'Method: navlaži do lepljivosti, bez odmaranja, pakuj na frame oko mamca. '
        'Toplo — jak riblji profil i 4mm pelet za šarana.',
    loading:
        'Method: 4 punjenja za start na isto mesto, pa zamena na 10–15 min. Leto — '
        'jak trag, method drži kompaktno hranilište.',
  ),
  WaterCombo(
    waterName: 'Jezero Ćelije',
    waterType: 'lake',
    season: Season.jesen,
    species: {'saran', 'deverika', 'bodorka'},
    baseFoodId: 'primama-specijal-saran-babuska-linjak-25kg',
    secondFoodId: 'gold-magic-primama',
    mixRatio: '60 : 40',
    additiveIds: ['melasa-traper'],
    hookbait: 'Kukuruz, crvi ili kasteri.',
    prep:
        'Voda:smesa ~1:3, odmori 25 min. Jesen — baza za šarana + finiji Magic za '
        'belu ribu; srednja granulacija za dublju vodu.',
    loading:
        'Početak: 5 hranilica, pa dopuna na 6–8 min. Smanji količinu kako voda '
        'hladi.',
  ),
  WaterCombo(
    waterName: 'Jezero Ćelije',
    waterType: 'lake',
    season: Season.zima,
    species: {'deverika', 'bodorka'},
    baseFoodId: 'zimska-primama-fish-mix-750g-f',
    secondFoodId: 'gold-expert-primama',
    mixRatio: '70 : 30',
    hookbait: 'Trzalica ili sitan crv.',
    prep:
        'Voda:smesa ~1:3,5, odmori 30 min, fino prosej. Zima — minimalno hrane, '
        'tamna i fina smeša; akumulacija hladna i bistra.',
    loading:
        'Početak: 2–3 male hranilice, pa retka dopuna na 15 min. Hladno i bistro — '
        'vrlo diskretno hranjenje.',
  ),
];

/// Ribolovna sezona iz meseca (gruba podela, severna hemisfera).
Season seasonForMonth(int month) {
  if (month == 12 || month <= 2) return Season.zima;
  if (month <= 5) return Season.prolece;
  if (month <= 8) return Season.leto;
  return Season.jesen;
}

/// Kurirani combo za datu vodu + sezonu, ili `null` ako voda nije pokrivena
/// (fallback tada ide na algoritamski `BaitRecommender`).
///
/// [waterName] mora biti tačno ime iz `serbia_waters.json` ('n' polje).
WaterCombo? comboFor(String? waterName, Season season) {
  if (waterName == null) return null;
  for (final c in traperCombos) {
    if (c.waterName == waterName && c.season == season) return c;
  }
  return null;
}
