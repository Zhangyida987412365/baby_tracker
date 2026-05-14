import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'db_helper.dart';
import '../utils/formatters.dart';
import '../utils/categories.dart';

// ── Baby model ──────────────────────────────────────────────────────────────
class Baby {
  final int? dbId;
  final String name;
  final String gender;
  final DateTime birthday;
  final double weightKg;
  final double heightCm;
  final double headCm;

  const Baby({
    this.dbId,
    required this.name,
    required this.gender,
    required this.birthday,
    required this.weightKg,
    required this.heightCm,
    required this.headCm,
  });

  Baby copyWith({
    int? dbId,
    String? name,
    String? gender,
    DateTime? birthday,
    double? weightKg,
    double? heightCm,
    double? headCm,
  }) {
    return Baby(
      dbId: dbId ?? this.dbId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      headCm: headCm ?? this.headCm,
    );
  }

  factory Baby.initial() => Baby(
    name: '小米团', gender: 'girl',
    birthday: DateTime(2025, 12, 26),
    weightKg: 7.2, heightCm: 65.1, headCm: 41.8,
  );

  factory Baby.fromDb(Map<String, dynamic> row) => Baby(
    dbId: row['id'] as int,
    name: row['name'] as String,
    gender: row['gender'] as String,
    birthday: DateTime.parse(row['birthday'] as String),
    weightKg: (row['weight_kg'] as num).toDouble(),
    heightCm: (row['height_cm'] as num).toDouble(),
    headCm: (row['head_cm'] as num).toDouble(),
  );

  Map<String, dynamic> toDb() => {
    'name': name, 'gender': gender,
    'birthday': birthday.toIso8601String().substring(0, 10),
    'weight_kg': weightKg, 'height_cm': heightCm, 'head_cm': headCm,
    'is_active': 1,
  };
}

// ── Record model ─────────────────────────────────────────────────────────────
class Record {
  final int? dbId;
  final int babyId;
  final DateTime time;
  final String type;
  final int? value;
  final Map<String, dynamic> extra;

  const Record({
    this.dbId,
    required this.babyId,
    required this.time,
    required this.type,
    this.value,
    this.extra = const {},
  });

  factory Record.fromDb(Map<String, dynamic> row) => Record(
    dbId: row['id'] as int,
    babyId: row['baby_id'] as int,
    time: DateTime.parse(row['time'] as String),
    type: row['type'] as String,
    value: row['value'] as int?,
    extra: jsonDecode(row['extra'] as String? ?? '{}'),
  );

  Map<String, dynamic> toDb() => {
    'baby_id': babyId,
    'time': time.toIso8601String(),
    'type': type,
    'value': value,
    'extra': jsonEncode(extra),
  };

  Map<String, dynamic> toJson() => {
    'id': dbId, 'time': time.toIso8601String(),
    'type': type, 'value': value, 'extra': extra,
  };
}

// ── App State with SQLite persistence ─────────────────────────────────────────
class AppState extends ChangeNotifier {
  Baby _baby = Baby.initial();
  List<Baby> _babies = [];
  List<Record> _records = [];
  bool _loaded = false;

  // ── Reminder Settings ──────────────────────────────────────────────────────
  double feedIntervalHours = 3.0; // default 3 hours
  bool feedReminderEnabled = true;

  double diaperIntervalHours = 2.5;
  bool diaperReminderEnabled = false;

  void setFeedInterval(double hours) {
    feedIntervalHours = hours;
    notifyListeners();
  }

  void toggleFeedReminder(bool val) {
    feedReminderEnabled = val;
    notifyListeners();
  }

  void setDiaperInterval(double hours) {
    diaperIntervalHours = hours;
    notifyListeners();
  }

  void toggleDiaperReminder(bool val) {
    diaperReminderEnabled = val;
    notifyListeners();
  }

