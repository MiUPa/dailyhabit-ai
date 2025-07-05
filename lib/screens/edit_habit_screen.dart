import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late String _selectedCategory;
  late String _selectedFrequency;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _selectedCategory = widget.habit.category;
    _selectedFrequency = widget.habit.frequency;
    _selectedTime = widget.habit.reminderTime;
  }

  @override
  void dispose() {
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

  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        reminderTime: _selectedTime,
        updatedAt: now,
      );

      await DatabaseService().updateHabit(updatedHabit);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('習慣を更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('習慣の更新に失敗しました: $e')),
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

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('習慣を削除'),
        content: const Text('この習慣を削除しますか？\n削除すると元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await DatabaseService().deleteHabit(widget.habit.id!);

        if (mounted) {
          Navigator.pop(context, 'deleted');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('習慣を削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('習慣の削除に失敗しました: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('習慣を編集'),
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
          else ...[
            TextButton(
              onPressed: _updateHabit,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteHabit();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

            // 作成日時表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '習慣情報',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildInfoRow('作成日', _formatDate(widget.habit.createdAt)),
                    _buildInfoRow('更新日', _formatDate(widget.habit.updatedAt)),
                    _buildInfoRow('ステータス', widget.habit.isActive ? 'アクティブ' : '非アクティブ'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 