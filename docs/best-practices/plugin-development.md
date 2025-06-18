# Redmineプラグイン開発ベストプラクティス

このドキュメントは、Redmineプラグイン開発における実践的なベストプラクティスをまとめたものです。効率的で保守性の高いプラグイン開発のための指針として活用してください。

## 1. プラグイン構造のベストプラクティス

### ディレクトリ構成
```
plugins/your_plugin_name/
├── init.rb                  # プラグイン登録（必須）
├── app/                     # アプリケーションコード
│   ├── controllers/         # コントローラー
│   ├── models/             # モデル
│   └── views/              # ビュー
├── config/                  # 設定ファイル
│   ├── locales/            # 国際化ファイル
│   └── routes.rb           # ルーティング
├── lib/                    # ライブラリコード
├── assets/                 # 静的ファイル
└── test/                   # テストファイル
```

### 命名規則
- **プラグインディレクトリ**: `snake_case`
- **クラス名**: `CamelCase`
- **ファイル名**: `snake_case.rb`
- **名前空間**: プラグイン名を使用して衝突を回避

### init.rbの基本構造
```ruby
Redmine::Plugin.register :your_plugin_name do
  name 'Your Plugin Name'
  author 'Your Name'
  description 'Plugin description'
  version '1.0.0'
  url 'https://github.com/your/plugin'
  author_url 'https://your-website.com'
  
  # 権限定義
  project_module :your_module do
    permission :view_your_feature, {:your_controller => [:index, :show]}, :read => true
    permission :manage_your_feature, {:your_controller => [:new, :create, :edit, :update, :destroy]}
  end
  
  # メニュー追加
  menu :project_menu, :your_feature, { :controller => 'your_controller', :action => 'index' }, 
       :caption => 'Your Feature', :after => :activity, :param => :project_id
end
```

## 2. 権限管理のベストプラクティス

### 権限の適切な定義
```ruby
# init.rbでの権限定義
project_module :your_module do
  permission :view_your_feature, {:your_controller => [:index, :show]}, :read => true
  permission :manage_your_feature, {:your_controller => [:new, :create, :edit, :update, :destroy]}
  permission :delete_your_feature, {:your_controller => [:destroy]}, :require => :member
end
```

### コントローラーでの権限チェック
```ruby
class YourController < ApplicationController
  before_action :find_project
  before_action :authorize
  
  private
  
  def find_project
    @project = Project.find(params[:project_id])
  end
  
  def authorize
    # 自動的に適切な権限をチェック
    super
  end
  
  # 個別の権限チェックが必要な場合
  def your_action
    return unless User.current.allowed_to?(:your_permission, @project)
    # 処理続行
  end
end
```

### ビューでの権限チェック
```erb
<% if User.current.allowed_to?(:manage_your_feature, @project) %>
  <%= link_to 'Edit', edit_your_path %>
<% end %>
```

## 3. フックシステム活用のベストプラクティス

### フックリスナーの基本実装
```ruby
class YourPluginHookListener < Redmine::Hook::ViewListener
  # ビューフック
  render_on :view_issues_show_details_bottom, :partial => "issues/your_plugin_details"
  
  # HTMLヘッドへの追加
  def view_layouts_base_html_head(context)
    stylesheet_link_tag 'your_plugin', :plugin => 'your_plugin'
  end
  
  # サイドバーへの追加
  def view_projects_show_sidebar_bottom(context)
    content_tag :h3, 'Your Plugin'
  end
end
```

### よく使用されるフック
- `view_layouts_base_html_head` - CSS/JSの追加
- `view_issues_show_details_bottom` - チケット詳細画面への追加
- `view_projects_show_sidebar_bottom` - プロジェクトサイドバーへの追加
- `controller_issues_new_before_save` - チケット保存前の処理

## 4. モデル拡張のベストプラクティス

### acts_asモジュールの活用
```ruby
class YourModel < ApplicationRecord
  acts_as_customizable      # カスタムフィールド対応
  acts_as_attachable        # ファイル添付対応
  acts_as_watchable         # ウォッチ機能対応
  acts_as_activity_provider # アクティビティ対応
  acts_as_searchable        # 検索対応
  
  belongs_to :project
  belongs_to :author, :class_name => 'User'
  
  validates :name, :presence => true, :length => {:maximum => 255}
  validates :project, :presence => true
end
```

### 既存モデルの拡張
```ruby
# lib/your_plugin/patches/issue_patch.rb
module YourPlugin
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          has_many :your_models, :dependent => :destroy
        end
      end
      
      module ClassMethods
        def your_custom_scope
          where(status_id: [1, 2, 3])
        end
      end
      
      def your_custom_method
        # カスタムメソッド
      end
    end
  end
end

# init.rbで適用
require_dependency 'issue'
Issue.send(:include, YourPlugin::Patches::IssuePatch)
```

## 5. テスト（RSpec）のベストプラクティス

### テスト環境設定
```ruby
# spec/spec_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures = false
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  
  config.include ActiveSupport::Testing::Assertions
  config.include Redmine::I18n
end
```

### モデルテストの基本パターン
```ruby
RSpec.describe YourModel, type: :model do
  fixtures :projects, :users
  
  let(:project) { Project.find(1) }
  let(:user) { User.find(2) }
  
  describe "validations" do
    it "requires name" do
      model = YourModel.new(project: project)
      expect(model).not_to be_valid
      expect(model.errors[:name]).to include("can't be blank")
    end
  end
  
  describe "associations" do
    it "belongs to project" do
      expect(subject).to belong_to(:project)
    end
  end
end
```

