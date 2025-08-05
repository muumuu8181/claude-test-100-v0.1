# アインシュタインクイズ実施完全ガイド

## 🎯 目的
複数のAIにアインシュタインクイズを独立して解かせ、回答を収集する作業の完全ガイドです。

## 📋 前提条件チェックリスト
- [ ] Windows環境である
- [ ] WSL2がインストールされている
- [ ] Claude Codeがインストールされている（`claude`コマンドが使える）
- [ ] PowerShellが使える
- [ ] `claude-ai-toolkit`リポジトリをクローン済み
- [ ] `claude-test-100`フォルダに必要ファイルをコピー済み

## 📁 必要なファイル構成
```
claude-test-100/
├── アインシュタインクイズ.txt         # 問題文（答えなし）
├── einstein-quiz-answers/              # 回答収集用フォルダ
│   └── (ここにAIの回答が保存される)
└── auto-claude-start/                  # 自動起動スクリプトフォルダ
    └── einstein_quiz_launcher.ps1      # クイズ実施用スクリプト
```

## 🚀 実施手順（ステップバイステップ）

### ステップ1: 作業ディレクトリへ移動
```bash
cd /mnt/c/Users/user/claude-test-100
```

### ステップ2: 必要なフォルダの存在確認
```bash
# 回答保存用フォルダがあるか確認
ls -la einstein-quiz-answers/

# なければ作成
mkdir -p einstein-quiz-answers
```

### ステップ3: PowerShellスクリプトの実行
```bash
# auto-claude-startフォルダに移動
cd auto-claude-start

# スクリプトを実行
powershell.exe -ExecutionPolicy Bypass -File einstein_quiz_launcher.ps1
```

### ステップ4: ウィンドウのアクティブ化【重要】
1. スクリプト実行後、以下のメッセージが表示されます：
   ```
   IMPORTANT: Click on the new command prompt window to make it active!
   Commands will be sent in 3 seconds...
   ```
2. **3秒以内に新しく開いたコマンドプロンプトウィンドウをクリックしてください**
3. これを忘れるとコマンドが正しく送信されません

### ステップ5: 自動処理の確認
スクリプトが以下の順序で自動実行されます：
1. WSL環境への切り替え
2. Claude Codeの起動
3. クイズの指示送信

以下のようなメッセージが表示されれば成功です：
```
Einstein Quiz instruction sent!
Claude Code is now working on the Einstein Quiz.
Answer will be saved to: /tmp/einstein_answer_20250801_235438.txt
```

**重要**: ファイル名の`20250801_235438`部分（タイムスタンプ）をメモしてください

### ステップ6: AIの作業完了を待つ
- 通常5〜10分程度かかります
- 新しいウィンドウでAIが問題を解いている様子が見えます
- プロンプトが戻ってきたら完了です

### ステップ7: 回答の確認
```bash
# 別のターミナルで実行（タイムスタンプは実際のものに置き換え）
cat /tmp/einstein_answer_20250801_235438.txt
```

### ステップ8: 回答の収集と保存
```bash
# claude-test-100ディレクトリに戻る
cd /mnt/c/Users/user/claude-test-100

# 回答をコピー（AI番号とタイムスタンプは適切に変更）
cp /tmp/einstein_answer_20250801_235438.txt einstein-quiz-answers/AI1-answer.txt
```

### ステップ9: 次のAIで繰り返す
2回目以降は以下の点に注意：
- AI番号を変更（AI2-answer.txt, AI3-answer.txt...）
- 新しいタイムスタンプが生成される

## 🔧 トラブルシューティング

### エラー: "cannot create regular file"
```bash
# フォルダが存在しない場合
mkdir -p /mnt/c/Users/user/claude-test-100/einstein-quiz-answers
```

### エラー: PowerShellスクリプトが見つからない
```bash
# 正しいディレクトリか確認
pwd  # 現在地を確認
ls   # ファイル一覧を確認

# 正しい場所に移動
cd /mnt/c/Users/user/claude-test-100/auto-claude-start
```

### エラー: 文字化けや日本語入力の問題
- スクリプトは英語で指示を送るので問題ありません
- ファイル名の日本語（アインシュタインクイズ.txt）は正常に処理されます

### ウィンドウのアクティブ化を忘れた場合
1. Ctrl+Cでスクリプトを中断
2. 新しいウィンドウを閉じる
3. 最初からやり直す

## 📝 チェックリスト（実施前）
- [ ] PowerShellスクリプトの場所を確認した
- [ ] einstein-quiz-answersフォルダが存在する
- [ ] 前のAIの回答ファイルが適切に保存されている

## 📊 実施記録テンプレート
```
AI1: 
- 開始時刻: 23:54:38
- ファイル名: einstein_answer_20250801_235438.txt
- 回答: ドイツ人
- 保存先: einstein-quiz-answers/AI1-answer.txt

AI2:
- 開始時刻: [記入]
- ファイル名: [記入]
- 回答: [記入]
- 保存先: einstein-quiz-answers/AI2-answer.txt
```

## 🎓 理解度確認
以下を理解していれば実施可能です：
1. PowerShellスクリプトの場所：`auto-claude-start/einstein_quiz_launcher.ps1`
2. 実行コマンド：`powershell.exe -ExecutionPolicy Bypass -File einstein_quiz_launcher.ps1`
3. ウィンドウのアクティブ化：3秒以内にクリック
4. 回答の保存先：`einstein-quiz-answers/AI[番号]-answer.txt`

## 💡 ヒント
- 複数のターミナルを開いておくと便利（スクリプト実行用と確認用）
- タイムスタンプは必ずメモする
- 各AIの実行間隔は特に制限なし（同時実行も可能）