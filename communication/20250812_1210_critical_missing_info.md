# 🔴 重要：実行方法の追加情報
**発信者**: シニアPM  
**日時**: 2025/08/12 12:10  
**宛先**: 新人PM

## 😓 私のミスをお詫びします

READMEに重要な情報が抜けていました。申し訳ございません。

## 🚨 緊急で伝えるべきこと

### auto-claude-start/フォルダの存在と使い方

**これが最も重要です！** AIを自動起動するツールがあります：
- `auto-claude-start/test_launcher.ps1`

### 正しい実行手順（完全版）

#### STEP 1: test_launcher.ps1を修正
```powershell
# auto-claude-start/test_launcher.ps1を開いて4-6行目を修正：

# 変更前：
$PROJECT_PATH = "C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100"
$TEST_FILE_PATH = "/mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/sample-test.txt"

# 変更後：
$PROJECT_PATH = "C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100\test-20250812"
$TEST_FILE_PATH = "/mnt/c/Users/user/Desktop/work/90_cc/20250812/claude-test-100/test-20250812/sample-test.txt"
```

#### STEP 2: 各AI用にスクリプトを実行
```powershell
# PowerShellを管理者権限で開く
cd C:\Users\user\Desktop\work\90_cc\20250812\claude-test-100\auto-claude-start

# AI1を起動（新しいウィンドウが開きます）
powershell.exe -ExecutionPolicy Bypass -File test_launcher.ps1

# 重要：新しいウィンドウをクリックしてアクティブにする！
# AIが自動的にテストを解き始めます
```

#### STEP 3: 各AIに異なる指示を出す方法

実は`simple_task.txt`は不要でした。理由：
- test_launcher.ps1が自動的に`sample-test.txt`を読み込む
- AIに「足し算だけ解いて」という指示を追加で送る

### 📝 修正版の作業フロー

1. **test_launcher.ps1のパスを修正**（上記参照）

2. **AI1起動時の追加指示**
   - スクリプト実行後、AIが起動したら追加で入力：
   - 「sample-test.txtの足し算問題（1+1, 5+7など）だけを解いてください」

3. **AI2〜4も同様に**
   - AI2: 「引き算問題だけ」
   - AI3: 「掛け算問題だけ」  
   - AI4: 「割り算問題だけ」

### ❌ あなたの`simple_task.txt`について

作成していただいたファイルは良い内容でしたが、実は：
- test_launcher.ps1は`sample-test.txt`を使う設計
- `simple_task.txt`は認識されません

ただし、内容は適切でした！

### 📋 今すぐやるべきこと

1. test_launcher.ps1のパスを修正
2. 4つのコマンドプロンプトウィンドウで各AIを起動
3. それぞれに役割（足し算/引き算/掛け算/割り算）を指示
4. 結果を収集

## 🙇 改めてお詫び

私がREADMEを簡潔にしすぎて、最も重要な**実行方法**を削除してしまいました。
これが混乱の原因の一つでした。申し訳ございません。

質問があれば遠慮なく聞いてください！