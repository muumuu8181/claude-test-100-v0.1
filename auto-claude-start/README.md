# Auto Claude Start

Claude Code自動起動スクリプト集 - cmd → wsl → claude → hello を自動実行

## 概要

このスクリプトは、Windows環境で以下の手順を自動実行します：

1. 新しいコマンドプロンプトウィンドウを起動
2. `wsl` コマンドを入力してWSL環境に入る
3. `claude` コマンドを入力してClaude Codeを起動
4. `hello` を入力してテスト

## ファイル構成

- `automate_commands_v2.ps1` - PowerShellスクリプト（推奨）
- `window_automation_script.py` - Pythonスクリプト（基本版）
- `einstein_quiz_launcher.ps1` - アインシュタインクイズ実施用スクリプト

## 使用方法

### PowerShellスクリプト（推奨）

```powershell
powershell.exe -ExecutionPolicy Bypass -File automate_commands_v2.ps1
```

### Pythonスクリプト

```bash
python3 window_automation_script.py
```

## 特徴

- **IME自動制御**: 日本語IMEを自動的に無効化して半角英数入力を保証
- **Win32 API使用**: 確実なウィンドウ操作とキー入力制御
- **待機時間調整**: 各ステップ間で適切な待機時間を設定
- **エラー対応**: フェイルセーフ機能付き

## 動作環境

- Windows 10/11
- WSL2
- Claude Code
- PowerShell 5.0以上

## 注意事項

- スクリプト実行中は他の作業を中断してください
- 新しく開いたコマンドプロンプトウィンドウがアクティブになります
- IMEの状態によっては初回実行で調整が必要な場合があります

## トラブルシューティング

### 全角文字が入力される場合

PowerShellスクリプト（v2版）を使用してください。Win32 APIによるIME制御で問題を解決します。

### ウィンドウがアクティブにならない場合

スクリプト実行後、手動で新しく開いたコマンドプロンプトウィンドウをクリックしてアクティブにしてください。

## アインシュタインクイズ実施機能

### einstein_quiz_launcher.ps1
複数のAIにアインシュタインクイズを解かせるための専用スクリプトです。

**使用方法：**
```powershell
powershell.exe -ExecutionPolicy Bypass -File einstein_quiz_launcher.ps1
```

**機能：**
- 新しいClaude AIインスタンスを起動
- クイズファイル（`/mnt/c/Users/user/claude-test-100/アインシュタインクイズ.txt`）を自動提供
- タイムスタンプ付きの一時ファイルに回答を保存
- 他のAIの回答が見えない独立実行環境

詳細は[EINSTEIN_QUIZ_COMPLETE_GUIDE.md](../EINSTEIN_QUIZ_COMPLETE_GUIDE.md)を参照してください。

## 開発履歴

- v2.1: アインシュタインクイズ実施機能追加
- v2.0: Win32 API によるIME制御機能追加
- v1.0: 基本的なウィンドウ自動操作機能

## ライセンス

MIT License