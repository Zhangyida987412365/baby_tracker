import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DbHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'baby_tracker.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE baby (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            gender TEXT NOT NULL,
            birthday TEXT NOT NULL,
            weight_kg REAL NOT NULL,
            height_cm REAL NOT NULL,
            head_cm REAL NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE record (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            baby_id INTEGER NOT NULL,
            time TEXT NOT NULL,
            type TEXT NOT NULL,
            value INTEGER,
            extra TEXT NOT NULL DEFAULT '{}',
            FOREIGN KEY (baby_id) REFERENCES baby(id)
          )
        ''');
        // Insert default baby
        await db.insert('baby', {
          'name': '小米团',
          'gender': 'girl',
          'birthday': '2025-12-26',
          'weight_kg': 7.2,
          'height_cm': 65.1,
          'head_cm': 41.8,
          'is_active': 1,
        });
      },
    );
  }

  // ── Baby CRUD ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getActiveBaby() async {
    final d = await db;
    final rows = await d.query('baby', where: 'is_active = 1', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, dynamic>>> getAllBabies() async {
    final d = await db;
    return d.query('baby', orderBy: 'id ASC');
  }

  static Future<void> setActiveBaby(int id) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.update('baby', {'is_active': 0});
      await txn.update('baby', {'is_active': 1}, where: 'id = ?', whereArgs: [id]);
    });
  }

  static Future<int> insertBaby(Map<String, dynamic> baby) async {
    final d = await db;
    return d.insert('baby', baby);
  }

  static Future<void> updateBaby(int id, Map<String, dynamic> data) async {
    final d = await db;
    await d.update('baby', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteBaby(int id) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.delete('record', where: 'baby_id = ?', whereArgs: [id]);
      await txn.delete('baby', where: 'id = ?', whereArgs: [id]);
    });
  }

  // ── Record CRUD ────────────────────────────────────────────────────────────
  static Future<int> insertRecord(Map<String, dynamic> rec) async {
    final d = await db;
    return d.insert('record', rec);
  }

  static Future<List<Map<String, dynamic>>> getRecords(int babyId, {String? date, String? type, int? limit}) async {
    final d = await db;
    final where = <String>['baby_id = ?'];
    final args = <dynamic>[babyId];
    if (date != null) {
      where.add("time LIKE ?");
      args.add('$date%');
    }
    if (type != null) {
      where.add("type = ?");
      args.add(type);
    }
    return d.query('record',
      where: where.join(' AND '), whereArgs: args,
      orderBy: 'time DESC', limit: limit);
  }

  static Future<List<Map<String, dynamic>>> searchAllRecords(String query) async {
    final d = await db;
    return d.rawQuery('''
      SELECT r.*, b.name as baby_name 
      FROM record r 
      JOIN baby b ON r.baby_id = b.id 
      WHERE r.type LIKE ? OR r.extra LIKE ?
      ORDER BY r.time DESC
    ''', ['%$query%', '%$query%']);
  }

  static Future<List<Map<String, dynamic>>> getAllRecords(int babyId) async {
    final d = await db;
    return d.query('record', where: 'baby_id = ?', whereArgs: [babyId], orderBy: 'time DESC');
  }

  static Future<void> deleteRecord(int id) async {
    final d = await db;
    await d.delete('record', where: 'id = ?', whereArgs: [id]);
  }
}
