import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../utils/fish_icons.dart';

class DiaryEntryScreen extends StatefulWidget {
  final DiaryEntry entry;
  final bool isNew;

  const DiaryEntryScreen({super.key, required this.entry, required this.isNew});

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final _service = DiaryService();
  late TextEditingController _technique, _bait, _notes;
  late List<CatchItem> _catches;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _technique = TextEditingController(text: widget.entry.technique ?? '');
    _bait = TextEditingController(text: widget.entry.bait ?? '');
    _notes = TextEditingController(text: widget.entry.notes ?? '');
    _catches = [...widget.entry.catches];
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
      technique: _technique.text.trim().isEmpty ? null : _technique.text.trim(),
      bait: _bait.text.trim().isEmpty ? null : _bait.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      catches: _catches,
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

  String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}.';

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        title: Text(widget.isNew ? 'Novi unos' : 'Izmena unosa', style: const TextStyle(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _headerCard(e),
          const SizedBox(height: 16),
          _conditionsCard(e),
          const SizedBox(height: 16),
          _catchesSection(),
          const SizedBox(height: 16),
          _textField('Tehnika', _technique, 'npr. feeder, varalica, plovak'),
          const SizedBox(height: 12),
          _textField('Mamac', _bait, 'npr. glista, kukuruz, boila'),
          const SizedBox(height: 12),
          _textField('Beleške', _notes, 'Komentar dana...', lines: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_saving ? 'Čuvam...' : 'Sačuvaj unos',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(DiaryEntry e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF0277BD)),
          const SizedBox(width: 8),
          Text(_fmtDate(e.date), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(e.location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                if (e.water != null)
                  Text(e.water!, style: const TextStyle(fontSize: 12, color: Color(0xFF0277BD)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionsCard(DiaryEntry e) {
    final items = <(String, String)>[];
    if (e.airTemp != null) items.add(('🌡', '${e.airTemp!.toStringAsFixed(0)}°C'));
    if (e.waterTempReal != null) items.add(('💧', '${e.waterTempReal!.toStringAsFixed(1)}°C vode'));
    if (e.pressure != null) items.add(('📊', '${e.pressure!.toStringAsFixed(0)} hPa'));
    if (e.windSpeed != null) items.add(('💨', '${e.windSpeed!.toStringAsFixed(0)} km/h'));
    if (e.waterTrend != null) items.add(('🌊', e.waterTrend!));
    if (e.moonPhase != null) items.add(('🌙', _moonLabel(e.moonPhase!)));
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('USLOVI TOG DANA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF546E7A))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: items
                .map((it) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Text('${it.$1} ${it.$2}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                    ))
                .toList(),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ULOV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF546E7A))),
              const Spacer(),
              if (_catches.isNotEmpty)
                Text('${_catches.fold<int>(0, (s, c) => s + c.count)} kom',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
            ],
          ),
          const SizedBox(height: 8),
          if (_catches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Nema unetog ulova', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            )
          else
            ..._catches.asMap().entries.map((entry) => _catchRow(entry.key, entry.value)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _addCatch,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Dodaj ribu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catchRow(int i, CatchItem c) {
    final icon = fishIconAsset(c.species);
    final extra = <String>[];
    if (c.maxWeightKg != null) extra.add('${c.maxWeightKg} kg');
    if (c.maxLengthCm != null) extra.add('${c.maxLengthCm!.toStringAsFixed(0)} cm');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 32, height: 32,
            child: icon != null ? Image.asset(icon, fit: BoxFit.contain) : const Text('🐟', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.species, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                if (extra.isNotEmpty)
                  Text(extra.join(' · '), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
            child: Text('${c.count} kom', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
            onPressed: () => setState(() => _catches.removeAt(i)),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController c, String hint, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF546E7A))),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          maxLines: lines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
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
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          const Text('Dodaj ribu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
          const SizedBox(height: 14),
          const Text('Vrsta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF546E7A))),
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
                    color: sel ? const Color(0xFF0277BD) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? const Color(0xFF0277BD) : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) SizedBox(width: 22, height: 22, child: Image.asset(icon, fit: BoxFit.contain)),
                      const SizedBox(width: 5),
                      Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF1A237E))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Broj komada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
              const Spacer(),
              _stepBtn(Icons.remove, () => setState(() { if (_count > 1) _count--; })),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('$_count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _species == null
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Dodaj', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          child: Icon(icon, size: 20, color: const Color(0xFF0277BD)),
        ),
      );

  Widget _numField(TextEditingController c, String hint) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );
}
