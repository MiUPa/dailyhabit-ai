import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class PerformanceOptimizer {
  // メモリ使用量の監視
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // デバッグモードでのみメモリ使用量をログ出力
      print('Memory usage at $context: ${_getMemoryUsage()}');
    }
  }

  static String _getMemoryUsage() {
    // 簡易的なメモリ使用量の取得
    // 実際の実装では、より詳細なメモリ監視が必要
    return 'Memory usage logged';
  }

  // 画像キャッシュの最適化
  static void optimizeImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
  }

  // アニメーションの最適化
  static Duration getOptimizedAnimationDuration(BuildContext context) {
    // デバイスの性能に応じてアニメーション時間を調整
    final mediaQuery = MediaQuery.of(context);
    final isLowEndDevice = mediaQuery.size.width < 400 || 
                          mediaQuery.size.height < 600;
    
    return isLowEndDevice 
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300);
  }

  // リストの最適化
  static Widget buildOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    ScrollController? controller,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) {
    return ListView.builder(
      controller: controller,
      itemCount: items.length,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }

  // データベースクエリの最適化
  static const int maxQueryResults = 100;
  static const int defaultPageSize = 20;

  // キャッシュの管理
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  static void setCache(String key, dynamic value) {
    _cache[key] = {
      'value': value,
      'timestamp': DateTime.now(),
    };
  }

  static T? getCache<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    final timestamp = cached['timestamp'] as DateTime;
    if (DateTime.now().difference(timestamp) > _cacheExpiration) {
      _cache.remove(key);
      return null;
    }

    return cached['value'] as T;
  }

  static void clearCache() {
    _cache.clear();
  }

  // 不要なキャッシュの削除
  static void cleanupExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      final timestamp = value['timestamp'] as DateTime;
      return now.difference(timestamp) > _cacheExpiration;
    });
  }

  // ウィジェットの最適化
  static Widget buildOptimizedCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return Card(
      margin: margin,
      color: color,
      elevation: elevation,
      shape: shape,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }

  // テキストの最適化
  static Widget buildOptimizedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return RepaintBoundary(
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  // 画像の最適化
  static Widget buildOptimizedImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return RepaintBoundary(
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }

  // デバウンス機能
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, Duration duration) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  // スロットリング機能
  static DateTime? _lastThrottleTime;
  
  static bool throttle(Duration duration) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || 
        now.difference(_lastThrottleTime!) > duration) {
      _lastThrottleTime = now;
      return true;
    }
    return false;
  }

  // パフォーマンス監視
  static void startPerformanceMonitoring() {
    if (kDebugMode) {
      // フレームレートの監視
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        // フレームレートの計算とログ出力
        _logFrameRate(timeStamp);
      });
    }
  }

  static DateTime? _lastFrameTime;
  static int _frameCount = 0;
  
  static void _logFrameRate(Duration timeStamp) {
    final now = DateTime.now();
    _frameCount++;
    
    if (_lastFrameTime == null) {
      _lastFrameTime = now;
      return;
    }
    
    final elapsed = now.difference(_lastFrameTime!);
    if (elapsed.inSeconds >= 1) {
      final fps = _frameCount / elapsed.inSeconds;
      if (kDebugMode) {
        print('FPS: ${fps.toStringAsFixed(1)}');
      }
      _frameCount = 0;
      _lastFrameTime = now;
    }
  }
}

// パフォーマンス監視用のミックスイン
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    PerformanceOptimizer.logMemoryUsage('${widget.runtimeType}.initState');
  }

  @override
  void dispose() {
    PerformanceOptimizer.logMemoryUsage('${widget.runtimeType}.dispose');
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceOptimizer.logMemoryUsage('${widget.runtimeType}.didChangeDependencies');
  }
} 