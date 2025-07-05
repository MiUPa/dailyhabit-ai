class UserSettings {
  final int? id;
  final String theme; // light, dark, system
  final String language; // ja, en
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    this.id,
    this.theme = 'system',
    this.language = 'ja',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'soundEnabled': soundEnabled ? 1 : 0,
      'vibrationEnabled': vibrationEnabled ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'],
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'ja',
      notificationsEnabled: map['notificationsEnabled'] == 1,
      soundEnabled: map['soundEnabled'] == 1,
      vibrationEnabled: map['vibrationEnabled'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  UserSettings copyWith({
    int? id,
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 