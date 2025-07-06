import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Habit> _habits = [];
  List<HabitLog> _recentLogs = [];
  bool _isLoading = true;
  int _selectedPeriod = 30; // 30日間

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
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: _selectedPeriod));
      
      // 期間中のログを取得
      List<HabitLog> recentLogs = [];
      for (int i = 0; i < _selectedPeriod; i++) {
        final date = endDate.subtract(Duration(days: i));
        final dayLogs = await _databaseService.getHabitLogsByDate(date);
        recentLogs.addAll(dayLogs);
      }

      setState(() {
        _habits = habits;
        _recentLogs = recentLogs;
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

  Map<String, dynamic> _getOverallStats() {
    final totalHabits = _habits.length;
    final activeHabits = _habits.where((h) => h.isActive).length;
    final totalLogs = _recentLogs.length;
    final completedLogs = _recentLogs.where((log) => log.completed).length;
    final completionRate = totalLogs > 0 ? (completedLogs / totalLogs * 100).round() : 0;

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'totalLogs': totalLogs,
      'completedLogs': completedLogs,
      'completionRate': completionRate,
    };
  }

  List<Map<String, dynamic>> _getHabitStats() {
    return _habits.map((habit) {
      final habitLogs = _recentLogs.where((log) => log.habitId == habit.id).toList();
      final totalDays = habitLogs.length;
      final completedDays = habitLogs.where((log) => log.completed).length;
      final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;

      return {
        'habit': habit,
        'totalDays': totalDays,
        'completedDays': completedDays,
        'completionRate': completionRate,
      };
    }).toList();
  }

  List<FlSpot> _getCompletionTrendData() {
    final spots = <FlSpot>[];
    final endDate = DateTime.now();
    
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = endDate.subtract(Duration(days: _selectedPeriod - 1 - i));
      final dayLogs = _recentLogs.where((log) => 
        log.date.year == date.year && 
        log.date.month == date.month && 
        log.date.day == date.day
      ).toList();
      
      final totalHabits = _habits.length;
      final completedHabits = dayLogs.where((log) => log.completed).length;
      final completionRate = totalHabits > 0 ? (completedHabits / totalHabits * 100) : 0;
      
      spots.add(FlSpot(i.toDouble(), completionRate.toDouble()));
    }
    
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _getOverallStats();
    final habitStats = _getHabitStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_habits.isEmpty || _recentLogs.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 24),
                      Text(
                        'まだ統計データがありません',
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '習慣を登録し、記録をつけるとここに統計が表示されます',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  // 期間選択表示
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text(
                            '過去${_selectedPeriod}日間の統計',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // 全体統計
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '全体統計',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '総習慣数',
                                  stats['totalHabits'].toString(),
                                  Icons.list,
                                  AppConstants.primaryColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'アクティブ',
                                  stats['activeHabits'].toString(),
                                  Icons.check_circle,
                                  AppConstants.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '完了率',
                                  '${stats['completionRate']}%',
                                  Icons.trending_up,
                                  AppConstants.secondaryColor,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '総記録数',
                                  stats['totalLogs'].toString(),
                                  Icons.history,
                                  AppConstants.accentColor,
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
                                    isCurved: true,
                                    color: AppConstants.primaryColor,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
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

                  // 習慣別統計
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '習慣別統計',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.defaultPadding),
                          ...habitStats.map((stat) {
                            final habit = stat['habit'] as Habit;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                                child: Text(
                                  '${stat['completionRate']}%',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(habit.title),
                              subtitle: Text(
                                '${stat['completedDays']}/${stat['totalDays']} 日完了',
                              ),
                              trailing: LinearProgressIndicator(
                                value: stat['completionRate'] / 100,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  stat['completionRate'] > 70 
                                      ? AppConstants.successColor
                                      : stat['completionRate'] > 40
                                          ? AppConstants.warningColor
                                          : AppConstants.errorColor,
                                ),
                              ),
                            );
                          }).toList(),
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