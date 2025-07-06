import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  // グローバルエラーハンドラー
  static void initializeErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
    };

    // 非同期エラーのハンドリング
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      return true;
    };
  }

  // エラーログの出力
  static void _logError(String type, dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('=== $type ===');
      print('Error: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      print('================');
    }
  }

  // ユーザーフレンドリーなエラーメッセージの生成
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      return 'データベースエラーが発生しました。アプリを再起動してください。';
    } else if (error is NetworkException) {
      return 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
    } else if (error is PermissionException) {
      return '権限エラーが発生しました。設定で権限を確認してください。';
    } else if (error is ValidationException) {
      return '入力データに問題があります。内容を確認してください。';
    } else {
      return '予期しないエラーが発生しました。アプリを再起動してください。';
    }
  }

  // エラー表示用のスナックバー
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // エラー表示用のダイアログ
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          if (actionText != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onAction?.call();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  // リトライ機能付きエラーハンドリング
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        _logError('Retry Error (Attempt $attempts)', error, null);
        
        if (attempts >= maxRetries) {
          throw RetryException(
            '操作が${maxRetries}回失敗しました: ${errorMessage ?? error.toString()}',
            error,
          );
        }
        
        // 指数バックオフ
        await Future.delayed(delay * attempts);
      }
    }
    throw RetryException('予期しないエラーが発生しました', null);
  }

  // 安全な非同期処理の実行
  static Future<void> safeAsync(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      _logError('Safe Async Error', error, null);
    }
  }

  // データベース操作のエラーハンドリング
  static Future<T?> safeDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      _logError('Database Error', error, null);
      return null;
    }
  }

  // ネットワーク操作のエラーハンドリング
  static Future<T?> safeNetworkOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      _logError('Network Error', error, null);
      return null;
    }
  }

  // ファイル操作のエラーハンドリング
  static Future<T?> safeFileOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      _logError('File Error', error, null);
      return null;
    }
  }

  // バリデーションエラーの処理
  static String validateHabitTitle(String title) {
    if (title.trim().isEmpty) {
      throw ValidationException('タイトルを入力してください');
    }
    if (title.trim().length > 50) {
      throw ValidationException('タイトルは50文字以内で入力してください');
    }
    return title.trim();
  }

  static String validateHabitDescription(String description) {
    if (description.trim().length > 200) {
      throw ValidationException('説明は200文字以内で入力してください');
    }
    return description.trim();
  }

  // エラー回復の試行
  static Future<bool> attemptRecovery(Future<bool> Function() recoveryOperation) async {
    try {
      return await recoveryOperation();
    } catch (error) {
      _logError('Recovery Error', error, null);
      return false;
    }
  }
}

// カスタム例外クラス
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class RetryException implements Exception {
  final String message;
  final dynamic originalError;
  
  RetryException(this.message, this.originalError);
  
  @override
  String toString() => 'RetryException: $message';
}

// エラーハンドリング用のミックスイン
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void handleError(dynamic error, {String? context}) {
    ErrorHandler._logError(context ?? 'Widget Error', error, null);
    
    if (mounted) {
      final message = ErrorHandler.getUserFriendlyErrorMessage(error);
      // contextはBuildContextなので、適切なコンテキストを渡す必要があります
      // このミックスインでは直接スナックバーを表示できないため、
      // エラーログのみ出力します
      print('Error in ${context ?? 'Widget'}: $message');
    }
  }

  Future<T?> safeOperation<T>(Future<T> Function() operation, {String? context}) async {
    try {
      return await operation();
    } catch (error) {
      handleError(error, context: context);
      return null;
    }
  }
} 