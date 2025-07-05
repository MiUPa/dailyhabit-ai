import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../utils/constants.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitLog? todayLog;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayLog,
    this.onTap,
    this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = todayLog?.completed ?? false;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // 完了チェックボックス
              GestureDetector(
                onTap: onToggle,
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
              
              const SizedBox(width: AppConstants.defaultPadding),
              
              // 習慣情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: isCompleted 
                                  ? Colors.grey.shade600 
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      habit.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Row(
                      children: [
                        // カテゴリー
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
                            habit.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        // 頻度
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppConstants.frequencyDisplayNames[habit.frequency] ?? habit.frequency,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppConstants.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (habit.reminderTime != null) ...[
                          const SizedBox(width: AppConstants.smallPadding),
                          Icon(
                            Icons.alarm,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 