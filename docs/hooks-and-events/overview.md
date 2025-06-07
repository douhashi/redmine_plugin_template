# Redmineフックシステム概要

## 概要

Redmineのフックシステムは、プラグイン開発者がコアコードを変更することなく機能を拡張するための強力なメカニズムです。フックは特定のタイミングで呼び出され、プラグインはそれらのフックに応答して独自の処理を実行できます。

## フックシステムの基本構造

### コアクラス

#### Redmine::Hook
- パス: `lib/redmine/hook.rb`
- フックシステムの中核クラス
- リスナーの管理とフック呼び出しを担当

```ruby
module Redmine
  module Hook
    # フック呼び出し
    def self.call_hook(hook, context={})
      response = []
      hook_listeners(hook).each do |listener|
        response << listener.send(hook, context)
      end
      response
    end
    
    # リスナー追加
    def self.add_listener(klass)
      unless klass.included_modules.include?(Singleton)
        raise "Hooks must include Singleton module."
      end
      @@listener_classes << klass
    end
  end
end
```

#### Redmine::Hook::Listener
- フックリスナーの基底クラス
- Singletonパターンを使用

```ruby
class Redmine::Hook::Listener
  include Singleton
  
  # フックに対応するメソッドを定義
  def view_layouts_base_html_head(context)
    # ビューフックの処理
  end
  
  def controller_issues_new_after_save(context)
    # コントローラーフックの処理
  end
end
```

#### Redmine::Hook::ViewListener
- ビュー専用のリスナークラス
- ActionViewヘルパーを利用可能

```ruby
class Redmine::Hook::ViewListener < Redmine::Hook::Listener
  # render_onを使用して自動的にパーシャルを描画
  render_on :view_issues_show_details_bottom, :partial => "issues/show_extra_info"
  
  # 複数のパーシャルを描画
  render_on :view_issues_form_details_bottom, :partial => ["issues/form_part1", "issues/form_part2"]
  
  # カスタムヘルパーメソッドが利用可能
  def view_layouts_base_html_head(context)
    stylesheet_link_tag 'my_plugin', :plugin => 'my_plugin'
  end
end
```

### フック呼び出しの仕組み

#### Helper Module
- パス: `lib/redmine/hook.rb` (Helper module)
- コントローラーとビューでフックを簡単に呼び出すためのヘルパー

```ruby
module Redmine::Hook::Helper
  def call_hook(hook, context={})
    if is_a?(ActionController::Base)
      # コントローラーでの呼び出し
      default_context = {
        :controller => self,
        :project => @project,
        :request => request,
        :hook_caller => self
      }
      Redmine::Hook.call_hook(hook, default_context.merge(context))
    else
      # ビューでの呼び出し
      default_context = {
        :project => @project,
        :hook_caller => self
      }
      default_context[:controller] = controller if respond_to?(:controller)
      default_context[:request] = request if respond_to?(:request)
      Redmine::Hook.call_hook(hook, default_context.merge(context)).join(' ').html_safe
    end
  end
end
```

## フック分類と命名規則

### 1. ビューフック（View Hooks）
ビューテンプレートで呼び出されるフック

#### 命名パターン
`view_{controller}_{action}_{position}`

#### 位置指定
- `_top`: 上部
- `_bottom`: 下部  
- `_left`: 左側
- `_right`: 右側
- `_head`: ヘッド部分
- `_sidebar`: サイドバー

#### 主要なビューフック例
```ruby
# レイアウト関連
:view_layouts_base_html_head        # HTMLヘッド内
:view_layouts_base_body_top         # body開始直後
:view_layouts_base_body_bottom      # body終了直前

# チケット関連
:view_issues_show_details_bottom    # チケット詳細の下部
:view_issues_form_details_bottom    # チケットフォームの下部
:view_issues_index_bottom           # チケット一覧の下部

# プロジェクト関連
:view_projects_show_left            # プロジェクト表示の左側
:view_projects_show_right           # プロジェクト表示の右側
```

### 2. コントローラーフック（Controller Hooks）
コントローラーのアクション前後で呼び出されるフック

#### 命名パターン
`controller_{controller}_{action}_{timing}`

#### タイミング指定
- `_before_save`: 保存前
- `_after_save`: 保存後
- `_before_render`: 描画前
- `_after_render`: 描画後

#### 主要なコントローラーフック例
```ruby
# チケット関連
:controller_issues_new_before_save     # チケット作成前
:controller_issues_new_after_save      # チケット作成後
:controller_issues_edit_before_save    # チケット更新前
:controller_issues_edit_after_save     # チケット更新後

# 認証関連
:controller_account_success_authentication_after  # 認証成功後
```

### 3. モデルフック（Model Hooks）
モデルの特定の処理で呼び出されるフック

#### 命名パターン
`model_{model}_{action}_{timing}`

#### 主要なモデルフック例
```ruby
# プロジェクト関連
:model_project_copy_before_save  # プロジェクトコピー保存前

# コミット関連
:model_changeset_scan_commit_for_issue_ids_pre_issue_update  # コミットスキャン時
```

