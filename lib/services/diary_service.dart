import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'fishing_diary.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            location TEXT NOT NULL,
            water TEXT,
            lat REAL, lon REAL,
            air_temp REAL, pressure REAL, wind REAL,
            water_temp REAL,
            water_trend TEXT, moon_phase REAL,
            technique TEXT, bait TEXT, notes TEXT,
            catches TEXT,
            created_at INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('ALTER TABLE diary ADD COLUMN water_temp REAL');
        }
      },
    );
    return _db!;
  }

  Future<int> insert(DiaryEntry e) async {
    final db = await _open();
    return db.insert('diary', e.toMap());
  }

  Future<void> update(DiaryEntry e) async {
    final db = await _open();
    await db.update('diary', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> delete(int id) async {
    final db = await _open();
    await db.delete('diary', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DiaryEntry>> all() async {
    final db = await _open();
    final rows = await db.query('diary', orderBy: 'date DESC, id DESC');
    return rows.map(DiaryEntry.fromMap).toList();
  }
}
