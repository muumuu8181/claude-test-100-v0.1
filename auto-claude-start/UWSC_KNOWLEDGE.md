# UWSC 知見まとめ

## 1. エラーと解決方法

### SyntaxError: ST_CLASS
**問題**: `STATUS(hwnd, ST_CLASS)` でエラーが発生
**原因**: 
- 変数名に`class`を使用（予約語の可能性）
- HWNDが0または無効な値の場合

**解決方法**:
```uwsc
// NG
class = STATUS(hwnd, ST_CLASS)

// OK
clsname = STATUS(hwnd, ST_CLASS)

// より安全な方法
IF hwnd > 0 THEN
    clsname = STATUS(hwnd, ST_CLASS)
ENDIF
```

### GETID関数での繰り返し問題
**問題**: `GETID("", "", i)` で同じIDが繰り返される
**解決方法**: `GETALLWIN()` と `ALL_WIN_ID` 配列を使用

```uwsc
count = GETALLWIN()
FOR i = 0 TO count - 1
    id = ALL_WIN_ID[i]
    // 処理
NEXT
```

## 2. 便利な機能

### スクリーンショット
```uwsc
// JPEG形式で保存（圧縮率70）
SAVEIMG("path.jpg", 0, , , , , , 70)

// BMP形式（無圧縮）
SAVEIMG("path.bmp", 0)
```

### エラーダイアログの自動クローズ
```uwsc
// 全ウィンドウから探す
count = GETALLWIN()
FOR i = 0 TO count - 1
    id = ALL_WIN_ID[i]
    IF id > 0 THEN
        title = STATUS(id, ST_TITLE)
        IF POS("Error", title) > 0 THEN
            CLKITEM(id, "OK", CLK_BTN)
        ENDIF
    ENDIF
NEXT
```

### ファイル操作
```uwsc
// 必ずFCLOSEを忘れずに！
fid = FOPEN("file.txt", F_WRITE)
FPUT(fid, "text")
FCLOSE(fid)  // これを忘れるとファイルが作成されない
```

## 3. デバッグテクニック

### エラー時の自動スクリーンショット
```uwsc
TRY
    // エラーが出そうな処理
EXCEPT
    SAVEIMG("error_screenshot.jpg", 0, , , , , , 80)
ENDTRY
```

### ウィンドウ状態の確認
```uwsc
// 起動前後の比較
before = GETALLWIN()
// 何か処理
after = GETALLWIN()
PRINT "増加数: " + (after - before)
```

## 4. 文字入力関数

### SENDSTR関数の注意点
```uwsc
// 間違い - クリップボードに保存するだけ
SENDSTR(0, "text")

// 正しい - 特定のウィンドウに送信
window_id = GETID("Window Title")
SENDSTR(window_id, "text")

// または一文字ずつキー送信
KBD(VK_W)
KBD(VK_S) 
KBD(VK_L)
```

**重要**: SENDSTR(0, text) は**クリップボード**に文字列を保存するだけで、ウィンドウには入力されない！

### 正しいキーボード入力の実装例
```uwsc
// PowerShellウィンドウに文字入力する正しい方法
ps_id = GETID("Windows PowerShell", "ConsoleWindowClass")
IF ps_id = 0 THEN
    ps_id = GETID("PowerShell", "CASCADIA_HOSTING_WINDOW_CLASS")
ENDIF

IF ps_id > 0 THEN
    CTRLWIN(ps_id, ACTIVATE)     // ウィンドウをアクティブに
    SLEEP(0.5)                   // 少し待つ
    SENDSTR(ps_id, "Hello")      // 正しい方法：ウィンドウIDを指定
    SCKEY(ps_id, VK_RETURN)      // Enterキー送信
ENDIF
```

## 5. UWSCの正しい実行方法

### 実行パス
```bash
# PowerShellから実行
& 'C:\Users\user\Downloads\uwsc5302 (1)\UWSC.exe' 'スクリプトのフルパス'

# 例
& 'C:\Users\user\Downloads\uwsc5302 (1)\UWSC.exe' 'C:\Users\user\claude-test-100-v0.2\auto-claude-start\script.uws'
```

### 実際に動作確認した文字入力スクリプト
```uwsc
// 全ウィンドウから対象を探す
count = GETALLWIN()
target_id = 0

FOR i = 0 TO count - 1
    id = ALL_WIN_ID[i]
    IF id > 0 THEN
        title = STATUS(id, ST_TITLE)
        IF POS("PowerShell", title) > 0 THEN
            target_id = id
            BREAK
        ENDIF
    ENDIF
NEXT

IF target_id > 0 THEN
    CTRLWIN(target_id, ACTIVATE)
    SLEEP(1)
    SENDSTR(target_id, "Hello from UWSC")
    SCKEY(target_id, VK_RETURN)
ENDIF
```

## 6. 注意点

- `EXEC()` の戻り値は常に確認（-1の場合は失敗）
- ウィンドウIDは必ず > 0 を確認してから使用
- 日本語を含むパスは文字化けする可能性がある
- MSGBOXを使うとスクリプトが停止するので、自動化には不向き
- SENDSTR(0, text)はクリップボード操作であることに注意