  Baby get baby => _baby;
  List<Baby> get babies => _babies;
  List<Record> get records => _records;
  bool get loaded => _loaded;

  // ── Global Breast Timer State ──────────────────────────────────────────────
  bool breastTimerActive = false;
  bool breastTimerRunning = false;
  String breastTimerSide = 'left';
  double breastLeftSec = 0;
  double breastRightSec = 0;
  Timer? _breastTimer;
  DateTime? _breastLastTick;

  void startBreastTimer() {
    if (!breastTimerActive) {
      breastTimerActive = true;
      breastTimerSide = 'left';
      breastLeftSec = 0;
      breastRightSec = 0;
    }
    breastTimerRunning = true;
    _breastLastTick = DateTime.now();
    _breastTimer?.cancel();
    _breastTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!breastTimerRunning) return;
      final now = DateTime.now();
      final dt = now.difference(_breastLastTick!).inMilliseconds / 1000.0;
      _breastLastTick = now;
      if (breastTimerSide == 'left') breastLeftSec += dt;
      else breastRightSec += dt;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseBreastTimer() {
    breastTimerRunning = false;
    notifyListeners();
  }

  void switchBreastTimerSide(String s) {
    if (s == breastTimerSide) return;
    _breastLastTick = DateTime.now();
    breastTimerSide = s;
    notifyListeners();
  }

  void stopAndSaveBreastTimer() {
    _breastTimer?.cancel();
    _breastTimer = null;
    breastTimerActive = false;
    breastTimerRunning = false;
    
    final total = breastLeftSec + breastRightSec;
    if (total > 10) { // save only if more than 10 seconds
      String sideLabel;
      if (breastLeftSec > 0 && breastRightSec > 0) sideLabel = 'both';
      else if (breastLeftSec > 0) sideLabel = 'left';
      else sideLabel = 'right';
      
      addRecord(Record(
        babyId: _baby.dbId ?? 1,
        time: DateTime.now(),
        type: 'breast',
        value: total.round(),
        extra: {'side': sideLabel, 'left': breastLeftSec.round(), 'right': breastRightSec.round()},
      ));
    }
    breastLeftSec = 0;
    breastRightSec = 0;
    notifyListeners();
  }

  void cancelBreastTimer() {
    _breastTimer?.cancel();
    _breastTimer = null;
    breastTimerActive = false;
    breastTimerRunning = false;
    breastLeftSec = 0;
    breastRightSec = 0;
    notifyListeners();
  }

  // ── Global Sleep Timer State ───────────────────────────────────────────────
  bool sleepTimerActive = false;
  bool sleepTimerRunning = false;
  double sleepSec = 0;
  Timer? _sleepTimer;
  DateTime? _sleepLastTick;

  void startSleepTimer() {
    if (!sleepTimerActive) {
      sleepTimerActive = true;
      sleepSec = 0;
    }
    sleepTimerRunning = true;
    _sleepLastTick = DateTime.now();
    _sleepTimer?.cancel();
    _sleepTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!sleepTimerRunning) return;
      final now = DateTime.now();
      final dt = now.difference(_sleepLastTick!).inMilliseconds / 1000.0;
      _sleepLastTick = now;
      sleepSec += dt;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseSleepTimer() {
    sleepTimerRunning = false;
    notifyListeners();
  }

  void stopAndSaveSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerActive = false;
    sleepTimerRunning = false;

