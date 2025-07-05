import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dailyhabit_ai.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 習慣テーブル
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        reminderTime TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 習慣ログテーブル
    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // ユーザー設定テーブル
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme TEXT NOT NULL DEFAULT 'system',
        language TEXT NOT NULL DEFAULT 'ja',
        notificationsEnabled INTEGER NOT NULL DEFAULT 1,
        soundEnabled INTEGER NOT NULL DEFAULT 1,
        vibrationEnabled INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 初期設定データの挿入
    final now = DateTime.now().toIso8601String();
    await db.insert('user_settings', {
      'theme': 'system',
      'language': 'ja',
      'notificationsEnabled': 1,
      'soundEnabled': 1,
      'vibrationEnabled': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // 習慣関連のメソッド
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 習慣ログ関連のメソッド
  Future<int> insertHabitLog(HabitLog log) async {
    final db = await database;
    return await db.insert('habit_logs', log.toMap());
  }

  Future<List<HabitLog>> getHabitLogsByHabitId(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_logs',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
  }

  Future<List<HabitLog>> getHabitLogsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return List.generate(maps.length, (i) => HabitLog.fromMap(maps[i]));
  }

  Future<int> updateHabitLog(HabitLog log) async {
    final db = await database;
    return await db.update(
      'habit_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteHabitLog(int id) async {
    final db = await database;
    return await db.delete(
      'habit_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ユーザー設定関連のメソッド
  Future<UserSettings?> getUserSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    if (maps.isNotEmpty) {
      return UserSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserSettings(UserSettings settings) async {
    final db = await database;
    return await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // 統計関連のメソッド
  Future<Map<String, dynamic>> getHabitStats(int habitId, {int days = 30}) async {
    final db = await database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalDays,
        SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completedDays,
        SUM(CASE WHEN completed = 0 THEN 1 ELSE 0 END) as missedDays
      FROM habit_logs 
      WHERE habitId = ? AND date BETWEEN ? AND ?
    ''', [
      habitId,
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    if (maps.isNotEmpty) {
      final data = maps.first;
      final totalDays = data['totalDays'] as int;
      final completedDays = data['completedDays'] as int;
      final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;

      return {
        'totalDays': totalDays,
        'completedDays': completedDays,
        'missedDays': data['missedDays'] as int,
        'completionRate': completionRate,
      };
    }

    return {
      'totalDays': 0,
      'completedDays': 0,
      'missedDays': 0,
      'completionRate': 0,
    };
  }
} 