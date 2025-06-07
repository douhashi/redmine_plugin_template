# プラグイン基本構造

## 概要

Redmineプラグインは、コアシステムを変更することなく機能を拡張するためのモジュラー構造を持ちます。プラグインは`plugins/`ディレクトリに配置され、Rails標準のMVCパターンに従って組織されます。

## 基本ディレクトリ構造

```
plugins/[plugin_name]/
├── init.rb                    # プラグイン登録ファイル（必須）
├── README.rdoc               # プラグインドキュメント
├── app/                      # アプリケーション層
│   ├── controllers/          # コントローラー
│   ├── helpers/             # ヘルパー
│   ├── models/              # モデル
│   └── views/               # ビュー
│       ├── [controller_name]/
│       ├── my/blocks/       # マイページブロック用
│       └── settings/        # プラグイン設定用
├── assets/                   # 静的アセット
│   ├── images/              # 画像ファイル
│   ├── javascripts/         # JavaScriptファイル
│   └── stylesheets/         # CSSファイル
├── config/                   # 設定ファイル
│   ├── locales/             # 国際化ファイル
│   │   ├── en.yml
│   │   └── [other_locales].yml
│   └── routes.rb            # ルーティング設定
├── db/                       # データベース関連
│   └── migrate/             # マイグレーションファイル
├── lib/                      # ライブラリファイル
│   └── tasks/               # Rakeタスク
└── test/                     # テストファイル
    ├── fixtures/            # テストフィクスチャ
    ├── functional/          # 機能テスト
    ├── integration/         # 統合テスト
    ├── system/             # システムテスト
    ├── unit/               # ユニットテスト
    └── test_helper.rb      # テストヘルパー
```

## 必須ファイル: init.rb

### 基本的なinit.rb構造

```ruby
Rails.logger.info 'Starting [Plugin Name] for Redmine'

Redmine::Plugin.register :plugin_symbol do
  name 'Plugin Display Name'
  author 'Author Name'
  description 'Plugin description'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  # Redmineバージョン要件（オプション）
  requires_redmine version_or_higher: '5.0.0'
  
  # プロジェクトモジュールの定義
  project_module :module_name do
    # 権限定義
    permission :permission_name, {
      :controller_name => [:action1, :action2]
    }, :public => false, :require => :member
  end
  
  # メニューアイテムの追加
  menu :project_menu, :menu_item_name, {
    :controller => 'controller_name',
    :action => 'action_name'
  }, :caption => 'Menu Item Caption', :param => :project_id
  
  # プラグイン設定の定義
  settings :default => {
    'setting_key' => 'default_value'
  }, :partial => 'settings/plugin_settings'
  
  # アクティビティプロバイダーの登録
  activity_provider :activity_type, :class_name => 'ModelClass'
end
```

### init.rbの主要オプション

#### プラグイン属性
- `name`: プラグインの表示名
- `author`: 作者名
- `description`: プラグインの説明
- `version`: バージョン番号
- `url`: プラグインのURL
- `author_url`: 作者のURL

#### バージョン要件
```ruby
# Redmineバージョン要件
requires_redmine version_or_higher: '5.0.0'
requires_redmine '5.0.0'  # 短縮形
requires_redmine :version => ['5.0.0', '5.1.0']  # 特定バージョン
requires_redmine :version => '5.0.0'..'5.2.0'    # バージョン範囲

# 他プラグインへの依存
requires_redmine_plugin :other_plugin, version_or_higher: '1.0.0'
```

#### プロジェクトモジュール
```ruby
project_module :module_name do
  # パブリック権限（すべてのユーザーに付与）
  permission :public_permission, {:controller => :action}, :public => true
  
  # ログインユーザー限定権限
  permission :loggedin_permission, {:controller => :action}, :require => :loggedin
  
  # プロジェクトメンバー限定権限
  permission :member_permission, {:controller => :action}, :require => :member
  
  # 読み取り専用権限（閉鎖プロジェクトでも有効）
  permission :read_permission, {:controller => :action}, :read => true
end
```

#### メニュー追加
```ruby
# プロジェクトメニュー
menu :project_menu, :item_name, url_hash, options

# アプリケーションメニュー  
menu :application_menu, :item_name, url_hash, options

# アカウントメニュー
menu :account_menu, :item_name, url_hash, options

# トップメニュー
menu :top_menu, :item_name, url_hash, options
```

#### 設定システム
```ruby
settings :default => {
  'boolean_setting' => true,
  'string_setting' => 'default_value',
  'array_setting' => ['option1', 'option2']
}, :partial => 'settings/plugin_settings'
```

## ファイル命名規則

### プラグイン名
- ディレクトリ名: `snake_case`（例: `my_awesome_plugin`）
- init.rbでの登録: `:snake_case`シンボル
- 表示名: 任意（例: "My Awesome Plugin"）

### ファイル・クラス命名
- コントローラー: `MyAwesome::PluginController < ApplicationController`
- モデル: `MyAwesome::PluginModel < ApplicationRecord`
- ヘルパー: `MyAwesome::PluginHelper`

## プラグインのライフサイクル

### 1. 初期化フェーズ
1. プラグインディレクトリの検出
2. `init.rb`の読み込み
3. プラグイン情報の登録
4. ビューパスの追加
5. 国際化ファイルの読み込み

### 2. 設定フェーズ
1. 設定定義の処理
2. 権限の登録
3. メニューアイテムの追加
4. アクティビティプロバイダーの登録

### 3. 実行時フェーズ
1. ルーティングの処理
2. コントローラーの読み込み
3. ビューの描画
4. フックの実行

## 開発時のベストプラクティス

### ディレクトリ構造
1. 必要最小限のファイルから開始
2. 機能の増加に合わせて段階的に構造を拡張
3. Rails標準の命名規則に従う

### init.rb設計
1. プラグイン情報は明確に記述
2. バージョン要件は適切に設定
3. 権限は細かく分割
4. メニューは適切な場所に配置

### 拡張性の考慮
1. 他プラグインとの競合を避ける
2. 適切な名前空間を使用
3. フックポイントを活用
4. 設定可能なオプションを提供

## 次のステップ

プラグインの基本構造を理解したら、以下を学習することを推奨します：

1. [プラグイン開発環境](./development-environment.md)
2. [コアアーキテクチャ: モデル構造](../core-architecture/models.md)
3. [フックシステム概要](../hooks-and-events/overview.md)
4. [基本プラグイン実装例](../examples/basic-plugin.md)