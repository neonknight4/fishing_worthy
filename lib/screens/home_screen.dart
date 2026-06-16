import 'package:flutter/material.dart';
import '../models/fishing_score.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/favorites_service.dart';
import '../services/recent_searches_service.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';
import 'result_screen.dart';
import 'waters_list_screen.dart';
import 'regulations_screen.dart';
import 'diary_list_screen.dart';
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

  void _openResult() {
    if (_forecasts.isEmpty || _selectedLocation == null) return;
    final forecast = _forecasts[_selectedDayIndex];
    final score = FishingScore.calculate(forecast, waterLevel: _waterLevelForecast);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          location: _selectedLocation!,
          waterLevel: _waterLevelForecast,
          selectedWaterBody: _selectedWaterBody,
        ),
      ),
    ).then((_) => _favService.load().then((r) => setState(() => _favorites = r)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildHeader(),
          if (_searchResults.isNotEmpty) _buildSearchDropdown()
          else if (_showRecent) _buildRecentDropdown(),
          if (_error != null) _buildError(),
          Expanded(child: _loading ? _buildLoading() : _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF01579B), Color(0xFF00695C)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎣', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  const Text(
                    'FishingWorthy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Prognoza uslova za pecanje',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Grad, reka, jezero...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 22),
                        suffixIcon: _searching
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchResults = []);
                                    },
                                  )
                                : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: _searchLocations,
                      onSubmitted: (_) => _searchFocus.unfocus(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _GpsButton(onTap: _loading ? null : _useGps),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_favorites.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'OMILJENE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: Colors.amber.shade700,
                ),
              ),
            ),
            ..._favorites.map(
              (loc) => InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _selectSearchResult(loc),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark, color: Colors.amber.shade600, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              'NEDAVNE PRETRAGE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          ..._recentSearches.map(
            (loc) => InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _selectSearchResult(loc),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    Icon(Icons.history, color: Colors.grey.shade400, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(loc.name, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _searchResults
            .map(
              (loc) => InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _selectSearchResult(loc),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF0277BD), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(loc.name, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 14),
          Text(
            'Učitavam prognozu...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌊', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            const Text(
              'Pronađi idealno mesto\nza pecanje',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A237E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unesi naziv mesta ili pritisni GPS da dobiješ prognozu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_pin, color: Color(0xFF0277BD), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedWaterBody?.name ?? _selectedLocation!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedWaterBody != null)
                      Text(
                        _selectedLocation!.name,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'ODABERI DAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _forecasts.length,
              separatorBuilder: (context, i2) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = _forecasts[i];
                final isSelected = i == _selectedDayIndex;
                final dayName = i == 0 ? 'Danas' : _dayNames[day.date.weekday % 7];
                final dateStr = '${day.date.day}.${day.date.month}.';

                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0277BD), Color(0xFF00695C)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF0277BD).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.06),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedLocation != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openWatersList,
                    icon: const Text('📋', style: TextStyle(fontSize: 15)),
                    label: const Text('Lista voda', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0277BD),
                      side: const BorderSide(color: Color(0xFF0277BD)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Text('🗺', style: TextStyle(fontSize: 15)),
                    label: const Text('Karta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0277BD),
                      side: const BorderSide(color: Color(0xFF0277BD)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegulationsScreen()),
              ),
              icon: const Text('📏', style: TextStyle(fontSize: 16)),
              label: const Text(
                'Lovostaj i dozvoljene mere',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00695C),
                side: const BorderSide(color: Color(0xFF00695C)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiaryListScreen()),
              ),
              icon: const Text('📖', style: TextStyle(fontSize: 16)),
              label: const Text(
                'Pecaroški dnevnik',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5D4037),
                side: const BorderSide(color: Color(0xFF5D4037)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (_waterBodies.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'OBLIŽNJE VODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
                if (_waterLevelLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _waterBodies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final wb = _waterBodies[i];
                  final isRiver = wb.type == 'river';
                  final isSelected = _selectedWaterBody?.name == wb.name;
                  final baseColor = isRiver ? const Color(0xFF0277BD) : const Color(0xFF2E7D32);
                  final bgColor = isRiver ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
                  final borderColor = isRiver ? const Color(0xFF90CAF9) : const Color(0xFFA5D6A7);
                  return GestureDetector(
                    onTap: _waterLevelLoading ? null : () => _selectWaterBody(wb),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? baseColor : bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? baseColor : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: baseColor.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isRiver ? '🏞' : '🏖', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wb.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : baseColor,
                                ),
                              ),
                              Text(
                                '${wb.distanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white70 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _waterLevelLoading ? null : _openResult,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.45),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎣', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Text(
                    'Proveri stanje za pecanje',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _GpsButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: active ? 0.22 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: active ? 0.5 : 0.2),
          ),
        ),
        child: Icon(
          Icons.my_location,
          color: active ? Colors.white : Colors.white38,
          size: 24,
        ),
      ),
    );
  }
}
