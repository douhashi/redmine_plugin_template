# Redmineプラグイン開発ガイド

## プロジェクト概要

このプロジェクトはRedmineのソースコードリポジトリです。Redmineは、Ruby on Railsで構築されたプロジェクト管理Webアプリケーションです。

## プラグイン開発について

Redmineは強力なプラグインシステムを備えており、コアコードを変更することなく機能を拡張できます。プラグイン開発に関する包括的なドキュメントは`docs/`ディレクトリに整備されています。

### ドキュメント構成

プラグイン開発に必要な情報は以下のドキュメントに体系的にまとめられています：

#### 📖 基本ガイド
- **[docs/README.md](./docs/README.md)** - ドキュメント全体の概要とナビゲーション
- **[docs/plugin-development/basic-structure.md](./docs/plugin-development/basic-structure.md)** - プラグインの基本構造とinit.rb詳細

#### 🏗️ アーキテクチャ
- **[docs/core-architecture/models.md](./docs/core-architecture/models.md)** - Redmineコアモデル構造とSTIパターン

#### 🔗 拡張システム
- **[docs/hooks-and-events/overview.md](./docs/hooks-and-events/overview.md)** - フック・イベントシステムの完全ガイド

#### 💡 実装例
- **[docs/examples/basic-plugin.md](./docs/examples/basic-plugin.md)** - 完全な基本プラグイン実装例

## プラグイン開発のベストプラクティス

### 1. プラグイン構造
- `plugins/[plugin_name]/`ディレクトリに配置
- `init.rb`でプラグインを登録（必須）
- Rails標準のMVCパターンに従う
- 適切な名前空間を使用して衝突を回避

### 2. 権限管理
```ruby
# init.rbでの権限定義例
project_module :your_module do
  permission :view_your_feature, {:your_controller => [:index, :show]}, :read => true
  permission :manage_your_feature, {:your_controller => [:new, :create, :edit, :update, :destroy]}
end
```

### 3. フックシステム活用
```ruby
# フックリスナーの基本実装
class YourPluginHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "issues/your_plugin_details"
  
  def view_layouts_base_html_head(context)
    stylesheet_link_tag 'your_plugin', :plugin => 'your_plugin'
  end
end
```

### 4. モデル拡張
```ruby
# acts_asモジュールの活用
class YourModel < ApplicationRecord
  acts_as_customizable      # カスタムフィールド対応
  acts_as_attachable        # ファイル添付対応
  acts_as_watchable         # ウォッチ機能対応
  acts_as_activity_provider # アクティビティ対応
end
```

## 開発環境セットアップ

### 必要要件
- Ruby 3.2, 3.3, 3.4
- Rails 7.x系
- データベース（PostgreSQL, MySQL, SQLite3のいずれか）

### プラグイン開発手順
1. `plugins/your_plugin_name/`ディレクトリ作成
2. `init.rb`でプラグイン登録
3. 必要に応じてマイグレーション作成
4. MVC構造に従って機能実装
5. テスト作成
6. `rake redmine:plugins:migrate`でマイグレーション実行

## コーディング規則

### ファイル命名
- プラグインディレクトリ：`snake_case`
- クラス名：`CamelCase`
- ファイル名：`snake_case.rb`

### 権限チェック
```ruby
def your_action
  # 権限チェックは必須
  return unless User.current.allowed_to?(:your_permission, @project)
  # 処理続行
end
```

### 国際化
- `config/locales/`に言語ファイル配置
- ラベルには`l()`ヘルパーを使用
- 英語（en.yml）と日本語（ja.yml）は最低限対応

### エラーハンドリング
```ruby
begin
  # プラグイン処理
rescue => e
  Rails.logger.error "Plugin error: #{e.message}"
  # サイレントフェイルを推奨（ユーザーエクスペリエンスを損なわない）
end
```

## 重要な設計原則

1. **非侵入性**: コアコードは変更しない
2. **拡張性**: 他プラグインとの共存を考慮
3. **パフォーマンス**: 重い処理は適切なタイミングで実行
4. **セキュリティ**: 権限チェックを適切に実装
5. **国際化**: 多言語対応を前提とした設計

## トラブルシューティング

### よくある問題
1. **プラグインが認識されない** → `init.rb`の記述を確認
2. **権限エラー** → 権限定義とロール設定を確認
3. **マイグレーションエラー** → データベース整合性を確認
4. **フックが動作しない** → フック名とリスナークラスを確認

### ログ確認
```bash
# Redmineログ
tail -f log/production.log

# プラグインログ（Rails.loggerを使用）
Rails.logger.info "Your plugin message"
```

## 参考リソース

- [Redmine Plugin Tutorial](http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial) - 公式チュートリアル
- [Redmine Plugin API](http://www.redmine.org/projects/redmine/wiki/Plugin_API) - API仕様
- `extra/sample_plugin/` - サンプルプラグイン
- `docs/` - 本プロジェクトのプラグイン開発ガイド（推奨）

---

**注意**: このドキュメントは、AIによる効率的なRedmineプラグイン開発支援を目的として作成されています。`docs/`配下の詳細ドキュメントと合わせてご活用ください。