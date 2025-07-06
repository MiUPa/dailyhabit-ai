import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  List<HabitLog> _monthLogs = [];
  DateTime _selectedDate = DateTime.now();
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
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      
      // 月のログを取得
      List<HabitLog> monthLogs = [];
      for (int i = 0; i < endOfMonth.day; i++) {
        final date = DateTime(_selectedDate.year, _selectedDate.month, i + 1);
        final dayLogs = await _databaseService.getHabitLogsByDate(date);
        monthLogs.addAll(dayLogs);
      }

      setState(() {
        _habits = habits;
        _monthLogs = monthLogs;
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

  Future<void> _toggleHabitCompletion(Habit habit, DateTime date) async {
    try {
      final dayLog = _monthLogs.firstWhere(
        (log) => log.habitId == habit.id && log.date.day == date.day,
        orElse: () => HabitLog(
          habitId: habit.id!,
          date: date,
          completed: false,
          createdAt: date,
        ),
      );

      final newCompleted = !dayLog.completed;
      final updatedLog = dayLog.copyWith(
        completed: newCompleted,
        id: dayLog.id,
      );

      if (dayLog.id == null) {
        await _databaseService.insertHabitLog(updatedLog);
      } else {
        await _databaseService.updateHabitLog(updatedLog);
      }

      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('習慣の更新に失敗しました: $e')),
        );
      }
    }
  }

  bool _isHabitCompletedOnDate(Habit habit, DateTime date) {
    try {
      return _monthLogs.any((log) => 
        log.habitId == habit.id && 
        log.date.day == date.day && 
        log.completed
      );
    } catch (e) {
      return false;
    }
  }

  int _getCompletedHabitsOnDate(DateTime date) {
    return _habits.where((habit) => _isHabitCompletedOnDate(habit, date)).length;
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
        actions: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('yyyy年M月').format(_selectedDate),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 週のヘッダー
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: ['日', '月', '火', '水', '木', '金', '土'].map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: day == '日' ? Colors.red : day == '土' ? Colors.blue : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // カレンダーグリッド
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42, // 6週間分
                    itemBuilder: (context, index) {
                      final dayOffset = index - (firstWeekday - 1);
                      final day = dayOffset + 1;
                      
                      if (day < 1 || day > daysInMonth) {
                        return Container(); // 空のセル
                      }

                      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
                      final isToday = date.isAtSameMomentAs(DateTime.now());
                      final completedCount = _getCompletedHabitsOnDate(date);
                      final totalCount = _habits.length;
                      final completionRate = totalCount > 0 ? (completedCount / totalCount) : 0.0;

                      return GestureDetector(
                        onTap: () => _showDayDetails(date),
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isToday 
                                ? AppConstants.primaryColor.withOpacity(0.1)
                                : completionRate > 0 
                                    ? AppConstants.successColor.withOpacity(completionRate * 0.3)
                                    : theme.colorScheme.surface,
                            border: Border.all(
                              color: isToday 
                                  ? AppConstants.primaryColor 
                                  : theme.dividerColor,
                              width: isToday ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday ? AppConstants.primaryColor : null,
                                ),
                              ),
                              if (totalCount > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '$completedCount/$totalCount',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: completionRate > 0.5 
                                        ? AppConstants.successColor 
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 凡例
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('今日', AppConstants.primaryColor),
                      _buildLegendItem('完了', AppConstants.successColor),
                      _buildLegendItem('未完了', Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showDayDetails(DateTime date) {
    final dayHabits = _habits.map((habit) {
      final isCompleted = _isHabitCompletedOnDate(habit, date);
      return {
        'habit': habit,
        'completed': isCompleted,
      };
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('M月d日').format(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ...dayHabits.map((item) {
              final habit = item['habit'] as Habit;
              final completed = item['completed'] as bool;
              
              return ListTile(
                leading: GestureDetector(
                  onTap: () => _toggleHabitCompletion(habit, date),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed 
                          ? AppConstants.successColor 
                          : Colors.grey.shade300,
                      border: Border.all(
                        color: completed 
                            ? AppConstants.successColor 
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                title: Text(
                  habit.title,
                  style: TextStyle(
                    decoration: completed ? TextDecoration.lineThrough : null,
                    color: completed ? Colors.grey.shade600 : null,
                  ),
                ),
                subtitle: Text(habit.category),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 