    if (sleepSec > 60) { // save only if more than 1 minute
      addRecord(Record(
        babyId: _baby.dbId ?? 1,
        time: DateTime.now().subtract(Duration(seconds: sleepSec.round())),
        type: 'sleep',
        value: sleepSec.round(),
      ));
    }
    sleepSec = 0;
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepTimerActive = false;
    sleepTimerRunning = false;
    sleepSec = 0;
    notifyListeners();
  }
  // ─────────────────────────────────────────────────────────────────────────

  AppState() {
    _init();
  }

  Future<void> _init() async {
    // Load or create baby
    final babyRows = await DbHelper.getAllBabies();
    if (babyRows.isEmpty) {
      final defaultBaby = Baby.initial();
      final id = await DbHelper.insertBaby(defaultBaby.toDb());
      _baby = Baby(dbId: id, name: defaultBaby.name, gender: defaultBaby.gender,
        birthday: defaultBaby.birthday, weightKg: defaultBaby.weightKg, heightCm: defaultBaby.heightCm, headCm: defaultBaby.headCm);
      _babies = [_baby];
    } else {
      _babies = babyRows.map((r) => Baby.fromDb(r)).toList();
      final activeRow = await DbHelper.getActiveBaby();
      if (activeRow != null) {
        _baby = Baby.fromDb(activeRow);
      } else {
        _baby = _babies.first;
      }
    }

    // Load records
    final rows = await DbHelper.getAllRecords(_baby.dbId!);
    _records = rows.map((r) => Record.fromDb(r)).toList();

    // If empty, seed demo data
    if (_records.isEmpty) {
      await _seedDemoRecords();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _seedDemoRecords() async {
    final now = DateTime.now();
    t(int h, int m) => DateTime(now.year, now.month, now.day, h, m);
    final seeds = [
      Record(babyId: _baby.dbId!, time: t(8, 15), type: 'breast', value: 18 * 60, extra: {'side': 'both', 'left': 480, 'right': 600}),
      Record(babyId: _baby.dbId!, time: t(8, 35), type: 'diaper', extra: {'status': 'pee'}),
      Record(babyId: _baby.dbId!, time: t(9, 40), type: 'sleep', value: 95 * 60, extra: {'start': t(9, 40).toIso8601String(), 'end': t(11, 15).toIso8601String()}),
      Record(babyId: _baby.dbId!, time: t(11, 20), type: 'diaper', extra: {'status': 'mixed'}),
      Record(babyId: _baby.dbId!, time: t(11, 35), type: 'bottle', value: 120),
      Record(babyId: _baby.dbId!, time: t(13, 0), type: 'sleep', value: 75 * 60, extra: {'start': t(13, 0).toIso8601String(), 'end': t(14, 15).toIso8601String()}),
      Record(babyId: _baby.dbId!, time: t(14, 30), type: 'breast', value: 22 * 60, extra: {'side': 'left', 'left': 1320, 'right': 0}),
      Record(babyId: _baby.dbId!, time: t(15, 0), type: 'food', extra: {'food': '米糊 + 香蕉', 'amount': '30g'}),
      Record(babyId: _baby.dbId!, time: t(15, 40), type: 'diaper', extra: {'status': 'poo', 'color': 'yellow'}),
      Record(babyId: _baby.dbId!, time: t(17, 20), type: 'bath'),
      Record(babyId: _baby.dbId!, time: t(18, 0), type: 'breast', value: 16 * 60, extra: {'side': 'right', 'left': 0, 'right': 960}),
    ];
    for (final r in seeds) {
      final id = await DbHelper.insertRecord(r.toDb());
      _records.add(Record(dbId: id, babyId: r.babyId, time: r.time, type: r.type, value: r.value, extra: r.extra));
    }
  }

  Future<void> addRecord(Record r) async {
    final id = await DbHelper.insertRecord(r.toDb());
    final saved = Record(dbId: id, babyId: r.babyId, time: r.time, type: r.type, value: r.value, extra: r.extra);
    _records = [saved, ..._records];
    
    if (r.type == 'growth') {
      final w = r.extra['weight'] as double?;
      final h = r.extra['height'] as double?;
      final hd = r.extra['head'] as double?;
      final newBaby = _baby.copyWith(
        weightKg: w ?? _baby.weightKg,
        heightCm: h ?? _baby.heightCm,
        headCm: hd ?? _baby.headCm,
      );
      await updateBaby(newBaby);
    } else {
      notifyListeners();
    }
  }

  Future<void> deleteRecord(int dbId) async {
    await DbHelper.deleteRecord(dbId);
    _records = _records.where((r) => r.dbId != dbId).toList();
    notifyListeners();
  }

  Future<void> updateBaby(Baby b) async {
    if (b.dbId != null) {
      await DbHelper.updateBaby(b.dbId!, b.toDb());
      final index = _babies.indexWhere((x) => x.dbId == b.dbId);
      if (index != -1) _babies[index] = b;
    }
    _baby = b;
    notifyListeners();
  }

  Future<void> addBaby(Baby b) async {
    final id = await DbHelper.insertBaby(b.toDb());
    final newBaby = Baby(
      dbId: id, name: b.name, gender: b.gender, birthday: b.birthday,
      weightKg: b.weightKg, heightCm: b.heightCm, headCm: b.headCm,
    );
    _babies.add(newBaby);
    await switchBaby(id);
  }

  Future<void> switchBaby(int id) async {
    if (_baby.dbId == id) return;
    await DbHelper.setActiveBaby(id);
    _baby = _babies.firstWhere((b) => b.dbId == id);
    // Reload records for this baby
    final rows = await DbHelper.getAllRecords(id);
    _records = rows.map((r) => Record.fromDb(r)).toList();
    notifyListeners();
  }

  Future<void> deleteBaby(int id) async {
    await DbHelper.deleteBaby(id);
    _babies.removeWhere((b) => b.dbId == id);
    if (_babies.isEmpty) {
      // Create a default if none left
      final newBabyInitial = Baby.initial();
      final newId = await DbHelper.insertBaby(newBabyInitial.toDb());
      final newBaby = Baby(
        dbId: newId,
        name: newBabyInitial.name,
        gender: newBabyInitial.gender,
        birthday: newBabyInitial.birthday,
        weightKg: newBabyInitial.weightKg,
        heightCm: newBabyInitial.heightCm,
        headCm: newBabyInitial.headCm,
      );
      _babies.add(newBaby);
      _baby = newBaby;
      _records = [];
    } else if (_baby.dbId == id) {
      // Switch to the first available if the active one was deleted
      await switchBaby(_babies.first.dbId!);
    }
    notifyListeners();
  }

  List<Record> get todayRecords {
    final today = DateTime.now();
    return _records.where((r) =>
      r.time.year == today.year &&
      r.time.month == today.month &&
      r.time.day == today.day
    ).toList();
  }

  // Stats helpers
  List<Record> recordsForDate(DateTime d) => _records.where((r) =>
    r.time.year == d.year && r.time.month == d.month && r.time.day == d.day).toList();

  int milkCountForDate(DateTime d) => recordsForDate(d).where((r) => r.type == 'breast' || r.type == 'bottle').length;
  int sleepSecsForDate(DateTime d) => recordsForDate(d).where((r) => r.type == 'sleep').fold(0, (s, r) => s + (r.value ?? 0));
  int diaperCountForDate(DateTime d) => recordsForDate(d).where((r) => r.type == 'diaper').length;

  Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    if (query.isEmpty) return [];
    final dbRows = await DbHelper.getAllBabies();
    List<Map<String, dynamic>> results = [];
    for (final bRow in dbRows) {
      final bId = bRow['id'] as int;
      final bName = bRow['name'] as String;
      final recs = await DbHelper.getAllRecords(bId);
      for (final rRow in recs) {
        final r = Record.fromDb(rRow);
        final cLabel = categories[r.type]?.label ?? '';
        final rDesc = describeRecord(r.toJson());
        if (cLabel.contains(query) || rDesc.contains(query) || bName.contains(query)) {
          results.add({
            'babyName': bName,
            'record': r,
          });
        }
      }
    }
    results.sort((a, b) => (b['record'] as Record).time.compareTo((a['record'] as Record).time));
    return results;
  }
}
