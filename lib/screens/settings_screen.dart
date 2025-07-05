import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定の読み込みに失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    try {
      await _databaseService.updateUserSettings(newSettings);
      setState(() {
        _settings = newSettings;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定を更新しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定の更新に失敗しました: $e')),
        );
      }
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
                  children: [
                    // アプリ情報
                    _buildSection(
                      title: 'アプリ情報',
                      children: [
                        _buildInfoTile(
                          'アプリ名',
                          AppConstants.appName,
                          Icons.apps,
                        ),
                        _buildInfoTile(
                          'バージョン',
                          AppConstants.appVersion,
                          Icons.info,
                        ),
                      ],
                    ),

                    // 表示設定
                    _buildSection(
                      title: '表示設定',
                      children: [
                        _buildDropdownTile(
                          'テーマ',
                          _settings!.theme,
                          {
                            'light': 'ライト',
                            'dark': 'ダーク',
                            'system': 'システム設定に従う',
                          },
                          Icons.palette,
                          (value) {
                            final newSettings = _settings!.copyWith(
                              theme: value,
                              updatedAt: DateTime.now(),
                            );
                            _updateSettings(newSettings);
                          },
                        ),
                        _buildDropdownTile(
                          '言語',
                          _settings!.language,
                          {
                            'ja': '日本語',
                            'en': 'English',
                          },
                          Icons.language,
                          (value) {
                            final newSettings = _settings!.copyWith(
                              language: value,
                              updatedAt: DateTime.now(),
                            );
                            _updateSettings(newSettings);
                          },
                        ),
                      ],
                    ),

                    // 通知設定
                    _buildSection(
                      title: '通知設定',
                      children: [
                        _buildSwitchTile(
                          '通知を有効にする',
                          _settings!.notificationsEnabled,
                          Icons.notifications,
                          (value) {
                            final newSettings = _settings!.copyWith(
                              notificationsEnabled: value,
                              updatedAt: DateTime.now(),
                            );
                            _updateSettings(newSettings);
                          },
                        ),
                        _buildSwitchTile(
                          'サウンド',
                          _settings!.soundEnabled,
                          Icons.volume_up,
                          (value) {
                            final newSettings = _settings!.copyWith(
                              soundEnabled: value,
                              updatedAt: DateTime.now(),
                            );
                            _updateSettings(newSettings);
                          },
                        ),
                        _buildSwitchTile(
                          'バイブレーション',
                          _settings!.vibrationEnabled,
                          Icons.vibration,
                          (value) {
                            final newSettings = _settings!.copyWith(
                              vibrationEnabled: value,
                              updatedAt: DateTime.now(),
                            );
                            _updateSettings(newSettings);
                          },
                        ),
                      ],
                    ),

                    // データ管理
                    _buildSection(
                      title: 'データ管理',
                      children: [
                        _buildActionTile(
                          'データをエクスポート',
                          Icons.download,
                          () {
                            // TODO: データエクスポート機能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('エクスポート機能は準備中です')),
                            );
                          },
                        ),
                        _buildActionTile(
                          'データをバックアップ',
                          Icons.backup,
                          () {
                            // TODO: バックアップ機能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('バックアップ機能は準備中です')),
                            );
                          },
                        ),
                        _buildActionTile(
                          'データをリセット',
                          Icons.refresh,
                          () => _showResetDialog(),
                          isDestructive: true,
                        ),
                      ],
                    ),

                    // その他
                    _buildSection(
                      title: 'その他',
                      children: [
                        _buildActionTile(
                          'プライバシーポリシー',
                          Icons.privacy_tip,
                          () {
                            // TODO: プライバシーポリシー表示
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('プライバシーポリシーは準備中です')),
                            );
                          },
                        ),
                        _buildActionTile(
                          '利用規約',
                          Icons.description,
                          () {
                            // TODO: 利用規約表示
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('利用規約は準備中です')),
                            );
                          },
                        ),
                        _buildActionTile(
                          'お問い合わせ',
                          Icons.email,
                          () {
                            // TODO: お問い合わせ機能
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('お問い合わせ機能は準備中です')),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.largePadding),
                  ],
                ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            AppConstants.largePadding,
            AppConstants.defaultPadding,
            AppConstants.smallPadding,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppConstants.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    Map<String, String> options,
    IconData icon,
    Function(String) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: options.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppConstants.errorColor : AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppConstants.errorColor : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データをリセット'),
        content: const Text(
          'すべての習慣データを削除しますか？\nこの操作は元に戻せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetData();
            },
            style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    try {
      // TODO: データベースのリセット機能を実装
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('データリセット機能は準備中です')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データのリセットに失敗しました: $e')),
        );
      }
    }
  }
} 