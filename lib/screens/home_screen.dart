import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';
import '../widgets/habit_card.dart';
import '../utils/constants.dart';
import 'add_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  List<HabitLog> _todayLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final habits = await _databaseService.getAllHabits();
      final today = DateTime.now();
      final todayLogs = await _databaseService.getHabitLogsByDate(today);

      setState(() {
        _habits = habits;
        _todayLogs = todayLogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    try {
      final today = DateTime.now();
      final todayLog = _todayLogs.firstWhere(
        (log) => log.habitId == habit.id,
        orElse: () => HabitLog(
          habitId: habit.id!,
          date: today,
          completed: false,
          createdAt: today,
        ),
      );

      final newCompleted = !todayLog.completed;
      final updatedLog = todayLog.copyWith(
        completed: newCompleted,
        id: todayLog.id,
      );

      if (todayLog.id == null) {
        // 新しいログを作成
        await _databaseService.insertHabitLog(updatedLog);
      } else {
        // 既存のログを更新
        await _databaseService.updateHabitLog(updatedLog);
      }

      await _loadData(); // データを再読み込み
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('習慣の更新に失敗しました: $e')),
        );
      }
    }
  }

  void _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );

    if (result == true) {
      await _loadData();
    }
  }

  void _navigateToEditHabit(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditHabitScreen(habit: habit)),
    );

    if (result == true || result == 'deleted') {
      await _loadData();
    }
  }

  void _navigateToHabitDetail(Habit habit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HabitDetailScreen(habit: habit)),
    );

    if (result == true || result == 'deleted') {
      await _loadData();
    }
  }

  HabitLog? _getTodayLogForHabit(Habit habit) {
    try {
      return _todayLogs.firstWhere((log) => log.habitId == habit.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final completedCount = _todayLogs.where((log) => log.completed).length;
    final totalCount = _habits.length;
    final completionRate = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            icon: const Icon(Icons.calendar_today),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 今日の進捗カード
                Container(
                  margin: const EdgeInsets.all(AppConstants.defaultPadding),
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        AppConstants.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '今日の進捗',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressItem(
                            '完了',
                            completedCount.toString(),
                            Icons.check_circle,
                            Colors.white,
                          ),
                          _buildProgressItem(
                            '残り',
                            (totalCount - completedCount).toString(),
                            Icons.pending,
                            Colors.white.withOpacity(0.8),
                          ),
                          _buildProgressItem(
                            '達成率',
                            '$completionRate%',
                            Icons.trending_up,
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 日付表示
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        '${today.year}年${today.month}月${today.day}日',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // 習慣リスト
                Expanded(
                  child: _habits.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            final todayLog = _getTodayLogForHabit(habit);

                            return HabitCard(
                              habit: habit,
                              todayLog: todayLog,
                              onTap: () => _navigateToHabitDetail(habit),
                              onToggle: () => _toggleHabitCompletion(habit),
                              onEdit: () => _navigateToEditHabit(habit),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: AppConstants.smallFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_task,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            '習慣が登録されていません',
            style: TextStyle(
              fontSize: AppConstants.largeFontSize,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '右下の+ボタンから習慣を追加してください',
            style: TextStyle(
              fontSize: AppConstants.normalFontSize,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
} 