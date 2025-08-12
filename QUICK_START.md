# 🚀 クイックスタートガイド

## このツールの機能
AI能力を評価するための汎用テストランチャー。サンプルとして簡単な数学問題を含んでいます。

## ⚠️ 初回設定（重要）
スクリプト内のパスを自分の環境に合わせて修正してください：

1. `auto-claude-start/test_launcher.ps1`を開く
2. 4-6行目の設定を変更：
```powershell
$PROJECT_PATH = "C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100"
$TEST_FILE_PATH = "/mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/sample-test.txt"
```

## 実行方法（3ステップ）

### 1️⃣ 作業ディレクトリに移動
```bash
cd /mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/auto-claude-start
```

### 2️⃣ スクリプトを実行

```bash
powershell.exe -ExecutionPolicy Bypass -File test_launcher.ps1
```

### 3️⃣ 新しいウィンドウをクリック（重要！）
- 「IMPORTANT: Click on the new command prompt window to make it active!」が表示されたら
- **3秒以内に新しく開いたウィンドウをクリック**してアクティブにする

## 実行後の流れ

1. AIが自動的に計算問題テストを解き始めます（5-10分）
2. 完了したら回答が `/tmp/test_answer_[タイムスタンプ].txt` に保存されます
3. 回答を `test-answers/test[番号]-answer.txt` にコピーして保存

## 回答の保存方法
```bash
# 例：AI5の回答を保存する場合
cp /tmp/test_answer_20250812_123456.txt ../test-answers/test5-answer.txt
```

## トラブルシューティング

**Q: ウィンドウのクリックを忘れた**
A: Ctrl+Cで中断し、最初からやり直してください

**Q: エラーが出た**
A: 以下を確認してください：
- パスが正しく設定されているか
- PowerShellの実行ポリシーが許可されているか
- WSLとClaude Codeがインストールされているか

## 📊 実施記録（テンプレート）
```
AI5:
- 開始時刻: 12:34:56
- ファイル: test_answer_20250812_123456.txt
- 結果: 5問全問正解
```