# GitHub Pages自動デプロイ問題のトラブルシューティング記録

**日付**: 2024-12-19  
**問題**: GitHub ActionsでFlutter WebアプリをGitHub Pagesに自動デプロイしようとしたが、Dart SDKバージョン不整合でビルドが失敗

## 問題の詳細

### エラー内容
```
The current Dart SDK version is 3.1.0.
Because dailyhabit requires SDK version ^3.8.1, version solving failed.
```

### 試した解決策

1. **subosito/flutter-action@v2のバージョン指定**
   - `flutter-version: '3.8.1'`を明示
   - 結果: 失敗（依然としてDart 3.1.0が使用される）

2. **Flutterキャッシュ削除**
   - `sudo rm -rf /opt/hostedtoolcache/flutter`を追加
   - 結果: 失敗

3. **手動Flutterセットアップ**
   - GitHubから直接Flutter安定版をクローン
   - `git clone https://github.com/flutter/flutter.git -b stable --depth 1`
   - 結果: 失敗

4. **各ステップでPATH明示指定**
   - 各ステップで`export PATH="$GITHUB_WORKSPACE/flutter/bin:$PATH"`を指定
   - 結果: 失敗

## 現在のワークフローファイル

`.github/workflows/deploy-gh-pages.yml`:
```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter manually
        run: |
          git clone https://github.com/flutter/flutter.git -b stable --depth 1
          export PATH="$GITHUB_WORKSPACE/flutter/bin:$PATH"
          flutter doctor

      - name: Check Flutter & Dart version
        run: |
          export PATH="$GITHUB_WORKSPACE/flutter/bin:$PATH"
          flutter --version
          dart --version

      - name: Install dependencies
        run: |
          export PATH="$GITHUB_WORKSPACE/flutter/bin:$PATH"
          flutter pub get

      - name: Build web
        run: |
          export PATH="$GITHUB_WORKSPACE/flutter/bin:$PATH"
          flutter build web

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## プロジェクト設定

### pubspec.yaml
```yaml
environment:
  sdk: ^3.8.1
```

### 現在のバージョン
```yaml
version: 1.0.0+3
```

## 成功したこと

1. **ローカルでのFlutter Webビルド**: `flutter build web`は正常に動作
2. **APKビルドと実機テスト**: Android実機で正常動作確認済み
3. **Google Play Console**: AABアップロード成功（クローズドテスト段階）

## 残る課題

- GitHub ActionsでのFlutter/Dartバージョン不整合問題
- PWA（Web版）の自動デプロイができない状態

## 次回の検討事項

1. **異なるCI/CDサービスの検討**（Netlify、Vercel、Firebase Hosting等）
2. **GitHub Actionsのrunnerイメージ変更**（ubuntu-22.04等）
3. **Flutter SDKの固定バージョン指定**
4. **手動デプロイからの段階的自動化**

## 参考リンク

- [Flutter公式CI/CD Documentation](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions Flutter Examples](https://github.com/flutter/flutter/tree/master/.github/workflows) 