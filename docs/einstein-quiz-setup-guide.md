# アインシュタインクイズ実施ガイド - 複数AIによる独立解答のための設定

## 概要
複数のAIに同じ論理パズルを独立して解かせる際の手順と注意点をまとめたガイドです。

## 必要なファイル構成
```
claude-test-100/
├── アインシュタインクイズ.txt  # 問題文（答えなし）
├── einstein-quiz-answers/        # 回答収集用フォルダ
│   ├── AI1-answer.txt
│   ├── AI2-answer.txt
│   └── ...
└── auto-claude-start/
    └── einstein_quiz_launcher.ps1  # AI起動スクリプト
```

## 実装時の重要ポイント

### 1. 文字エンコーディング問題
**問題**: PowerShellで日本語を含むヒアドキュメントを使用するとエンコーディングエラーが発生
**解決策**: 
- 英語でインストラクションを送信
- ファイルパスは日本語でもそのまま使用可能

### 2. 回答の独立性確保
**重要**: 各AIが他のAIの回答を見られないようにする
**実装方法**:
- 各AIに個別の一時ファイルパス（`/tmp/einstein_answer_[timestamp].txt`）を指定
- タイムスタンプで一意性を保証
- 回答完了後に管理者が収集

### 3. スクリプトの構成
```powershell
# タイムスタンプ生成
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# 英語でのインストラクション（日本語エンコーディング問題回避）
$instruction = "Please solve the Einstein puzzle located at /mnt/c/Users/user/claude-test-100/アインシュタインクイズ.txt and save your answer to /tmp/einstein_answer_$timestamp.txt - The file is in Japanese, please read it carefully and solve who owns the fish. Write your reasoning process and final answer in the output file."
```

### 4. 自動化の流れ
1. PowerShellスクリプトが新しいコマンドプロンプトを起動
2. WSL環境に入る
3. `claude`コマンドでAIを起動
4. クイズの指示を自動送信
5. AIが独立して問題を解く
6. 回答を一時ファイルに保存

## 次回実施時のチェックリスト

### 準備段階
- [ ] 問題ファイルが正しい場所にあるか確認
- [ ] einstein-quiz-answersフォルダが存在するか確認
- [ ] PowerShellスクリプトの実行権限があるか確認

### 実行時
- [ ] コマンドプロンプトウィンドウをクリックしてアクティブにする
- [ ] IMEが無効化されているか確認（英語入力モード）
- [ ] 各AIの回答ファイル名（タイムスタンプ）を記録

### 収集時
- [ ] 各AIの一時ファイルから回答を収集
- [ ] AI番号を付けて共通フォルダに保存（AI1-answer.txt, AI2-answer.txt...）
- [ ] 他のAIが前の回答を見ていないことを確認

## トラブルシューティング

### エンコーディングエラーが発生した場合
- PowerShellスクリプト内の日本語を英語に置き換える
- ファイルパスの日本語は問題ないが、SendKeysで送る文字列は英語にする

### ファイルが見つからない場合
- フルパスを使用する（`/mnt/c/Users/user/...`）
- 相対パスは避ける

### AIが回答を保存しない場合
- 一時ファイルのパスが正しいか確認
- `/tmp/`ディレクトリの書き込み権限を確認

## 実施結果の例
- AI1の回答: ドイツ人が魚を飼っている
- 推論過程も含めて約93行の詳細な解答
- 全16条件を満たす唯一の解を導出

## 今後の改善案
1. 複数AIを同時並行で起動する機能
2. 回答の自動収集スクリプト
3. 回答の比較分析ツール
4. 異なるモデル（GPT、Gemini等）での実施対応