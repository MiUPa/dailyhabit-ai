import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  UserSettings? _settings;
  bool _isLoading = true;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final settings = await _databaseService.getUserSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    try {
      await _databaseService.updateUserSettings(newSettings);
      setState(() {
        _settings = newSettings;
      });
    } catch (e) {}
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
              ? const Center(child: Text('設定を読み込めませんでした'))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // テーマ設定
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('テーマ'),
                      trailing: DropdownButton<String>(
                        value: _settings!.theme,
                        items: const [
                          DropdownMenuItem(value: 'light', child: Text('ライト')),
                          DropdownMenuItem(value: 'dark', child: Text('ダーク')),
                          DropdownMenuItem(value: 'system', child: Text('システム')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _updateSettings(_settings!.copyWith(
                              theme: value,
                              updatedAt: DateTime.now(),
                            ));
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    // 通知設定
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: const Text('通知を有効にする'),
                      value: _settings!.notificationsEnabled,
                      onChanged: (value) {
                        _updateSettings(_settings!.copyWith(
                          notificationsEnabled: value,
                          updatedAt: DateTime.now(),
                        ));
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up),
                      title: const Text('サウンド'),
                      value: _settings!.soundEnabled,
                      onChanged: (value) {
                        _updateSettings(_settings!.copyWith(
                          soundEnabled: value,
                          updatedAt: DateTime.now(),
                        ));
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration),
                      title: const Text('バイブレーション'),
                      value: _settings!.vibrationEnabled,
                      onChanged: (value) {
                        _updateSettings(_settings!.copyWith(
                          vibrationEnabled: value,
                          updatedAt: DateTime.now(),
                        ));
                      },
                    ),
                    const Divider(),
                    // データ管理
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('データをエクスポート'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('エクスポート機能は準備中です')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text('データをバックアップ'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('バックアップ機能は準備中です')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('データをリセット'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('データリセット機能は準備中です')),
                        );
                      },
                    ),
                    const Divider(),
                    // バージョン・リンク
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('バージョン情報'),
                      subtitle: Text(_version.isNotEmpty ? 'バージョン: $_version' : '取得中...'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('利用規約'),
                      onTap: () => _launchUrl('https://example.com/terms'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('プライバシーポリシー'),
                      onTap: () => _launchUrl('https://example.com/privacy'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('お問い合わせ'),
                      onTap: () => _launchUrl('mailto:support@example.com?subject=DailyHabit%E3%81%8A%E5%95%8F%E3%81%84%E5%90%88%E3%82%8F%E3%81%9B'),
                    ),
                  ],
                ),
    );
  }
} 