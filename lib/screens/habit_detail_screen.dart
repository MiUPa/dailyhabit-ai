import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<HabitLog> _logs = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _selectedPeriod = 30;

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
      final logs = await _databaseService.getHabitLogsByHabitId(widget.habit.id!);
      final stats = await _databaseService.getHabitStats(widget.habit.id!, days: _selectedPeriod);

      setState(() {
        _logs = logs;
        _stats = stats;
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

  Future<void> _toggleCompletion(DateTime date) async {
    try {
      final existingLog = _logs.firstWhere(
        (log) => log.date.day == date.day && log.date.month == date.month && log.date.year == date.year,
        orElse: () => HabitLog(
          habitId: widget.habit.id!,
          date: date,
          completed: false,
          createdAt: date,
        ),
      );

      final newCompleted = !existingLog.completed;
      final updatedLog = existingLog.copyWith(
        completed: newCompleted,
        id: existingLog.id,
      );

      if (existingLog.id == null) {
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

  bool _isCompletedOnDate(DateTime date) {
    try {
      return _logs.any((log) => 
        log.date.day == date.day && 
        log.date.month == date.month && 
        log.date.year == date.year && 
        log.completed
      );
    } catch (e) {
      return false;
    }
  }

  List<FlSpot> _getCompletionTrendData() {
    final spots = <FlSpot>[];
    final endDate = DateTime.now();
    
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = endDate.subtract(Duration(days: _selectedPeriod - 1 - i));
      final isCompleted = _isCompletedOnDate(date);
      spots.add(FlSpot(i.toDouble(), isCompleted ? 100 : 0));
    }
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('過去7日間')),
              const PopupMenuItem(value: 30, child: Text('過去30日間')),
              const PopupMenuItem(value: 90, child: Text('過去90日間')),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: widget.habit),
                ),
              ).then((result) {
                if (result == true || result == 'deleted') {
                  Navigator.pop(context, result);
                }
              });
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  // 習慣情報カード
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.habit.title,
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.smallPadding,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.habit.category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.smallPadding),
                          Text(
                            widget.habit.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Icon(Icons.repeat, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                AppConstants.frequencyDisplayNames[widget.habit.frequency]!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (widget.habit.reminderTime != null) ...[
                                const SizedBox(width: AppConstants.defaultPadding),
                                Icon(Icons.alarm, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.habit.reminderTime!.hour.toString().padLeft(2, '0')}:${widget.habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // 統計カード
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '統計（過去${_selectedPeriod}日間）',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '完了日数',
                                  _stats['completedDays']?.toString() ?? '0',
                                  Icons.check_circle,
                                  AppConstants.successColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '未完了日数',
                                  _stats['missedDays']?.toString() ?? '0',
                                  Icons.cancel,
                                  AppConstants.errorColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '完了率',
                                  '${_stats['completionRate']?.toString() ?? '0'}%',
                                  Icons.trending_up,
                                  AppConstants.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // 完了率トレンド
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '完了率トレンド',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.round()}%');
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() % 7 == 0) {
                                          return Text('${value.toInt()}日');
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: true),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getCompletionTrendData(),
                                    isCurved: false,
                                    color: AppConstants.primaryColor,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppConstants.primaryColor.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // 最近の記録
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '最近の記録',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ..._logs.take(10).map((log) {
                            final isCompleted = log.completed;
                            return ListTile(
                              leading: GestureDetector(
                                onTap: () => _toggleCompletion(log.date),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted 
                                        ? AppConstants.successColor 
                                        : Colors.grey.shade300,
                                    border: Border.all(
                                      color: isCompleted 
                                          ? AppConstants.successColor 
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ),
                              title: Text(
                                DateFormat('M月d日').format(log.date),
                                style: TextStyle(
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? Colors.grey.shade600 : null,
                                ),
                              ),
                              subtitle: log.note != null ? Text(log.note!) : null,
                              trailing: Text(
                                DateFormat('HH:mm').format(log.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            );
                          }).toList(),
                          if (_logs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(AppConstants.defaultPadding),
                              child: Center(
                                child: Text(
                                  'まだ記録がありません',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.smallFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
} 