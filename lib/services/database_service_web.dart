import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast_web/sembast_web.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static sembast.Database? _sembastDb;
  static final sembast.StoreRef<int, Map<String, dynamic>> _habitStore = sembast.intMapStoreFactory.store('habits');
  static final sembast.StoreRef<int, Map<String, dynamic>> _habitLogStore = sembast.intMapStoreFactory.store('habit_logs');
  static final sembast.StoreRef<int, Map<String, dynamic>> _userSettingsStore = sembast.intMapStoreFactory.store('user_settings');

  Future<void> _init() async {
    if (_sembastDb == null) {
      _sembastDb = await databaseFactoryWeb.openDatabase('dailyhabit_ai_web.db');
    }
  }

  // --- Habit ---
  Future<int> insertHabit(Habit habit) async {
    await _init();
    final finder = sembast.Finder(sortOrders: [sembast.SortOrder('id', false)]);
    final records = await _habitStore.find(_sembastDb!, finder: finder);
    final newId = (records.isNotEmpty ? (records.first.key + 1) : 1);
    final data = habit.toMap();
    data['id'] = newId;
    await _habitStore.record(newId).put(_sembastDb!, data);
    return newId;
  }

  Future<List<Habit>> getAllHabits() async {
    await _init();
    final records = await _habitStore.find(_sembastDb!);
    return records.map((rec) => Habit.fromMap(rec.value)).toList();
  }

  Future<Habit?> getHabitById(int id) async {
    await _init();
    final record = await _habitStore.record(id).get(_sembastDb!);
    if (record != null) {
      return Habit.fromMap(record);
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    await _init();
    await _habitStore.record(habit.id!).put(_sembastDb!, habit.toMap());
    return habit.id!;
  }

  Future<int> deleteHabit(int id) async {
    await _init();
    await _habitStore.record(id).delete(_sembastDb!);
    return id;
  }

  // --- HabitLog ---
  Future<int> insertHabitLog(HabitLog log) async {
    await _init();
    final finder = sembast.Finder(sortOrders: [sembast.SortOrder('id', false)]);
    final records = await _habitLogStore.find(_sembastDb!, finder: finder);
    final newId = (records.isNotEmpty ? (records.first.key + 1) : 1);
    final data = log.toMap();
    data['id'] = newId;
    await _habitLogStore.record(newId).put(_sembastDb!, data);
    return newId;
  }

  Future<int> updateHabitLog(HabitLog log) async {
    await _init();
    await _habitLogStore.record(log.id!).put(_sembastDb!, log.toMap());
    return log.id!;
  }

  Future<List<HabitLog>> getHabitLogsByDate(DateTime date) async {
    await _init();
    final dateStr = date.toIso8601String().split('T')[0];
    final finder = sembast.Finder(filter: sembast.Filter.equals('date', dateStr));
    final records = await _habitLogStore.find(_sembastDb!, finder: finder);
    return records.map((rec) => HabitLog.fromMap(rec.value)).toList();
  }

  Future<List<HabitLog>> getHabitLogsByHabitId(int habitId) async {
    await _init();
    final finder = sembast.Finder(filter: sembast.Filter.equals('habitId', habitId));
    final records = await _habitLogStore.find(_sembastDb!, finder: finder);
    return records.map((rec) => HabitLog.fromMap(rec.value)).toList();
  }

  // --- UserSettings ---
  Future<UserSettings?> getUserSettings() async {
    await _init();
    final records = await _userSettingsStore.find(_sembastDb!);
    if (records.isNotEmpty) {
      return UserSettings.fromMap(records.first.value);
    }
    return null;
  }

  Future<int> updateUserSettings(UserSettings settings) async {
    await _init();
    // 1件のみ保存する想定
    final finder = sembast.Finder();
    final records = await _userSettingsStore.find(_sembastDb!, finder: finder);
    int id;
    if (records.isEmpty) {
      id = 1;
    } else {
      id = records.first.key;
    }
    final data = settings.toMap();
    data['id'] = id;
    await _userSettingsStore.record(id).put(_sembastDb!, data);
    return id;
  }

  // --- Stats ---
  Future<Map<String, dynamic>> getHabitStats(int habitId, {int days = 30}) async {
    await _init();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final finder = sembast.Finder(
      filter: sembast.Filter.and([
        sembast.Filter.equals('habitId', habitId),
        sembast.Filter.greaterThanOrEquals('date', startDate.toIso8601String().split('T')[0]),
        sembast.Filter.lessThanOrEquals('date', endDate.toIso8601String().split('T')[0]),
      ]),
    );
    final records = await _habitLogStore.find(_sembastDb!, finder: finder);
    final totalDays = records.length;
    final completedDays = records.where((rec) => rec.value['completed'] == 1).length;
    final missedDays = totalDays - completedDays;
    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;
    return {
      'totalDays': totalDays,
      'completedDays': completedDays,
      'missedDays': missedDays,
      'completionRate': completionRate,
    };
  }
} 