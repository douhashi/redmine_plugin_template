# Redmine プラグインテンプレートリポジトリ

モダンな開発手法と包括的なツールセットを備えた、新しいRedmineプラグイン作成のためのすぐに使えるテンプレートリポジトリです。

## 概要

このテンプレートリポジトリは、Redmineプラグイン作成のための完全な開発環境と骨組みを提供します。新しいプラグインリポジトリの出発点として活用することで、以下が得られます：

- **完全な開発環境** - プラグイン開発をすぐに開始できるすべての要素
- **包括的ドキュメント** - プラグイン開発ワークフローの詳細ガイド

## はじめに

### このテンプレートから新しいプラグインを作成する

1. **このテンプレートを使用**して新しいリポジトリを作成：
   - GitHubで「Use this template」をクリック、または
   - このコードベースをクローンして新しいリポジトリを作成
2. **セットアップスクリプトを実行**してプラグインを設定する：
```bash
ruby scripts/setup_plugin.rb
```

このスクリプトでは以下の入力が求められます：
- プラグインID（内部識別用）
- プラグイン名と説明
- 作成者情報とURL
- バージョン番号

## テンプレート構造

### ファイル構成
```
├── init.rb                      # プラグイン登録と設定
├── app/                         # アプリケーションコード（MVCパターン）
│   ├── controllers/             # リクエスト処理とビジネスロジック
│   └── views/                   # ユーザーインターフェーステンプレート
├── config/                      # 設定ファイル
│   ├── locales/                 # 国際化ファイル
│   └── routes.rb                # URLルーティング定義
├── docs/                        # 包括的な開発ガイド
├── scripts/                     # 自動化とセットアップツール
│   └── setup_plugin.rb          # インタラクティブなプラグイン設定スクリプト
├── README.md                    # 英語ドキュメント
└── README.ja.md                 # 日本語ドキュメント
```

## 付属ドキュメント

このテンプレートには`docs/`ディレクトリに広範囲な開発ドキュメントが含まれています：

### コアガイド
- **[docs/README.md](./docs/README.md)** - 完全なドキュメント索引とナビゲーション
- **[docs/plugin-development/basic-structure.md](./docs/plugin-development/basic-structure.md)** - プラグインアーキテクチャとファイル構成
- **[docs/core-architecture/models.md](./docs/core-architecture/models.md)** - Redmineの内部構造とパターン

### 高度なトピック
- **[docs/hooks-and-events/overview.md](./docs/hooks-and-events/overview.md)** - 拡張ポイントとイベントシステム
- **[docs/examples/basic-plugin.md](./docs/examples/basic-plugin.md)** - 完全な実装ウォークスルー

### 学習リソース
- 詳細なコメント付きの動作サンプルコード
- 一般的なプラグインパターンとアンチパターン
- Redmineの既存機能との統合
- セキュリティとパフォーマンスの考慮事項

## 環境要件

**対応Redmineバージョン：**
- Redmine 6.0以降のバージョン
- Ruby 3.2、3.3、または3.4
- Rails 7.x系

**開発環境：**
- バージョン管理用Git
- Ruby対応のテキストエディターまたはIDE
- テスト用ローカルRedmineインストール

## DevContainer開発環境

このテンプレートはDevContainer（開発コンテナ）に対応しており、一貫性のある開発環境を提供します。

### DevContainer構成

開発環境では以下のディレクトリ構成でRedmineとプラグインが配置されます：

```
/workspace/
├── redmine/                     # Redmine本体（git clone）
│   ├── app/
│   ├── plugins/
│   │   └── {plugin_name}/       # シンボリックリンク → /workspace/src
│   └── ...
└── src/                         # このプラグインリポジトリ
    ├── init.rb
    ├── app/
    ├── config/
    └── ...
```

### 開発ワークフロー

1. **DevContainer起動時の自動セットアップ**：
   - `/workspace/redmine`にRedmine本体がクローンされます
   - `/workspace/src`にこのプラグインの内容が配置されます
   - `/workspace/redmine/plugins/{plugin_name}`にシンボリックリンクが作成されます

2. **開発プロセス**：
   - `/workspace/src`でプラグインコードを編集
   - 変更は自動的にRedmine環境に反映される（シンボリックリンク経由）
   - Redmineサーバーの再起動で変更を確認

## テンプレートの保守

### テンプレートへの貢献

Redmineコミュニティのためにこのテンプレートの改善をサポート：

1. **テンプレート改善**: テンプレート拡張のためにこのリポジトリをフォーク
2. **ドキュメント更新**: ガイドと例の改善を提出
3. **バグ報告**: テンプレート構造やセットアップツールの問題を報告
4. **機能要求**: 含めるべき追加ツールやパターンを提案

### ヘルプの取得
- **テンプレートの問題**: [GitHub Issues](https://github.com/douhashi/redmine_plugin_template/issues)
- **プラグイン開発**: 包括的な`docs/`ディレクトリを参照
- **Redmineコミュニティ**: 公式Redmineフォーラムとドキュメント

## ライセンス

このテンプレートはMITライセンスで提供されています。詳細は[LICENSE](LICENSE)をご覧ください。

このテンプレートからプラグインを作成する場合、以下が自由にできます：
- プラグインに任意のライセンスを使用
- テンプレートの帰属を変更または削除
- プラグインを商用またはオープンソースとして配布

## テンプレート作成者

**Sho DOUHASHI**
- GitHub: [@douhashi](https://github.com/douhashi)
- テンプレートリポジトリ: [redmine_plugin_template](https://github.com/douhashi/redmine_plugin_template)
