import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dailyhabit_ai/main.dart' as app;
import 'dart:io';
import 'dart:typed_data';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ホーム画面のスクリーンショット', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // スクリーンショットを撮影してファイルに保存
    final bytes = await tester.binding.takeScreenshot('home_screen');
    final file = File('test_output/home_screen.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    print('✅ スクリーンショット保存: ${file.absolute.path}');
  });
} 