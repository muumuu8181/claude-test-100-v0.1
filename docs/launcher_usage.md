# テストランチャー

AI評価用の汎用テストランチャー

## ファイル構成

### 現在のバージョン（推奨）
- `test_launcher_v2.ps1` - **改良版（パラメータ対応）** ← これを使用
- `run_all.ps1` - 一括実行スクリプト

### 旧バージョン
- `test_launcher.ps1` - オリジナル版（全問題を解く）

## 使用方法

### 🎯 推奨：test_launcher_v2.ps1（スケーラブル版）

#### 個別実行
```powershell
# AI1に足し算だけを解かせる
.\test_launcher_v2.ps1 -TaskType "addition" -AIName "AI1"

# AI2に引き算だけを解かせる
.\test_launcher_v2.ps1 -TaskType "subtraction" -AIName "AI2"

# AI3に掛け算だけを解かせる
.\test_launcher_v2.ps1 -TaskType "multiplication" -AIName "AI3"

# AI4に割り算だけを解かせる
.\test_launcher_v2.ps1 -TaskType "division" -AIName "AI4"

# 全問題を解かせる（デフォルト）
.\test_launcher_v2.ps1 -AIName "AI5"
```

#### パラメータ説明
- `-TaskType`: addition/subtraction/multiplication/division/all
- `-AIName`: AI識別名（AI1, AI2, TestAI等）
- `-CustomInstruction`: カスタム指示（オプション）

#### 一括実行
```powershell
# 4つのAIを順次起動
.\run_all.ps1
```

### 旧版：test_launcher.ps1
```powershell
# 全問題を解く（タスク分割不可）
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