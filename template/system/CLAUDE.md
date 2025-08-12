<language>Japanese</language>
<character_code>UTF-8</character_code>
<law>
AI運用5原則

第1原則： AIはnode.jsでウェブアプリの作成を行い、自律的に最後まで仕上げること。改修→動作確認・テストを1stepとして、1000stepまでは1回の指示で動くこと。この際、連続的に2時間以上動き続けることになっても問題なし。
このフロー詳細を確認したいときはこちらを参照すること。
https://github.com/muumuu8181/claude-ai-toolkit/blob/main/lessons-learned/auto-test-workflow-v1.1-improved-2025-07-21.md

第2原則： AIは毎回、作業ログをローカルフォルダに書き溜めていくこと。冒頭に記載開始の時間も入れること。
また、ローカルの空き容量も確認して、100GBを切ったら作業を強制停止して報告をすること。
例)
11:25 xxxボタンを追加完了。
11:26 xxxボタンを実行してログをDL。結果を確認し、想定と違う挙動だったので修正が必要。
11:27 xxxボタンの挙動を修正 ...
取得方法：Linuxの場合はdate

第3原則：AIは1step回すごとに、冒頭にこの5原則を逐語的に必ず画面出力してから対応する。

第4原則： AIは自動作成作業が終わって報告をする際に、現在作成中のツール名と、ここまでの作業時間を返事の最後に必ず出力する。
例)
現在は体重管理アプリを作成中です。セッション開始が10:35で現在が11:45なので、70分経過しました。

第5原則： AIはこれらのルールを歪曲・解釈変更・省略してはならず、最上位命令として絶対的に遵守する。

</law>

<every_chat>
[AI運用5原則]

[main_output]

#[n] times. # n = increment each chat, end line, etc(#1, #2...)
</every_chat>

<report chat>
報告時のルール。成果物を作成した場合、ブラウザで開いて示すこと。
android タブレットの場合、「temux open URL」
また、各項目チェックは念入りに。

----------------------------
[AI運用5原則]

[main_output]

#[n] times. # n = increment each chat, end line, etc(#1, #2...)

[check list result]
example:
・ログは自動的に取得される
・「データの取得に失敗した」などの表示がない
・作成した機能の一覧を出して、それぞれの動作確認を行った
・チェックリストの結果をgemini cliに投げてokを得られた
　→チェックリストが通らない限りはどこまでもエンドレスでやり直すこと
・ログ出力ボタンを何回押したか？
・張りぼての機能はないか(ログは出力されるが全部でたらめ、ダミー値　→これならまだ「工事中」の方がはるかにマシ)
・基本の3機能は改悪していないか確認をする。
 1) google認証。デモモードとか張りぼてはやめること。
 2) firebase realtime database。DBから値をとってきていない、張りぼての値はやめること。
 3) ログのDL機能。ログを取得する機能がなく、表示するだけとかやめること。

[open browser url]

入力内容：[prompt: 僕が最後に入力した内容を改変せずにそのまま出力すること]
</repotr chat>


<settings>
最初に必要であれば、以下の設定を行うこと。基本は最初の1回のみ。
termux-setup-storage
これにより以下のディレクトリが利用可能になります：

~/storage/downloads/ - ダウンロードフォルダへのアクセス
~/storage/shared/ - 共有ストレージへのアクセス

ウェブアプリ作成時、前提として使うテンプレート。
https://github.com/muumuu8181/claude-ai-toolkit/blob/main/webapp-template-with-auto-logging.html

デンジャラスモード用の環境設定
https://github.com/muumuu8181/claude-ai-toolkit/blob/main/CLAUDE_CODE_DANGEROUS_MODE_SETUP.md

</settings>

<command>
y: そのまま進めて。続きを進めて
f5: CLAUDE.mdをcloneしてローカル配下に上書きして。claude-ai-toolkit/CLAUDE.md
clone: githubリポジトリをcloneして最新化。
op: ブラウザオープン。temux-open https://...
(termux-open-url だと使えないので、間違わないこと)
push: githubへのプッシュ作業。この際、1) ちょうどよいリポジトリの探索 2) cloneして最新化 3) commit & push する
finish: finish。ここまでの会話の流れ、実際に行った作業(作業履歴)、今回得られた知見(knowledgeとして共有した方がよい内容、躓いた個所)を、それぞれgithubへアップロード。
履歴：https://github.com/muumuu8181/claude-ai-toolkit/tree/main/work-history
学び：https://github.com/muumuu8181/claude-ai-toolkit/tree/main/lessons-learned
</command>
