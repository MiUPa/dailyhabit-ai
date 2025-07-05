class HabitLog {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool completed;
  final String? note;
  final DateTime createdAt;

  HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD形式
      'completed': completed ? 1 : 0,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habitId'],
      date: DateTime.parse(map['date']),
      completed: map['completed'] == 1,
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? completed,
    String? note,
    DateTime? createdAt,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 