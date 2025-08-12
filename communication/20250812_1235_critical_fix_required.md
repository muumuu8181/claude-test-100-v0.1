# 🔴 緊急修正指示：スケーラビリティ問題の解決
**発信者**: シニアPM  
**日時**: 2025/08/12 12:35  
**宛先**: 新人PM
**優先度**: 高

## 📊 現状分析

### 何が起きているか
```
現在の構造：
auto-claude-start/
├── test_launcher.ps1      # 原本（全問題を解く設計）
├── launch_AI1.ps1         # AI1専用（あなたが作成）
├── launch_AI2.ps1         # AI2専用（あなたが作成）
├── launch_AI3.ps1         # AI3専用（あなたが作成）
└── launch_AI4.ps1         # AI4専用（あなたが作成）
```

**4AI = 4スクリプト**
**100AI = 100スクリプト？** ← これは破綻する

## 🔥 何がまずいのか

### 1. スケーラビリティゼロ
- **現状**: N個のAI = N個のスクリプト作成
- **問題**: 20AI、100AIでは管理不可能
- **影響**: 手作業が線形増加、ミスの温床

### 2. test_launcher.ps1の設計欠陥
```powershell
# 現在のコード（84行目）
$instruction = "Please solve the test problems located at $TEST_FILE_PATH and save your answers to /tmp/test_answer_$timestamp.txt."
```
- **ハードコード**された指示
- タスクタイプを指定する方法がない
- 「足し算だけ」という指示を渡せない

### 3. 重複コードの大量発生
- launch_AI1〜4.ps1はほぼ同じ内容
- 違いは指示文だけ
- **DRY原則違反**（Don't Repeat Yourself）

## ✅ どう修正すべきか

### 修正方針：パラメータ化による単一スクリプト化

#### STEP 1: test_launcher.ps1を改良
```powershell
# 新しいtest_launcher.ps1の冒頭
param(
    [Parameter(Mandatory=$false)]
    [string]$TaskType = "all",  # addition/subtraction/multiplication/division/all
    
    [Parameter(Mandatory=$false)]
    [string]$AIName = "AI",     # AI1, AI2, AI3, AI4...
    
    [Parameter(Mandatory=$false)]
    [string]$CustomInstruction = ""  # カスタム指示（オプション）
)

# === Configuration ===
$PROJECT_PATH = "C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100\test-20250812"
$TEST_FILE_PATH = "/mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/test-20250812/sample-test.txt"
```

#### STEP 2: 指示文を動的生成（84行目付近を修正）
```powershell
# タスクタイプに応じた指示を生成
switch ($TaskType) {
    "addition" {
        $taskInstruction = "Please solve ONLY the addition problems (marked with +) from"
    }
    "subtraction" {
        $taskInstruction = "Please solve ONLY the subtraction problems (marked with -) from"
    }
    "multiplication" {
        $taskInstruction = "Please solve ONLY the multiplication problems (marked with * or ×) from"
    }
    "division" {
        $taskInstruction = "Please solve ONLY the division problems (marked with / or ÷) from"
    }
    default {
        $taskInstruction = "Please solve all the test problems from"
    }
}

# カスタム指示がある場合は追加
if ($CustomInstruction) {
    $instruction = "$CustomInstruction. Test file: $TEST_FILE_PATH. Save to: /tmp/test_answer_${AIName}_$timestamp.txt"
} else {
    $instruction = "$taskInstruction $TEST_FILE_PATH and save your answers to /tmp/test_answer_${AIName}_$timestamp.txt"
}

# 実際の送信
[System.Windows.Forms.SendKeys]::SendWait($instruction)
```

#### STEP 3: ウィンドウプロセスログにAI名を記録（45行目付近）
```powershell
# 修正前
$logEntry = "AI_NEW, $processId, $timestamp, Started"

# 修正後
$logEntry = "$AIName, $processId, $timestamp, Started, TaskType: $TaskType"
```

#### STEP 4: 実行方法の簡潔化
```powershell
# 使用例（単一コマンド）
.\test_launcher.ps1 -TaskType "addition" -AIName "AI1"
.\test_launcher.ps1 -TaskType "subtraction" -AIName "AI2"
.\test_launcher.ps1 -TaskType "multiplication" -AIName "AI3"
.\test_launcher.ps1 -TaskType "division" -AIName "AI4"

# または一括実行スクリプト（run_all.ps1）を作成
@("addition:AI1", "subtraction:AI2", "multiplication:AI3", "division:AI4") | ForEach-Object {
    $parts = $_.Split(':')
    Start-Process powershell -ArgumentList "-File test_launcher.ps1 -TaskType $($parts[0]) -AIName $($parts[1])"
    Start-Sleep -Seconds 10  # 干渉防止
}
```

## 📝 実装タスク

### 必須タスク
1. [ ] test_launcher.ps1にパラメータを追加
2. [ ] 指示文の動的生成ロジックを実装
3. [ ] ログ出力にAI名とタスクタイプを含める
4. [ ] 動作テスト（最低1つのAIで）

### オプションタスク
5. [ ] launch_AI1〜4.ps1を削除（不要になるため）
6. [ ] run_all.ps1を作成（一括実行用）
7. [ ] READMEに新しい使用方法を記載

## 🎯 成功基準

### 技術面
- **1つのスクリプト**で全AIに対応
- パラメータでタスク種別を指定可能
- 100AI対応でもスクリプトは1つ

### 検証方法
```powershell
# テスト実行
.\test_launcher.ps1 -TaskType "addition" -AIName "TestAI"
# → TestAIが足し算だけを解くことを確認
```

## ⏰ 期限
可能な限り早急に。ただし、理解しながら進めることが重要。

## 💬 サポート
- 不明な点は即座に質問してください
- PowerShellの文法で困ったら聞いてください
- 設計判断で迷ったら相談してください

## 🏁 完了報告
修正完了後、以下を報告：
1. 実装した内容
2. テスト結果
3. 困った点と解決方法
4. 所要時間

---
**重要**: これは「あなたのミス」ではありません。元の設計が不十分だったのです。
今回の修正で、より良いツールに進化させましょう。

頑張ってください！質問は遠慮なく。