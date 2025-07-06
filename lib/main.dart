import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'utils/performance_optimizer.dart';
import 'utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 通知サービスの初期化
  await NotificationService().initialize();
  
  // パフォーマンス最適化の初期化
  PerformanceOptimizer.optimizeImageCache();
  PerformanceOptimizer.startPerformanceMonitoring();
  
  // エラーハンドリングの初期化
  ErrorHandler.initializeErrorHandling();
  
  runApp(const DailyHabitAIApp());
}

class DailyHabitAIApp extends StatelessWidget {
  const DailyHabitAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    // システムUIの設定
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // システム設定に従う
      home: const HomeScreen(),
    );
  }
}