## フックコンテキスト（Context）

### 自動提供されるコンテキスト
フック呼び出し時に自動的に提供される情報：

```ruby
{
  :project => @project,           # 現在のプロジェクト
  :request => request,            # HTTPリクエストオブジェクト
  :controller => self,            # 現在のコントローラーインスタンス
  :hook_caller => self            # フックを呼び出したオブジェクト
}
```

### カスタムコンテキスト
フック呼び出し時に追加で渡される情報：

```ruby
# ビューでの例
<%= call_hook(:view_issues_show_details_bottom, :issue => @issue) %>

# コントローラーでの例
call_hook(:controller_issues_new_after_save, :issue => @issue, :params => params)
```

## フックリスナーの実装パターン

### 基本的なリスナー実装

```ruby
class MyPluginHookListener < Redmine::Hook::ViewListener
  # render_onを使用した自動パーシャル描画
  render_on :view_issues_show_details_bottom, :partial => "issues/plugin_details"
  
  # 複数パーシャルの描画
  render_on :view_issues_form_details_bottom, :partial => [
    "issues/form_section1",
    "issues/form_section2"
  ]
  
  # カスタムメソッドでの処理
  def view_layouts_base_html_head(context)
    return '' unless context[:project]
    
    # CSSの追加
    stylesheet_link_tag('my_plugin', :plugin => 'my_plugin') +
    # JavaScriptの追加  
    javascript_include_tag('my_plugin', :plugin => 'my_plugin')
  end
  
  # コントローラーフックの処理
  def controller_issues_new_after_save(context)
    issue = context[:issue]
    return unless issue.persisted?
    
    # カスタム処理
    MyPlugin::IssueProcessor.process(issue)
  end
  
  # 条件付き処理
  def view_issues_show_details_bottom(context)
    issue = context[:issue]
    return '' unless issue.tracker.name == 'Bug'
    
    render_partial(context, 'issues/bug_specific_info')
  end
  
  private
  
  def render_partial(context, partial)
    context[:controller].send(:render_to_string, {
      :partial => partial,
      :locals => context
    })
  end
end
```

### 高度なリスナー実装

```ruby
class AdvancedPluginHookListener < Redmine::Hook::ViewListener
  # 複数フックに対する共通処理
  [:view_issues_show_details_bottom, :view_issues_edit_notes_bottom].each do |hook|
    define_method(hook) do |context|
      return '' unless authorized_user?(context)
      render_issue_enhancement(context)
    end
  end
  
  # 設定による条件分岐
  def view_projects_show_right(context)
    return '' unless plugin_enabled?(context[:project])
    
    case Setting.plugin_my_plugin['display_mode']
    when 'full'
      render_full_widget(context)
    when 'compact'
      render_compact_widget(context)
    else
      ''
    end
  end
  
  # エラーハンドリング
  def controller_issues_new_after_save(context)
    begin
      MyPlugin::NotificationService.notify(context[:issue])
    rescue => e
      Rails.logger.error "Plugin notification failed: #{e.message}"
    end
  end
  
  private
  
  def authorized_user?(context)
    user = User.current
    project = context[:project]
    user.allowed_to?(:view_my_plugin, project)
  end
  
  def plugin_enabled?(project)
    project&.module_enabled?(:my_plugin)
  end
end
```

## フック活用のベストプラクティス

### 1. 適切なフック選択
```ruby
# ❌ 間違い: 不適切なフック選択
def view_layouts_base_body_bottom(context)
  # 重い処理をレイアウトフックで実行（全ページで実行される）
end

# ✅ 正しい: 適切なフック選択
def view_issues_show_details_bottom(context)
  # チケット詳細ページでのみ実行される軽量な処理
end
```

### 2. 条件チェック
```ruby
def view_issues_show_details_bottom(context)
  # プロジェクトの存在確認
  return '' unless context[:project]
  
  # モジュールの有効性確認
  return '' unless context[:project].module_enabled?(:my_plugin)
  
  # 権限確認
  return '' unless User.current.allowed_to?(:view_my_plugin, context[:project])
  
  render_partial(context, 'my_plugin/issue_details')
end
```

### 3. パフォーマンス考慮
```ruby
def view_issues_index_bottom(context)
  # キャッシュの利用
  Rails.cache.fetch("my_plugin_issues_#{context[:project].id}", :expires_in => 1.hour) do
    expensive_computation(context)
  end
end
```

### 4. エラーハンドリング
```ruby
def controller_issues_new_after_save(context)
  begin
    MyPlugin::Service.process(context[:issue])
  rescue => e
    Rails.logger.error "MyPlugin error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # エラーをユーザーに表示しない（サイレントフェイル）
  end
end
```

## 次のステップ

フックシステムの概要を理解したら、以下の詳細ドキュメントを参照してください：

1. [ビューフック詳細](./view-hooks.md)
2. [コントローラーフック詳細](./controller-hooks.md)
3. [フック実装例](./implementation-examples.md)
4. [基本プラグイン実装例](../examples/basic-plugin.md)