### コントローラーテストの基本パターン
```ruby
RSpec.describe YourController, type: :controller do
  fixtures :projects, :users, :roles, :members, :member_roles
  
  before do
    User.current = User.find(2)
    @project = Project.find(1)
  end
  
  describe "GET #index" do
    context "with permission" do
      it "returns success" do
        get :index, params: { project_id: @project.id }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
```

## 6. コーディング規則

### Ruby/Railsのベストプラクティス
- **Rubyイディオム**: Rubyらしい書き方を心がける
- **ActiveRecord**: 適切なスコープとバリデーションを使用
- **Fat Model, Skinny Controller**: ビジネスロジックはモデルに配置
- **サービスオブジェクト**: 複雑なロジックは専用クラスに抽出

### 国際化対応
```ruby
# config/locales/en.yml
en:
  your_plugin:
    label_your_feature: "Your Feature"
    button_create: "Create"
    notice_successful_create: "Successfully created."

# config/locales/ja.yml
ja:
  your_plugin:
    label_your_feature: "あなたの機能"
    button_create: "作成"
    notice_successful_create: "正常に作成されました。"
```

### エラーハンドリング
```ruby
begin
  # プラグイン処理
rescue => e
  Rails.logger.error "Plugin error: #{e.message}"
  # サイレントフェイルを推奨（ユーザーエクスペリエンスを損なわない）
  flash[:error] = l(:notice_plugin_error) if respond_to?(:flash)
end
```

## 7. 重要な設計原則

### 1. 非侵入性
- **コアコード変更禁止**: Redmineのコアファイルは絶対に変更しない
- **パッチ使用**: 既存機能の拡張にはパッチを使用
- **フック活用**: UIの拡張にはフックシステムを活用

### 2. 拡張性
- **他プラグインとの共存**: 名前空間を適切に使用
- **設定可能性**: 管理画面での設定変更を可能にする
- **API提供**: 他プラグインから利用可能なAPIを提供

### 3. パフォーマンス
- **遅延読み込み**: 必要な時にのみリソースを読み込む
- **キャッシュ活用**: 適切なキャッシュ戦略を実装
- **データベース最適化**: N+1問題を避ける

### 4. セキュリティ
- **権限チェック**: すべてのアクションで適切な権限チェック
- **入力検証**: ユーザー入力は必ず検証
- **SQLインジェクション対策**: パラメータ化クエリを使用

### 5. 国際化
- **多言語対応**: 最低限英語と日本語に対応
- **文字エンコーディング**: UTF-8を使用
- **日付・時刻**: ユーザーのタイムゾーンを考慮

## 8. トラブルシューティング

### よくある問題と解決策

#### プラグインが認識されない
**原因**: `init.rb`の記述エラー
**解決策**: 
- プラグイン名の確認
- 構文エラーのチェック
- ログファイルの確認

#### 権限エラーが発生する
**原因**: 権限定義またはロール設定の問題
**解決策**:
- `init.rb`の権限定義を確認
- 管理画面でロールの権限設定を確認
- コントローラーの`authorize`メソッド呼び出しを確認

#### マイグレーションエラー
**原因**: データベーススキーマの不整合
**解決策**:
- マイグレーションファイルの構文確認
- 既存テーブルとの競合チェック
- `rake redmine:plugins:migrate`の実行

#### フックが動作しない
**原因**: フック名またはリスナークラスの問題
**解決策**:
- フック名の正確性を確認
- リスナークラスの継承関係を確認
- `init.rb`でのリスナー登録を確認

### デバッグ手法

#### ログ出力
```ruby
Rails.logger.info "Your plugin debug message"
Rails.logger.debug "Detailed debug information: #{variable.inspect}"
```

#### 開発環境での確認
```bash
# Redmineログの確認
tail -f log/development.log

# プラグインの再読み込み
touch tmp/restart.txt

# マイグレーションの確認
rake redmine:plugins:migrate RAILS_ENV=development
```

## 9. パフォーマンス最適化

### データベースクエリの最適化
```ruby
# N+1問題の回避
@issues = Issue.includes(:author, :status, :priority).where(project: @project)

# 適切なスコープの使用
scope :open, -> { where(status_id: IssueStatus.where(is_closed: false)) }
```

### キャッシュの活用
```ruby
# ビューキャッシュ
<% cache [@project, @issues] do %>
  <%= render @issues %>
<% end %>

# メソッドキャッシュ
def expensive_calculation
  @expensive_calculation ||= perform_complex_calculation
end
```

## 10. セキュリティベストプラクティス

### 入力検証
```ruby
class YourController < ApplicationController
  before_action :validate_input
  
  private
  
  def validate_input
    params.require(:your_model).permit(:name, :description, :project_id)
  end
end
```

### XSS対策
```erb
<!-- 自動エスケープされる -->
<%= @user_input %>

<!-- HTMLを許可する場合（注意深く使用）-->
<%= sanitize(@user_input, tags: %w[p br strong em]) %>
```

このベストプラクティスガイドを参考に、安全で効率的なRedmineプラグインを開発してください。
