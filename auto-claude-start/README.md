# テストランチャー

AI評価用の汎用テストランチャー

## ファイル
- `test_launcher.ps1` - メインランチャースクリプト（これを実行）
- `README.md` - このファイル

**注意**: バックアップファイル（.bakなど）が存在する場合がありますが、実行するのは`test_launcher.ps1`のみです。

## 使用方法
```powershell
powershell.exe -ExecutionPolicy Bypass -File test_launcher.ps1
```

## 重要な改善点
- **Enter送信前の待機**: テキスト入力後、2秒待機してからEnterを送信（文字化け防止）
- **エンコーディング対応**: UTF-8 BOM付きで保存（日本語環境での動作を安定化）

## トラブルシューティング
もし指示が正しく送信されない場合：
1. スクリプト87行目の`Start-Sleep -Seconds 2`を3秒や5秒に変更
2. Claude Codeの起動待ち時間（76行目）を延長

詳細は親フォルダの`QUICK_START.md`を参照してください。