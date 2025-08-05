# Claude AI Toolkit

Claude AIを活用するための各種ツールやガイドをまとめたリポジトリです。

## 📚 コンテンツ

### 1. [ccusage完全ガイド](./ccusage-guide.md)
Claude Codeのトークン使用量とコストを分析するツール「ccusage」の詳細なガイドです。

- インストール方法
- 基本的な使い方
- 高度な機能
- 実用例
- 制限事項

### 2. 🔒 [Claude Code Safe Dangerous Mode](./claude-dangerous-mode/)
**NEW!** Claude Codeのデンジャラスモードを安全に使用するための統合ソリューション

- **⚡ コマンド一発インストール**: Android/Termux環境で即座に安全なデンジャラスモード環境を構築
- **🛡️ proot隔離環境**: システムファイルを完全保護する多層防護システム
- **💾 自動バックアップ**: 作業開始前の自動バックアップと一発復元機能
- **8️⃣ 複数端末対応**: 8台のタブレットで統一された安全環境
- **📱 Android特化**: Termux環境に最適化された設計

```bash
cd claude-dangerous-mode
./claude-dangerous-setup.sh  # コマンド一発で環境構築完了
```

**主な機能:**
- `cdg-safe` - 安全なデンジャラスモード起動
- `enter-sandbox` - proot隔離環境でのセキュア実行
- `restore-backup` - バックアップからの瞬時復元

## 🎯 このリポジトリの目的

Claude AIやClaude Codeを使用する際に役立つ情報を集約し、日本語で分かりやすく解説することを目的としています。

## 📝 貢献について

新しいツールの情報や使い方のガイドなど、プルリクエストを歓迎します。

## ⚠️ 免責事項

このリポジトリの情報は調査時点のものです。最新情報は各ツールの公式ドキュメントをご確認ください。

## 🧩 アインシュタインクイズ実施ツール

### [EINSTEIN_QUIZ_COMPLETE_GUIDE.md](./EINSTEIN_QUIZ_COMPLETE_GUIDE.md)
複数のAIにアインシュタインクイズを解かせるための完全ガイド。

**主な機能：**
- 新しいAIインスタンスの自動起動
- クイズファイルの自動提供
- 回答の独立性を保証（他AIの回答が見えない設計）
- 回答の自動収集と整理

**使用方法：**
```bash
cd auto-claude-start
powershell.exe -ExecutionPolicy Bypass -File einstein_quiz_launcher.ps1
```

詳細は[完全ガイド](./EINSTEIN_QUIZ_COMPLETE_GUIDE.md)を参照してください。

## 📅 更新履歴

- 2025-08-01: **アインシュタインクイズ実施ツール** 追加 - 複数AIによる独立解答システム
- 2025-07-22: **Claude Code Safe Dangerous Mode** 追加 - Android/Termux対応の安全なデンジャラスモード環境構築ツール
- 2025-07-19: リポジトリ作成、ccusageガイド追加

## 📧 連絡先

質問や提案がある場合は、Issueを作成してください。
