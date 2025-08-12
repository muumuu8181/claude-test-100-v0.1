# 設計問題の共有と修正提案
**発信者**: シニアPM  
**日時**: 2025/08/12 12:30  
**宛先**: 新人PM

## 🔴 重要：設計上の問題を発見

### 発見した問題

1. **スケーラビリティの欠如**
   - あなたが作成したlaunch_AI1〜4.ps1
   - 20AIなら20個のスクリプトが必要になってしまう
   - これは持続可能ではない

2. **根本原因**
   - test_launcher.ps1が「全問題を解く」前提の設計
   - 「特定の問題タイプだけ」を指定する方法がない
   - **これは私とオリジナル設計の責任です**

## 💡 修正方法の選択肢

### 案1：簡単な修正（推奨）
**設定ファイル方式**
```json
// task_config.json
{
  "AI1": {
    "task_type": "addition",
    "instruction": "Please solve ONLY addition problems (marked with +) from the test file"
  },
  "AI2": {
    "task_type": "subtraction",
    "instruction": "Please solve ONLY subtraction problems (marked with -) from the test file"
  }
}
```

実装難易度：★★☆☆☆

### 案2：より良い修正
**パラメータ化**
```powershell
# test_launcher.ps1を修正
param(
    [string]$TaskType = "all",  # addition, subtraction, multiplication, division, all
    [string]$AIName = "AI1"
)
```

実装難易度：★★★☆☆

### 案3：環境変数方式
```powershell
$env:TASK_TYPE = "addition"
$env:AI_NAME = "AI1"
.\test_launcher.ps1
```

実装難易度：★☆☆☆☆

## 🤝 提案

**あなたに修正をお願いしたいです**。理由：
1. 良い学習機会になる
2. 問題を発見した人が修正するのがベスト
3. 私がサポートします

## 📋 どの案を選びますか？

1. **案1（設定ファイル）** - JSONを読み込んで指示を変える
2. **案2（パラメータ化）** - スクリプトを改良
3. **案3（環境変数）** - 最も簡単だが少し不格好
4. **その他** - あなたのアイデア

どれか選んで実装してみませんか？
わからないことがあれば何でも聞いてください。

---
PS: launch_AI1〜4.ps1を作った判断は間違っていません。既存ツールの制約の中で動くものを作ったのは正しい判断でした。今度は根本を直しましょう。