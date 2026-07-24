import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/fish_icons.dart';
import '../widgets/components.dart';
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
            child: Text('Obriši', style: TextStyle(color: context.c.coral)),
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
      body: Column(
        children: [
          PageHeader(
            title: 'Dnevnik',
            subtitle: _entries.isEmpty ? 'Nema unosa' : '${_entries.length} izlazaka · $totalCatch riba',
            showBack: true,
            actions: [
              if (_entries.isNotEmpty)
                AppIconButton(Icons.bar_chart, onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DiaryStatsScreen(entries: _entries)),
                    )),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _empty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                        itemCount: _entries.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: _EntryCard(
                            entry: _entries[i],
                            fmtDate: _fmtDate,
                            onTap: () => _openEntry(_entries[i]),
                            onDelete: () => _confirmDelete(_entries[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 56, color: c.faint),
            const SizedBox(height: 16),
            Text('Dnevnik je prazan', style: context.display(size: 18)),
            const SizedBox(height: 8),
            Text(
              'Otvori prognozu za lokaciju i pritisni „Zabeleži u dnevnik" da sačuvaš izlazak sa uslovima tog dana.',
              textAlign: TextAlign.center,
              style: context.ui(size: 13, weight: FontWeight.w500, color: c.muted, height: 1.5),
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
    final c = context.c;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 15, color: c.water),
              const SizedBox(width: 6),
              Text(fmtDate(entry.date), style: context.display(size: 15, weight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, size: 19, color: c.faint),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.place, size: 13, color: c.faint),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  entry.water != null ? '${entry.water} · ${entry.location}' : entry.location,
                  style: context.ui(size: 12, weight: FontWeight.w600, color: c.muted),
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
              children: entry.catches.map((ct) {
                final icon = fishIconAsset(ct.species);
                return Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                  decoration: BoxDecoration(color: c.surface3, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        SizedBox(width: 22, height: 22, child: Image.asset(icon, fit: BoxFit.contain))
                      else
                        const Text('🐟', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 5),
                      Text('${ct.species} ×${ct.count}',
                          style: context.ui(size: 11.5, weight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text('Bez ulova', style: context.ui(size: 12, weight: FontWeight.w500, color: c.faint)),
          ],
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('„${entry.notes!}"',
                style: context.ui(size: 12, weight: FontWeight.w500, color: c.muted, height: 1.4)
                    .copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
