# 新しいAIへの完全指示文（一発実行用）

## コピペ用指示文

```
あなたは複数のAIにアインシュタインクイズを解かせる司会進行役です。

【作業環境】
- 現在地: /mnt/c/Users/user/claude-test-100
- 必要なファイルは全て準備済み

【あなたのミッション】
新しいClaude AIインスタンスを起動してアインシュタインクイズを解かせ、その回答を収集・保存することです。

【ゴールの定義】
以下が完了したら成功です：
1. 新しいAIがアインシュタインクイズを解き終わっている
2. 回答ファイルがeinstein-quiz-answers/AI[番号]-answer.txtに保存されている
3. 実施記録（開始時刻、回答者、最終回答）が報告されている

【実行手順】
1. まずEINSTEIN_QUIZ_COMPLETE_GUIDE.mdを読んで手順を完全に理解する
2. 既存の回答数を確認して次のAI番号を決定する（ls einstein-quiz-answers/）
3. auto-claude-startフォルダに移動してPowerShellスクリプトを実行する
4. 3秒以内に新しいウィンドウをクリックする（重要！）
5. タイムスタンプをメモして5-10分待つ
6. 回答を確認して適切なファイル名で保存する
7. 実施記録を報告する

今すぐ開始してください。完了したら実施記録と共に報告してください。
```

## より詳細な一発実行指示文（エラーを防ぎたい場合）

```
あなたは複数のAIにアインシュタインクイズを解かせる司会進行役です。
以下の作業を最後まで完遂してください。途中で止まらず、全て実行してください。

【環境確認と準備】
現在地が/mnt/c/Users/user/claude-test-100であることを確認し、以下を実行：
1. cat EINSTEIN_QUIZ_COMPLETE_GUIDE.md で手順を読む
2. ls einstein-quiz-answers/ で既存回答を確認（次はAI何番か決定）
3. cd auto-claude-start でスクリプトフォルダに移動

【AIインスタンス起動】
4. powershell.exe -ExecutionPolicy Bypass -File einstein_quiz_launcher.ps1 を実行
5. 「IMPORTANT: Click on the new command prompt window」が出たら3秒以内に新ウィンドウをクリック
6. 「Answer will be saved to: /tmp/einstein_answer_XXXXXX.txt」のXXXXXX部分をメモ

【回答収集】
7. 5-10分待ってAIが解き終わるのを確認
8. cat /tmp/einstein_answer_[メモしたタイムスタンプ].txt で回答確認
9. cp /tmp/einstein_answer_[タイムスタンプ].txt einstein-quiz-answers/AI[番号]-answer.txt で保存

【完了報告】
10. 以下の形式で報告：
    - AI番号: AI[番号]
    - 開始時刻: [PowerShell実行時刻]
    - 最終回答: [誰が魚を飼っているか]
    - 保存先: einstein-quiz-answers/AI[番号]-answer.txt
    - ステータス: 完了

これら全てを順番に実行し、最後の報告まで完了させてください。
```

## 最もシンプルな指示（経験者向け）

```
/mnt/c/Users/user/claude-test-100でアインシュタインクイズ司会進行を実施してください。
EINSTEIN_QUIZ_COMPLETE_GUIDE.mdの手順に従い、新しいAIに問題を解かせて回答を収集し、
einstein-quiz-answers/AI[次の番号]-answer.txtに保存して実施記録を報告してください。
全て完了するまで実行してください。
```