# Redmineプラグイン開発ガイド

## プロジェクト概要

このプロジェクトはRedmineのソースコードリポジトリです。Redmineは、Ruby on Railsで構築されたプロジェクト管理Webアプリケーションです。

## プラグイン開発について

Redmineは強力なプラグインシステムを備えており、コアコードを変更することなく機能を拡張できます。プラグイン開発に関する包括的なドキュメントは`docs/`ディレクトリに整備されています。

## ドキュメント構成

### 1. プラグイン開発基礎
- [プラグイン基本構造](./plugin-development/basic-structure.md) - プラグインの基本的な構造とファイル組織
- [プラグイン開発環境](./plugin-development/development-environment.md) - 開発環境のセットアップ方法
- [プラグインライフサイクル](./plugin-development/plugin-lifecycle.md) - プラグインの初期化、設定、マイグレーション

### 2. コアアーキテクチャ
- [モデル構造](./core-architecture/models.md) - Redmineのコアモデルとその関係性
- [コントローラー構造](./core-architecture/controllers.md) - コントローラーの組織とパターン
- [権限システム](./core-architecture/permissions.md) - 権限・アクセス制御の仕組み
- [メニューシステム](./core-architecture/menu-system.md) - メニュー管理とカスタマイズ

### 3. フック・イベントシステム
- [フックシステム概要](./hooks-and-events/overview.md) - フックシステムの基本概念
- [ビューフック](./hooks-and-events/view-hooks.md) - ビューレイヤーでのフック利用
- [コントローラーフック](./hooks-and-events/controller-hooks.md) - コントローラーレイヤーでのフック利用
- [フック実装例](./hooks-and-events/implementation-examples.md) - 具体的な実装パターン

### 4. 実装例
- [基本プラグイン](./examples/basic-plugin.md) - 最小限のプラグイン実装例
- [メニュー拡張](./examples/menu-extension.md) - メニューアイテム追加の例
- [カスタムフィールド](./examples/custom-fields.md) - カスタムフィールド実装例
- [権限カスタマイズ](./examples/permissions.md) - 権限システムのカスタマイズ例

## AIによる利用時の注意点

このドキュメントはvibe codingでAIが利用することを前提に、以下の点を重視して構造化されています：

1. **機械可読性**: 階層的で明確な構造
2. **正確性**: 実際のソースコードに基づく情報
3. **完全性**: プラグイン開発に必要な全要素を網羅
4. **更新可能性**: 新しい情報の追加が容易

## Redmineバージョン情報

このドキュメントは以下のRedmineバージョンを基準としています：
- Ruby 3.2, 3.3, 3.4対応
- Rails 7.x系
- PostgreSQL, MySQL, SQLite3対応
- プラグインAPIバージョン: 最新

## 使用法

各markdownファイルは独立して読むことができますが、プラグイン開発の初心者は以下の順序で読むことを推奨します：

1. プラグイン基本構造
2. コアアーキテクチャ
3. フックシステム概要
4. 実装例

## 更新履歴

- 初版: Redmineソースコード解析による包括的ドキュメント作成