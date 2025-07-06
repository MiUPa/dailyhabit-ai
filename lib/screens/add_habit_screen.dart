import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = AppConstants.habitCategories.first;
  String _selectedFrequency = AppConstants.habitFrequencies.first;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final habit = Habit(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        reminderTime: _selectedTime,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseService().insertHabit(habit);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('習慣を追加しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('習慣の追加に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('習慣を追加'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveHabit,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // タイトル入力
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '習慣のタイトル *',
                hintText: '例: 毎日30分運動する',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                if (value.trim().length > 50) {
                  return 'タイトルは50文字以内で入力してください';
                }
                return null;
              },
              maxLength: 50,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // 説明入力
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                hintText: '習慣についての詳細な説明（任意）',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 200,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // カテゴリー選択
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'カテゴリー *',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.habitCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // 頻度選択
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: '頻度 *',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: AppConstants.habitFrequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(AppConstants.frequencyDisplayNames[frequency]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                });
              },
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // リマインダー時間選択
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('リマインダー時間'),
              subtitle: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : '設定しない',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedTime != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // プレビューカード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プレビュー',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    if (_titleController.text.isNotEmpty) ...[
                      Text(
                        _titleController.text,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                    ],
                    if (_descriptionController.text.isNotEmpty) ...[
                      Text(
                        _descriptionController.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                    ],
                    Row(
                      children: [
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
                            _selectedCategory,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
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
                            AppConstants.frequencyDisplayNames[_selectedFrequency]!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppConstants.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_selectedTime != null) ...[
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
            ),
          ],
        ),
      ),
    );
  }
} 