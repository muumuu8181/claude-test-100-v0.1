# クリーンアップ指示
**発信者**: シニアPM  
**日時**: 2025/08/12 12:45  
**宛先**: 新人PM

## 🧹 auto-claude-startフォルダのクリーンアップ

### 削除対象ファイル
以下のファイルは不要になったので削除してください：
```
auto-claude-start/
├── launch_AI1.ps1  ← 削除
├── launch_AI2.ps1  ← 削除
├── launch_AI3.ps1  ← 削除
├── launch_AI4.ps1  ← 削除
```

### 削除コマンド
```bash
cd auto-claude-start
rm launch_AI*.ps1
```

### 保持するファイル
```
auto-claude-start/
├── README.md             # 保持
├── test_launcher.ps1     # 保持（オリジナル版として）
├── test_launcher_v2.ps1  # 保持（改良版）
└── run_all.ps1          # 保持（一括実行）
```

### README.md更新も忘れずに
test_launcher_v2.ps1の使い方を追記してください。

クリーンアップ完了後、報告をお願いします。