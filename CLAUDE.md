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

### DevContainer開発環境

このプロジェクトはDevContainer（開発コンテナ）に対応しており、一貫性のある開発環境を提供します。

#### ディレクトリ構成

開発環境では以下のディレクトリ構成でRedmineとプラグインが配置されます：

```
/workspace/
├── redmine/                     # Redmine本体（git clone）
│   ├── app/
│   ├── config/
│   ├── plugins/
│   │   └── {plugin_name}/       # シンボリックリンク → /workspace/src
│   ├── public/
│   ├── test/
│   └── ...
└── src/                         # このプラグインリポジトリ
    ├── init.rb                  # プラグイン登録と設定
    ├── app/                     # アプリケーションコード（MVCパターン）
    │   ├── controllers/         # リクエスト処理とビジネスロジック
    │   └── views/               # ユーザーインターフェーステンプレート
    ├── config/                  # 設定ファイル
    │   ├── locales/             # 国際化ファイル
    │   │   ├── en.yml          # 英語翻訳
    │   │   └── ja.yml          # 日本語翻訳
    │   └── routes.rb           # URLルーティング定義
    ├── docs/                    # 包括的な開発ガイド
    ├── spec/                    # RSpecテストファイル
    │   ├── controllers/         # コントローラーテスト
    │   ├── models/             # モデルテスト
    │   ├── system/             # 統合テスト
    │   ├── spec_helper.rb      # RSpec設定
    │   └── rails_helper.rb     # Rails用RSpec設定
    ├── scripts/                 # 自動化とセットアップツール
    │   └── setup_plugin.rb     # インタラクティブなプラグイン設定スクリプト
    ├── CLAUDE.md               # プラグイン開発ガイド
    └── README.md               # プロジェクト概要
```

#### 開発ワークフロー

1. **DevContainer起動時の自動セットアップ**：
   - `/workspace/redmine`にRedmine本体がクローンされます
   - `/workspace/src`にこのプラグインの内容が配置されます
   - `/workspace/redmine/plugins/{plugin_name}`にシンボリックリンクが作成されます

2. **開発プロセス**：
   - `/workspace/src`でプラグインコードを編集
   - 変更は自動的にRedmine環境に反映される（シンボリックリンク経由）
   - Redmineサーバーの再起動で変更を確認

3. **テスト環境**：
   ```bash
   # Redmineディレクトリでの作業
   cd /workspace/redmine
   
   # データベースセットアップ
   bundle exec rake db:migrate
   bundle exec rake redmine:plugins:migrate
   
   # テストデータ投入
   bundle exec rake db:fixtures:load
   
   # 開発サーバー起動
   bundle exec rails server
   ```

4. **プラグインテスト**：
   ```bash
   # プラグインディレクトリでのテスト
   cd /workspace/src
   bundle exec rspec
   
   # Redmineテスト環境での統合テスト
   cd /workspace/redmine
   bundle exec rake test:plugins:units PLUGIN={plugin_name}
   ```

### プラグイン開発手順
1. `plugins/your_plugin_name/`ディレクトリ作成
2. `init.rb`でプラグイン登録
3. 必要に応じてマイグレーション作成
4. MVC構造に従って機能実装
5. テスト作成
6. `rake redmine:plugins:migrate`でマイグレーション実行

## テスト（RSpec）

RedmineプラグインのテストにはRSpecを使用します。

### テスト環境設定

#### spec_helper.rb
```ruby
# spec/spec_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures = false
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  
  # プラグイン固有の設定
  config.include ActiveSupport::Testing::Assertions
  config.include Redmine::I18n
end
```

#### rails_helper.rb
```ruby
# spec/rails_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'

# Redmineテスト環境の初期化
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
```

### テストの基本パターン

#### モデルテスト
```ruby
# spec/models/your_model_spec.rb
require 'rails_helper'

RSpec.describe YourModel, type: :model do
  let(:project) { Project.find(1) }
  
  describe "validations" do
    it "requires name" do
      model = YourModel.new
      expect(model).not_to be_valid
      expect(model.errors[:name]).to include("can't be blank")
    end
  end
  
  describe "associations" do
    it "belongs to project" do
      expect(subject).to belong_to(:project)
    end
  end
  
  describe "acts_as modules" do
    it "acts as customizable" do
      expect(YourModel.new).to respond_to(:custom_field_values)
    end
  end
end
```

#### コントローラーテスト
```ruby
# spec/controllers/your_controller_spec.rb
require 'rails_helper'

RSpec.describe YourController, type: :controller do
  fixtures :projects, :users, :roles, :members, :member_roles
  
  before do
    User.current = User.find(2) # 管理者ユーザー
    @project = Project.find(1)
  end
  
  describe "GET #index" do
    context "with permission" do
      it "returns success" do
        get :index, params: { project_id: @project.id }
        expect(response).to have_http_status(:success)
      end
    end
    
    context "without permission" do
      before do
        User.current = User.find(7) # 権限のないユーザー
      end
      
      it "returns forbidden" do
        get :index, params: { project_id: @project.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

#### 統合テスト
```ruby
# spec/system/your_feature_spec.rb
require 'rails_helper'

RSpec.describe "YourFeature", type: :system do
  fixtures :projects, :users, :roles, :members, :member_roles
  
  before do
    login_as(User.find(2))
  end
  
  it "allows user to create new item" do
    visit project_path(Project.find(1))
    click_link "Your Feature"
    click_link "New Item"
    
    fill_in "Name", with: "Test Item"
    click_button "Create"
    
    expect(page).to have_content("Item was successfully created")
    expect(page).to have_content("Test Item")
  end
  
  private
  
  def login_as(user)
    visit signin_path
    fill_in "username", with: user.login
    fill_in "password", with: "admin"
    click_button "Login"
  end
end
```

### フックのテスト
```ruby
# spec/lib/your_plugin_hook_listener_spec.rb
require 'rails_helper'

RSpec.describe YourPluginHookListener do
  let(:listener) { YourPluginHookListener.instance }
  let(:context) { { project: Project.find(1) } }
  
  describe "#view_issues_show_details_bottom" do
    it "renders partial" do
      result = listener.view_issues_show_details_bottom(context)
      expect(result).to include("your_plugin_details")
    end
  end
end
```

### ファクトリの使用
```ruby
# spec/factories/your_models.rb
FactoryBot.define do
  factory :your_model do
    name { "Test Item" }
    project { Project.find(1) }
    
    trait :with_custom_fields do
      after(:create) do |item|
        item.custom_field_values = { "1" => "Custom Value" }
        item.save
      end
    end
  end
end

# テストでの使用
RSpec.describe YourModel do
  let(:model) { create(:your_model) }
  let(:model_with_cf) { create(:your_model, :with_custom_fields) }
end
```

### テスト実行

```bash
# 全テスト実行
bundle exec rspec

# 特定のファイル実行
bundle exec rspec spec/models/your_model_spec.rb

# 特定の行のテスト実行
bundle exec rspec spec/models/your_model_spec.rb:10

# タグ指定実行
bundle exec rspec --tag focus
```

### テストカバレッジ
```ruby
# Gemfileに追加
group :test do
  gem 'simplecov', require: false
end

# spec_helper.rbの先頭に追加
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
end
```

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