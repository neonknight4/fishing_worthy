import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/fish_icons.dart';
import '../utils/moon_calc.dart';
import '../widgets/components.dart';

class DiaryEntryScreen extends StatefulWidget {
  final DiaryEntry entry;
  final bool isNew;

  const DiaryEntryScreen({super.key, required this.entry, required this.isNew});

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  static const _maxPhotos = 5;
  final _service = DiaryService();
  final _picker = ImagePicker();
  late TextEditingController _technique, _bait, _notes;
  late List<CatchItem> _catches;
  late List<String> _photos;
  late DateTime _date;
  double? _air, _pressure, _wind, _moon, _waterTemp;
  bool _saving = false;
  bool _fetchingWx = false;

  @override
  void initState() {
    super.initState();
    _technique = TextEditingController(text: widget.entry.technique ?? '');
    _bait = TextEditingController(text: widget.entry.bait ?? '');
    _notes = TextEditingController(text: widget.entry.notes ?? '');
    _catches = [...widget.entry.catches];
    _photos = [...widget.entry.photos];
    _date = widget.entry.date;
    _air = widget.entry.airTemp;
    _pressure = widget.entry.pressure;
    _wind = widget.entry.windSpeed;
    _moon = widget.entry.moonPhase;
    _waterTemp = widget.entry.waterTempReal;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      helpText: 'Datum izlaska',
    );
    if (picked == null || _sameDay(picked, _date)) return;
    setState(() {
      _date = picked;
      _moon = MoonCalc.phase(picked);
    });
    _refetchConditions();
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Povuci uslove za izabrani (prošli) datum na koordinatama izlaska.
  Future<void> _refetchConditions() async {
    final e = widget.entry;
    if (e.lat == null || e.lon == null) return;
    setState(() => _fetchingWx = true);
    final day = await WeatherService().fetchDay(e.lat!, e.lon!, _date);
    if (!mounted) return;
    setState(() {
      if (day != null) {
        _air = day.avgTemperature;
        _pressure = day.avgPressure;
        _wind = day.avgWindSpeed;
      }
      // Istorijska temp vode (RHMZ) nije dostupna za prošle dane.
      if (!_sameDay(_date, DateTime.now())) _waterTemp = null;
      _fetchingWx = false;
    });
  }

