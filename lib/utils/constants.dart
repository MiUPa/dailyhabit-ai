import 'package:flutter/material.dart';

class AppConstants {
  // アプリ情報
  static const String appName = 'DailyHabit AI';
  static const String appVersion = '1.0.0';
  
  // カラー
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // 習慣カテゴリー
  static const List<String> habitCategories = [
    '健康',
    '学習',
    '仕事',
    '運動',
    '読書',
    '瞑想',
    '家事',
    'その他',
  ];
  
  // 習慣頻度
  static const List<String> habitFrequencies = [
    'daily',
    'weekly',
    'monthly',
  ];
  
  // 頻度表示名
  static const Map<String, String> frequencyDisplayNames = {
    'daily': '毎日',
    'weekly': '毎週',
    'monthly': '毎月',
  };
  
  // データベース
  static const String databaseName = 'dailyhabit_ai.db';
  static const int databaseVersion = 1;
  
  // 通知
  static const String notificationChannelId = 'dailyhabit_ai_channel';
  static const String notificationChannelName = 'DailyHabit AI';
  static const String notificationChannelDescription = '習慣リマインダー通知';
  
  // 設定
  static const String settingsThemeKey = 'theme';
  static const String settingsLanguageKey = 'language';
  static const String settingsNotificationsKey = 'notifications_enabled';
  static const String settingsSoundKey = 'sound_enabled';
  static const String settingsVibrationKey = 'vibration_enabled';
  
  // アニメーション
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  
  // レイアウト
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // フォントサイズ
  static const double smallFontSize = 12.0;
  static const double normalFontSize = 14.0;
  static const double largeFontSize = 16.0;
  static const double titleFontSize = 20.0;
  static const double headlineFontSize = 24.0;
} 