// WebとモバイルでDatabaseServiceの実装を切り替えるエクスポート専用ファイル
export 'database_service_mobile.dart'
  if (dart.library.html) 'database_service_web.dart'; 