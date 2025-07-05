class Habit {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String frequency; // daily, weekly, monthly
  final TimeOfDay? reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    this.reminderTime,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
      'reminderTime': reminderTime != null 
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminderTime;
    if (map['reminderTime'] != null) {
      final timeParts = map['reminderTime'].split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      frequency: map['frequency'],
      reminderTime: reminderTime,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? frequency,
    TimeOfDay? reminderTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 