import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../utils/fish_icons.dart';
import 'diary_entry_screen.dart';
import 'diary_stats_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final _service = DiaryService();
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.all();
    if (mounted) setState(() { _entries = list; _loading = false; });
  }

  Future<void> _openEntry(DiaryEntry e) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DiaryEntryScreen(entry: e, isNew: false)),
    );
    if (changed == true) _load();
  }

  Future<void> _confirmDelete(DiaryEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Brisanje unosa'),
        content: Text('Obrisati unos od ${_fmtDate(e.date)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true && e.id != null) {
      await _service.delete(e.id!);
      _load();
    }
  }

  String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}.';

  @override
  Widget build(BuildContext context) {
    final totalCatch = _entries.fold<int>(0, (s, e) => s + e.totalCatch);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01579B),
        foregroundColor: Colors.white,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pecaroški dnevnik', style: TextStyle(fontSize: 16)),
            Text(
              _entries.isEmpty ? 'Nema unosa' : '${_entries.length} izlazaka · $totalCatch riba',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistika',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DiaryStatsScreen(entries: _entries)),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _empty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: _entries.length,
                  itemBuilder: (_, i) => _EntryCard(
                    entry: _entries[i],
                    fmtDate: _fmtDate,
                    onTap: () => _openEntry(_entries[i]),
                    onDelete: () => _confirmDelete(_entries[i]),
                  ),
                ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Dnevnik je prazan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
            const SizedBox(height: 8),
            Text(
              'Otvori prognozu za lokaciju i pritisni "Zabeleži u dnevnik" da sačuvaš izlazak sa uslovima tog dana.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final String Function(DateTime) fmtDate;
  final VoidCallback onTap, onDelete;

  const _EntryCard({required this.entry, required this.fmtDate, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 15, color: Color(0xFF0277BD)),
                  const SizedBox(width: 6),
                  Text(fmtDate(entry.date), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A237E))),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 19, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.place, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      entry.water != null ? '${entry.water} · ${entry.location}' : entry.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (entry.catches.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: entry.catches.map((c) {
                    final icon = fishIconAsset(c.species);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) SizedBox(width: 18, height: 18, child: Image.asset(icon, fit: BoxFit.contain)) else const Text('🐟', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text('${c.species} ×${c.count}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text('Bez ulova', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(entry.notes!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
