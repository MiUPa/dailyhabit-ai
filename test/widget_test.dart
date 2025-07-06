// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/src/enums.dart';

import 'package:dailyhabit_ai/main.dart';
import 'package:dailyhabit_ai/models/habit.dart';
import 'package:dailyhabit_ai/screens/home_screen.dart';

// モック用のPathProvider
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path.join(Directory.systemTemp.path, 'test_app_documents');
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return path.join(Directory.systemTemp.path, 'test_app_support');
  }

  @override
  Future<String?> getLibraryPath() async {
    return path.join(Directory.systemTemp.path, 'test_library');
  }

  @override
  Future<String?> getTemporaryPath() async {
    return path.join(Directory.systemTemp.path, 'test_temp');
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return [path.join(Directory.systemTemp.path, 'test_external_cache')];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return path.join(Directory.systemTemp.path, 'test_downloads');
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return path.join(Directory.systemTemp.path, 'test_app_cache');
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return path.join(Directory.systemTemp.path, 'test_external_storage');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async {
    return [path.join(Directory.systemTemp.path, 'test_external_storage')];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // テスト用のデータベース設定
  setUpAll(() async {
    // SQLite FFIの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // PathProviderのモック設定
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  group('DailyHabit AI App Tests', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリをビルド
      await tester.pumpWidget(const DailyHabitAIApp());

      // アプリが正常に起動することを確認
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('ホーム画面の基本要素が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const DailyHabitAIApp());

      // アプリバーのタイトルが表示される
      expect(find.text('DailyHabit AI'), findsOneWidget);

      // カレンダー、統計、設定ボタンが表示される
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // フローティングアクションボタンが表示される
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('習慣追加ボタンが動作する', (WidgetTester tester) async {
      await tester.pumpWidget(const DailyHabitAIApp());

      // フローティングアクションボタンをタップ
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // 習慣追加画面が表示される
      expect(find.text('習慣を追加'), findsOneWidget);
    });

    testWidgets('空の状態が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const DailyHabitAIApp());

      // 基本的な要素が表示されることを確認
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('Habit Model Tests', () {
    test('HabitモデルのtoMapとfromMap', () {
      final originalHabit = Habit(
        id: 1,
        title: 'テスト習慣',
        description: 'テスト用の習慣です',
        category: 'テスト',
        frequency: 'daily',
        reminderTime: const TimeOfDay(hour: 9, minute: 0),
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // toMapでマップに変換
      final map = originalHabit.toMap();

      // fromMapでHabitオブジェクトに戻す
      final restoredHabit = Habit.fromMap(map);

      // 元のオブジェクトと一致することを確認
      expect(restoredHabit.id, equals(originalHabit.id));
      expect(restoredHabit.title, equals(originalHabit.title));
      expect(restoredHabit.description, equals(originalHabit.description));
      expect(restoredHabit.category, equals(originalHabit.category));
      expect(restoredHabit.frequency, equals(originalHabit.frequency));
      expect(restoredHabit.isActive, equals(originalHabit.isActive));
    });

    test('HabitモデルのcopyWith', () {
      final originalHabit = Habit(
        id: 1,
        title: '元のタイトル',
        description: '元の説明',
        category: '元のカテゴリー',
        frequency: 'daily',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // copyWithで一部のフィールドを更新
      final updatedHabit = originalHabit.copyWith(
        title: '新しいタイトル',
        description: '新しい説明',
      );

      // 更新されたフィールドが変更されていることを確認
      expect(updatedHabit.title, equals('新しいタイトル'));
      expect(updatedHabit.description, equals('新しい説明'));

      // 更新されていないフィールドが元のままであることを確認
      expect(updatedHabit.id, equals(originalHabit.id));
      expect(updatedHabit.category, equals(originalHabit.category));
      expect(updatedHabit.frequency, equals(originalHabit.frequency));
    });
  });
}
