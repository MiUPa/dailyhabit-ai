# DailyHabit AI - ワイヤーフレーム

## 主要画面構成

### 1. ホーム画面（メイン）
```
┌─────────────────────────┐
│ [設定] DailyHabit AI [統計] │
├─────────────────────────┤
│ 今日の習慣 (3/5)        │
│ ┌─────────────────────┐ │
│ │ ☑️ 朝の散歩         │ │
│ │ ☑️ 読書30分         │ │
│ │ ☑️ 筋トレ           │ │
│ │ ⭕ 瞑想             │ │
│ │ ⭕ 日記             │ │
│ └─────────────────────┘ │
│                         │
│ 今週の進捗              │
│ ┌─────────────────────┐ │
│ │ ████████░░ 80%      │ │
│ │ 継続日数: 12日       │ │
│ └─────────────────────┘ │
│                         │
│ [習慣追加] [詳細を見る]  │
└─────────────────────────┘
```

### 2. 習慣追加画面
```
┌─────────────────────────┐
│ ← 習慣を追加            │
├─────────────────────────┤
│ 習慣名                  │
│ ┌─────────────────────┐ │
│ │ 朝の散歩            │ │
│ └─────────────────────┘ │
│                         │
│ 説明                    │
│ ┌─────────────────────┐ │
│ │ 30分の散歩で健康維持│ │
│ └─────────────────────┘ │
│                         │
│ カテゴリ                │
│ ○ 健康  ○ 学習        │
│ ○ 仕事  ○ 趣味        │
│                         │
│ 頻度                    │
│ ○ 毎日  ○ 週3回       │
│ ○ 週1回  ○ 月1回       │
│                         │
│ [保存] [キャンセル]     │
└─────────────────────────┘
```

### 3. 統計画面
```
┌─────────────────────────┐
│ [ホーム] 統計 [設定]    │
├─────────────────────────┤
│ 今月のサマリー          │
│ ┌─────────────────────┐ │
│ │ 総達成回数: 45回     │ │
│ │ 継続率: 85%         │ │
│ │ 最長ストリーク: 15日 │ │
│ └─────────────────────┘ │
│                         │
│ 継続率グラフ            │
│ ┌─────────────────────┐ │
│ │ ████████░░ 80%      │ │
│ │ 過去30日間          │ │
│ └─────────────────────┘ │
│                         │
│ AI分析                  │
│ ┌─────────────────────┐ │
│ │ あなたは朝型です    │ │
│ │ 朝の習慣達成率: 90% │ │
│ │ 夜の習慣達成率: 60% │ │
│ └─────────────────────┘ │
│                         │
│ [詳細レポート] [エクスポート] │
└─────────────────────────┘
```

### 4. 設定画面
```
┌─────────────────────────┐
│ [ホーム] 設定           │
├─────────────────────────┤
│ 通知設定                │
│ ┌─────────────────────┐ │
│ │ リマインダー: 09:00 │ │
│ │ 通知: ON            │ │
│ └─────────────────────┘ │
│                         │
│ テーマ                  │
│ ○ ライト  ○ ダーク    │
│                         │
│ データ管理              │
│ [バックアップ] [復元]   │
│ [データ削除]           │
│                         │
│ プレミアム              │
│ [アップグレード]       │
│                         │
│ アプリ情報              │
│ バージョン: 1.0.0      │
│ [プライバシーポリシー]  │
└─────────────────────────┘
```

## 画面遷移フロー

```
ホーム画面
├── 習慣追加 → 習慣追加画面
├── 詳細を見る → 統計画面
├── 設定 → 設定画面
└── 習慣タップ → 記録画面

統計画面
├── 詳細レポート → 詳細統計画面
├── エクスポート → ファイル選択
└── 戻る → ホーム画面

設定画面
├── アップグレード → 課金画面
├── バックアップ → ファイル保存
└── 戻る → ホーム画面
```

## 主要UI要素

### ボタン
- **プライマリ**: 青背景 (#6366F1)
- **セカンダリ**: 白背景 + 青ボーダー
- **サイズ**: 高さ48px、角丸12px

### カード
- **背景**: 白
- **角丸**: 16px
- **シャドウ**: 軽い影
- **パディング**: 16px

### 入力フィールド
- **背景**: ライトグレー (#F8FAFC)
- **角丸**: 8px
- **フォーカス**: 青ボーダー

### アイコン
- **サイズ**: 24px
- **カラー**: プライマリカラー
- **スタイル**: アウトライン 