  @override
  void dispose() {
    _technique.dispose();
    _bait.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final e = widget.entry.copyWith(
      date: _date,
      technique: _technique.text.trim().isEmpty ? null : _technique.text.trim(),
      bait: _bait.text.trim().isEmpty ? null : _bait.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      catches: _catches,
      photos: _photos,
      airTemp: _air,
      pressure: _pressure,
      windSpeed: _wind,
      moonPhase: _moon,
      waterTempReal: _waterTemp,
    );
    if (widget.isNew) {
      await _service.insert(e);
    } else {
      await _service.update(e);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addCatch() async {
    final item = await showModalBottomSheet<CatchItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCatchSheet(),
    );
    if (item != null) setState(() => _catches.add(item));
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourceSheet(),
    );
    if (src == null) return;
    final x = await _picker.pickImage(source: src, maxWidth: 1600, imageQuality: 80);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'diary_photos'));
    if (!await photosDir.exists()) await photosDir.create(recursive: true);
    final dest = p.join(photosDir.path, '${DateTime.now().millisecondsSinceEpoch}_${p.basename(x.path)}');
    await File(x.path).copy(dest);
    if (mounted) setState(() => _photos.add(dest));
  }

  void _removePhoto(int i) {
    final path = _photos[i];
    setState(() => _photos.removeAt(i));
    File(path).delete().catchError((_) => File(path));
  }

  String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}.';

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: widget.isNew ? 'Novi izlazak' : 'Izmena unosa',
            subtitle: 'Zabeleži ulov',
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              children: [
                _headerCard(e),
                const SizedBox(height: 14),
                _conditionsCard(e),
                const SizedBox(height: 14),
                _catchesSection(),
                const SizedBox(height: 14),
                _photosSection(),
                const SizedBox(height: 14),
                _textField('Tehnika', _technique, 'npr. feeder, varalica, plovak'),
                const SizedBox(height: 12),
                _textField('Mamac', _bait, 'npr. glista, kukuruz, boila'),
                const SizedBox(height: 12),
                _textField('Beleške', _notes, 'Komentar dana…', lines: 4),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: AppButton(
                _saving ? 'Čuvam…' : 'Sačuvaj izlazak',
                icon: Icons.check,
                block: true,
                large: true,
                onTap: _saving ? null : _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(DiaryEntry e) {
    final c = context.c;
    return AppCard(
      onTap: _pickDate,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: c.water),
          const SizedBox(width: 8),
          Text(_fmtDate(_date), style: context.display(size: 15, weight: FontWeight.w700)),
          const SizedBox(width: 6),
          Icon(Icons.edit, size: 14, color: c.faint),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(e.location, style: context.ui(size: 13, weight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                if (e.water != null)
                  Text(e.water!, style: context.ui(size: 12, weight: FontWeight.w600, color: c.water), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionsCard(DiaryEntry e) {
    final c = context.c;
    final items = <String>[];
    if (_air != null) items.add('🌡 ${_air!.toStringAsFixed(0)}°C');
    if (_waterTemp != null) items.add('💧 ${_waterTemp!.toStringAsFixed(1)}°C vode');
    if (_pressure != null) items.add('📊 ${_pressure!.toStringAsFixed(0)} mbar');
    if (_wind != null) items.add('💨 ${_wind!.toStringAsFixed(0)} km/h');
    if (e.waterTrend != null) items.add('🌊 ${e.waterTrend!}');
    if (_moon != null) items.add('🌙 ${_moonLabel(_moon!)}');
    if (items.isEmpty && !_fetchingWx) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('USLOVI TOG DANA', style: context.ui(size: 10, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.2)),
              const Spacer(),
              if (_fetchingWx)
                const SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((it) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: c.surface3, borderRadius: BorderRadius.circular(10)),
                  child: Text(it, style: context.ui(size: 12, weight: FontWeight.w600)),
                )).toList(),
          ),
        ],
      ),
    );
  }

  String _moonLabel(double phase) {
    if (phase < 0.03 || phase > 0.97) return 'Mlad mesec';
    if (phase < 0.22) return 'Mladi srp';
    if (phase < 0.28) return 'Prva četvrt';
    if (phase < 0.47) return 'Rastući';
    if (phase < 0.53) return 'Pun mesec';
    if (phase < 0.72) return 'Opadajući';
    if (phase < 0.78) return 'Zadnja četvrt';
    return 'Stari srp';
  }

  Widget _catchesSection() {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ULOV', style: context.ui(size: 11, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.2)),
              const Spacer(),
              if (_catches.isNotEmpty)
                Text('${_catches.fold<int>(0, (s, ct) => s + ct.count)} kom',
                    style: context.ui(size: 12, weight: FontWeight.w700, color: c.green)),
            ],
          ),
          const SizedBox(height: 8),
          if (_catches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Nema unetog ulova', style: context.ui(size: 13, weight: FontWeight.w500, color: c.faint)),
            )
          else
            ..._catches.asMap().entries.map((entry) => _catchRow(entry.key, entry.value)),
          const SizedBox(height: 6),
          AppButton('Dodaj ribu', icon: Icons.add, kind: BtnKind.outline, onTap: _addCatch),
        ],
      ),
    );
  }

  Widget _catchRow(int i, CatchItem ct) {
    final c = context.c;
    final icon = fishIconAsset(ct.species);
    final extra = <String>[];
    if (ct.maxWeightKg != null) extra.add('${ct.maxWeightKg} kg');
    if (ct.maxLengthCm != null) extra.add('${ct.maxLengthCm!.toStringAsFixed(0)} cm');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: icon != null ? Image.asset(icon, fit: BoxFit.contain) : const Text('🐟', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ct.species, style: context.ui(size: 14, weight: FontWeight.w600)),
                if (extra.isNotEmpty)
                  Text(extra.join(' · '), style: context.ui(size: 11, weight: FontWeight.w500, color: c.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: c.green.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: Text('${ct.count} kom', style: context.ui(size: 12, weight: FontWeight.w700, color: c.green)),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: c.faint),
            onPressed: () => setState(() => _catches.removeAt(i)),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, String hint, {int lines = 1}) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: context.ui(size: 12, weight: FontWeight.w800, color: c.muted, letterSpacing: 0.4)),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          maxLines: lines,
          style: context.ui(size: 15, weight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.ui(size: 14, weight: FontWeight.w500, color: c.faint),
            filled: true,
            fillColor: c.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: c.line)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: c.green)),
          ),
        ),
      ],
    );
  }

  Widget _photosSection() {
    final c = context.c;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('FOTOGRAFIJE', style: context.ui(size: 11, weight: FontWeight.w800, color: c.muted, letterSpacing: 1.2)),
              const Spacer(),
              Text('${_photos.length}/$_maxPhotos', style: context.ui(size: 12, weight: FontWeight.w700, color: c.muted)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _photos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_photos[i]), width: 76, height: 76, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                              width: 76, height: 76, color: c.surface3,
                              child: Icon(Icons.broken_image, color: c.faint, size: 24))),
                    ),
                    Positioned(
                      top: 2, right: 2,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_photos.length < _maxPhotos)
                GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      color: c.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.line),
                    ),
                    child: Icon(Icons.add_a_photo_outlined, color: c.green, size: 24),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Izbor izvora slike (kamera / galerija).
