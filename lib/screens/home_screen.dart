import 'package:flutter/material.dart';
import '../logic/technique_advisor.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/favorites_service.dart';
import '../services/recent_searches_service.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/components.dart';
import 'result_screen.dart';
import 'waters_list_screen.dart';
import 'regulations_screen.dart';
import 'favorites_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _weatherService = WeatherService();
  final _waterService = WaterService();
  final _recentService = RecentSearchesService();
  final _favService = FavoritesService();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  LocationInfo? _selectedLocation;
  List<LocationInfo> _searchResults = [];
  List<LocationInfo> _recentSearches = [];
  List<LocationInfo> _favorites = [];
  List<DailyForecast> _forecasts = [];
  List<WaterBody> _waterBodies = [];
  WaterBody? _selectedWaterBody;
  WaterLevelForecast? _waterLevelForecast;
  int _selectedDayIndex = 0;
  bool _loading = false;
  bool _waterLevelLoading = false;
  bool _searching = false;
  bool _showRecent = false;
  String? _error;
  /// != null → prognoza je iz offline keša; vreme je kad je upisana.
  DateTime? _cacheStamp;

  static const _dayNames = ['Ned', 'Pon', 'Uto', 'Sre', 'Čet', 'Pet', 'Sub'];

  @override
  void initState() {
    super.initState();
    _recentService.load().then((r) => setState(() => _recentSearches = r));
    _favService.load().then((r) => setState(() => _favorites = r));
    _searchFocus.addListener(() {
      setState(() => _showRecent =
          _searchFocus.hasFocus && _searchController.text.isEmpty && _recentSearches.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _useGps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loc = await _locationService.getCurrentLocation();
      await _loadForecast(loc);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // Major Serbian rivers — preferred for auto-selected vodostaj when nearby.
  static const _majorRivers = {
    'dunav', 'sava', 'tisa', 'velika morava', 'zapadna morava',
    'južna morava', 'juzna morava', 'drina', 'ibar', 'tamiš', 'tamis',
    'begej', 'nišava', 'nisava', 'kolubara', 'timok',
  };

  // Vodostaj (river discharge) is meaningful only for rivers. Prefer the
  // nearest river; among rivers, favour major ones within ~10km.
  WaterBody? _pickAutoWater(List<WaterBody> bodies) {
    if (bodies.isEmpty) return null;
    final rivers = bodies.where((b) => b.type == 'river').toList();
    if (rivers.isEmpty) return bodies.first;

    WaterBody best = rivers.first;
    double bestScore = double.infinity;
    for (final r in rivers) {
      final isMajor = _majorRivers.contains(r.name.toLowerCase());
      final score = r.distanceKm - (isMajor ? 10.0 : 0.0);
      if (score < bestScore) {
        bestScore = score;
        best = r;
      }
    }
    return best;
  }

  Future<void> _loadForecast(LocationInfo loc) async {
    final forecastFuture = _weatherService.fetchForecast(loc.latitude, loc.longitude);
    final waterFuture = _waterService
        .fetchNearbyWaterBodies(loc.latitude, loc.longitude)
        .catchError((_) => <WaterBody>[]);

    final results = await Future.wait([forecastFuture, waterFuture]);

    final forecasts = results[0] as List<DailyForecast>;
    final waterBodies = results[1] as List<WaterBody>;

    final autoSelected = _pickAutoWater(waterBodies);
    final wlLat = autoSelected?.latitude ?? loc.latitude;
    final wlLon = autoSelected?.longitude ?? loc.longitude;
    final waterLevel = await _waterService.fetchWaterLevelForecast(
      wlLat, wlLon,
      waterBodyName: autoSelected?.name,
    );

    await _recentService.save(loc);
    final updatedRecent = await _recentService.load();

    setState(() {
      _cacheStamp = _weatherService.servedFromCacheAt;
      _selectedLocation = loc;
      _forecasts = forecasts;
      _waterBodies = waterBodies;
      _selectedWaterBody = autoSelected;
      _waterLevelForecast = waterLevel;
      _selectedDayIndex = 0;
      _searchResults = [];
      _recentSearches = updatedRecent;
      _showRecent = false;
      _searchController.clear();
    });
  }

  Future<void> _selectWaterBody(WaterBody wb) async {
    setState(() {
      _selectedWaterBody = wb;
      _waterLevelLoading = true;
    });
    final newLevel = await _waterService.fetchWaterLevelForecast(
      wb.latitude, wb.longitude,
      waterBodyName: wb.name,
    );
    setState(() {
      _waterLevelForecast = newLevel;
      _waterLevelLoading = false;
    });
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showRecent = _searchFocus.hasFocus && _recentSearches.isNotEmpty;
      });
      return;
    }
    setState(() {
      _searchResults = [];
      _showRecent = false;
      _searching = query.length >= 2;
    });
    if (query.length < 2) return;
    setState(() => _searching = true);
    try {
      final results = await _locationService.searchLocation(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _searching = false);
    }
  }

  void _selectSearchResult(LocationInfo loc) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _loadForecast(loc);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openWatersList() async {
    if (_selectedLocation == null) return;
    final selected = await Navigator.push<WaterBody>(
      context,
      MaterialPageRoute(
        builder: (_) => WatersListScreen(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationName: _selectedLocation!.name,
        ),
      ),
    );
    if (selected != null) {
      await _selectWaterBody(selected);
    }
  }

  Future<void> _openMap() async {
    if (_selectedLocation == null) return;
    final selected = await Navigator.push<WaterBody>(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationName: _selectedLocation!.name,
        ),
      ),
    );
    if (selected != null) {
      await _selectWaterBody(selected);
    }
  }

  /// Vodostaj (protok) nema smisla za stajaće vode — ne ulazi u ocenu.
  WaterLevelForecast? get _scoringLevel =>
      _selectedWaterBody?.type == 'lake' ? null : _waterLevelForecast;

  /// Skor za jedan dan iz prognoze. Isti ulaz za day-chipove i za Result.
  FishingScore _scoreFor(DailyForecast f) =>
      FishingScore.calculate(f, waterLevel: _scoringLevel);

  void _openResult() {
    if (_forecasts.isEmpty || _selectedLocation == null) return;
    final forecast = _forecasts[_selectedDayIndex];
    final wl = _scoringLevel;
    final score = _scoreFor(forecast);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          location: _selectedLocation!,
          waterLevel: wl,
          selectedWaterBody: _selectedWaterBody,
        ),
      ),
    ).then((_) => _favService.load().then((r) => setState(() => _favorites = r)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildHeader(),
          if (_searchResults.isNotEmpty)
            _buildSearchDropdown()
          else if (_showRecent)
            _buildRecentDropdown(),
          if (_error != null) _buildError(),
          if (_cacheStamp != null && !_loading) _buildStaleBanner(),
          Expanded(child: _loading ? _buildLoading() : _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final c = context.c;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
        child: Column(
          children: [
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Upecaj',
                    style: context.display(size: 26, weight: FontWeight.w800, color: c.green),
                    children: [
                      TextSpan(text: '!', style: context.display(size: 26, weight: FontWeight.w800, color: c.gold)),
                    ],
                  ),
                ),
                const Spacer(),
                AppIconButton(
                  themeController.isDark(context) ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  ghost: true,
                  onTap: () => themeController.toggle(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: c.shadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Icon(Icons.search, color: c.faint, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: context.ui(size: 15, weight: FontWeight.w600),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintText: 'Grad, reka, jezero…',
                        hintStyle: context.ui(size: 15, weight: FontWeight.w600, color: c.faint),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: _searchLocations,
                      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  if (_searching)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  else if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                      child: Icon(Icons.close, size: 18, color: c.muted),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDropdown() {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_favorites.isNotEmpty) ...[
            _dropdownLabel('OMILJENE', c.gold),
            ..._favorites.map((loc) => _dropdownRow(Icons.bookmark, loc, c.gold)),
            Divider(height: 1, color: c.line),
          ],
          _dropdownLabel('NEDAVNE PRETRAGE', c.muted),
          ..._recentSearches.map((loc) => _dropdownRow(Icons.history, loc, c.faint)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown() {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: c.shadow,
      ),
      child: Column(
        children: _searchResults.map((loc) => _dropdownRow(Icons.location_on, loc, c.water)).toList(),
      ),
    );
  }

  Widget _dropdownLabel(String text, Color color) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Text(text, style: context.ui(size: 10, weight: FontWeight.w800, color: color, letterSpacing: 1.4)),
      );

  Widget _dropdownRow(IconData icon, LocationInfo loc, Color iconColor) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectSearchResult(loc),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(loc.name, style: context.ui(size: 14, weight: FontWeight.w600))),
            ],
          ),
        ),
      );

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: WarnBanner(icon: Icons.error_outline, title: 'Greška', message: _error!),
    );
  }

  /// Kad nema signala, prognoza dolazi sa diska — korisnik na vodi mora da zna
  /// da gleda stare podatke, a ne trenutno stanje.
  Widget _buildStaleBanner() {
    final t = _cacheStamp!;
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final sameDay = DateUtils.isSameDay(t, DateTime.now());
    final when = sameDay ? 'danas u $hh:$mm' : '${t.day}.${t.month}. u $hh:$mm';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: WarnBanner(
        icon: Icons.cloud_off,
        title: 'Nema mreže — offline podaci',
        message: 'Prikazano je zadnje preuzeto stanje ($when). Osveži kad uhvatiš signal.',
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text('Učitavam prognozu…', style: context.ui(size: 14, color: context.c.muted)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedLocation == null || _forecasts.isEmpty) {
      return _buildEmptyState();
    }
    return _buildForecastContent();
  }

  Widget _buildEmptyState() {
    final c = context.c;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.l),
              boxShadow: c.shadowLg,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
                colors: [c.green2, c.greenInk],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gde pecaš\ndanas?', style: context.display(size: 26, color: c.onGreen)),
                const SizedBox(height: 8),
                Text('Izaberi vodu i proveri stanje.',
                    style: context.ui(size: 13.5, weight: FontWeight.w600, color: c.onGreen.withValues(alpha: 0.82))),
                const SizedBox(height: 16),
                AppButton('Moja lokacija',
                    icon: Icons.my_location,
                    large: true,
                    block: true,
                    kind: BtnKind.ghost,
                    onTap: _loading ? null : _useGps),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Image.asset('assets/brand/fish-teal.png', width: 58, height: 44, fit: BoxFit.contain),
                const SizedBox(height: 14),
                Text('Pronađi idealno mesto', style: context.display(size: 18)),
                const SizedBox(height: 6),
                Text('Unesi naziv mesta ili pritisni „Moja lokacija".',
                    textAlign: TextAlign.center,
                    style: context.ui(size: 13.5, weight: FontWeight.w500, color: c.muted, height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastContent() {
    final c = context.c;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // izabrana lokacija
          Row(
            children: [
              Icon(Icons.location_pin, color: c.water, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedWaterBody?.name ?? _selectedLocation!.name,
                        style: context.display(size: 17), overflow: TextOverflow.ellipsis),
                    if (_selectedWaterBody != null)
                      Text(_selectedLocation!.name,
                          style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted),
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBriefing(),
          const SectionLabel('Odaberi dan'),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _forecasts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = _forecasts[i];
                final isSelected = i == _selectedDayIndex;
                final dayName = i == 0 ? 'Danas' : _dayNames[day.date.weekday % 7];
                final dateStr = '${day.date.day}.${day.date.month}.';
                // Skor stoji na čipu da se najbolji dan u nedelji vidi bez ulaska
                // u Result — sedam poziva `calculate` po rebuild-u, sve sinhrono.
                final dayScore = _scoreFor(day).score;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: isSelected ? c.green : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: c.shadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayName,
                            style: context.ui(
                                size: 10,
                                weight: FontWeight.w700,
                                color: isSelected ? c.onBrand.withValues(alpha: 0.85) : c.muted)),
                        const SizedBox(height: 2),
                        Text(dateStr,
                            style: context.display(
                                size: 13.5, weight: FontWeight.w700, color: isSelected ? c.onBrand : c.ink)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: c.score(dayScore),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$dayScore',
                              style: context.ui(
                                  size: 11.5, weight: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // alati
          const SectionLabel('Alati'),
          Row(
            children: [
              _toolButton(Icons.map_outlined, 'Mapa', _openMap),
              const SizedBox(width: 11),
              _toolButton(Icons.list_alt, 'Lista voda', _openWatersList),
              const SizedBox(width: 11),
              _toolButton(Icons.bookmark_border, 'Omiljene',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
              const SizedBox(width: 11),
              _toolButton(Icons.gavel, 'Propisi',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegulationsScreen()))),
            ],
          ),
          if (_waterBodies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 26, 2, 13),
              child: Row(
                children: [
                  Text('OBLIŽNJE VODE',
                      style: context.ui(size: 12, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.7)),
                  const SizedBox(width: 9),
                  if (_waterLevelLoading)
                    const SizedBox(width: 11, height: 11, child: CircularProgressIndicator(strokeWidth: 1.5))
                  else
                    Expanded(child: Container(height: 1, color: c.line)),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _waterBodies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final wb = _waterBodies[i];
                  final isRiver = wb.type == 'river';
                  final isSelected = _selectedWaterBody?.name == wb.name;
                  return GestureDetector(
                    onTap: _waterLevelLoading ? null : () => _selectWaterBody(wb),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c.green : c.surface3,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isRiver ? Icons.waves : Icons.water,
                              size: 14, color: isSelected ? c.onBrand : c.water2),
                          const SizedBox(width: 6),
                          Text('${wb.name} · ${wb.distanceKm.toStringAsFixed(1)} km',
                              style: context.ui(
                                  size: 12.5,
                                  weight: FontWeight.w700,
                                  color: isSelected ? c.onBrand : c.ink)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 28),
          AppButton('Proveri stanje za pecanje',
              icon: Icons.phishing,
              large: true,
              block: true,
              onTap: _waterLevelLoading ? null : _openResult),
        ],
      ),
    );
  }

  /// „Danas na vodi" — dnevni sažetak za trenutno izabranu vodu: skor za danas,
  /// najbolja tehnika i jedan razlog. Tap vodi na Result za danas.
  ///
  /// Skor je isti model kao na day-chipovima (procenjena temp. vode). Result
  /// ekran ga posle precizira pravom temperaturom sa RHMZ stanice, pa se broj
  /// tamo može malo razlikovati.
  Widget _buildBriefing() {
    final c = context.c;
    final today = _forecasts.first;
    final score = _scoreFor(today);
    final best = TechniqueAdvisor.advise(
      today,
      _scoringLevel,
      _selectedWaterBody,
      today.date,
    ).first;
    final line = best.positives.isNotEmpty
        ? best.positives.first
        : best.negatives.isNotEmpty
            ? best.negatives.first
            : 'Uslovi su osrednji — probaj u zoru ili sumrak.';
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        setState(() => _selectedDayIndex = 0);
        _openResult();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.score(score.score).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('${score.score}',
                style: context.display(size: 21, weight: FontWeight.w800, color: c.score(score.score))),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('DANAS NA VODI',
                        style: context.ui(size: 10, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.4)),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 18, color: c.faint),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${score.ratingLabel} · ${best.name} (${best.score})',
                    style: context.ui(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(line,
                    style: context.ui(size: 12, weight: FontWeight.w500, color: c.muted, height: 1.35)),
                if (best.targetFish.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('🐟 ${best.targetFish.take(3).join(" · ")}',
                      style: context.ui(size: 11.5, weight: FontWeight.w600, color: c.water2)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    final c = context.c;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.m),
            boxShadow: c.shadow,
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: c.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                child: Icon(icon, size: 21, color: c.green),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: context.ui(size: 11.5, weight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