class _SourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          AppButton('Kamera', icon: Icons.photo_camera, block: true,
              onTap: () => Navigator.pop(context, ImageSource.camera)),
          const SizedBox(height: 8),
          AppButton('Galerija', icon: Icons.photo_library_outlined, kind: BtnKind.outline, block: true,
              onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ],
      ),
    );
  }
}

// ── Add-catch bottom sheet ────────────────────────────────────────────────

class _AddCatchSheet extends StatefulWidget {
  const _AddCatchSheet();
  @override
  State<_AddCatchSheet> createState() => _AddCatchSheetState();
}

class _AddCatchSheetState extends State<_AddCatchSheet> {
  String? _species;
  int _count = 1;
  final _weight = TextEditingController();
  final _length = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _length.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text('Dodaj ribu', style: context.display(size: 18)),
          const SizedBox(height: 14),
          Text('VRSTA', style: context.ui(size: 12, weight: FontWeight.w800, color: c.muted, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: iconFishNames.map((name) {
              final sel = _species == name;
              final icon = fishIconAsset(name);
              return GestureDetector(
                onTap: () => setState(() => _species = name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? c.green.withValues(alpha: 0.12) : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? c.green : c.line, width: sel ? 2 : 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) SizedBox(width: 22, height: 22, child: Image.asset(icon, fit: BoxFit.contain)),
                      const SizedBox(width: 5),
                      Text(name, style: context.ui(size: 13, weight: FontWeight.w600, color: sel ? c.green : c.ink)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Broj komada', style: context.ui(size: 13, weight: FontWeight.w600)),
              const Spacer(),
              _stepBtn(Icons.remove, () => setState(() { if (_count > 1) _count--; })),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('$_count', style: context.display(size: 20, weight: FontWeight.w800)),
              ),
              _stepBtn(Icons.add, () => setState(() => _count++)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _numField(_weight, 'Najveća (kg)')),
              const SizedBox(width: 12),
              Expanded(child: _numField(_length, 'Najveća (cm)')),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            'Dodaj',
            block: true,
            large: true,
            onTap: _species == null
                ? null
                : () => Navigator.pop(
                      context,
                      CatchItem(
                        species: _species!,
                        count: _count,
                        maxWeightKg: double.tryParse(_weight.text.replaceAll(',', '.')),
                        maxLengthCm: double.tryParse(_length.text.replaceAll(',', '.')),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.line)),
        child: Icon(icon, size: 20, color: c.green),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String hint) {
    final c = context.c;
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: context.ui(size: 14, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.ui(size: 12, weight: FontWeight.w500, color: c.faint),
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.green)),
      ),
    );
  }
}
