# 基本プラグイン実装例

## 概要

この文書では、Redmineプラグインの基本的な実装例を段階的に説明します。シンプルな「プロジェクトメモ」機能を持つプラグインを例として、プラグイン開発の基本的な流れを示します。

## プラグイン概要

**機能**: プロジェクトごとにメモを作成・表示する機能
**プラグイン名**: `redmine_project_memo`
**主な機能**:
- プロジェクトページでのメモ表示
- メモの作成・編集・削除
- 適切な権限管理

## ディレクトリ構造

```
plugins/redmine_project_memo/
├── init.rb
├── README.rdoc
├── app/
│   ├── controllers/
│   │   └── project_memos_controller.rb
│   ├── models/
│   │   └── project_memo.rb
│   ├── helpers/
│   │   └── project_memos_helper.rb
│   └── views/
│       ├── project_memos/
│       │   ├── index.html.erb
│       │   ├── new.html.erb
│       │   ├── edit.html.erb
│       │   └── _form.html.erb
│       ├── projects/
│       │   └── _memo_sidebar.html.erb
│       └── settings/
│           └── _project_memo_settings.html.erb
├── config/
│   ├── locales/
│   │   ├── en.yml
│   │   └── ja.yml
│   └── routes.rb
├── db/
│   └── migrate/
│       └── 001_create_project_memos.rb
└── test/
    ├── fixtures/
    │   └── project_memos.yml
    ├── functional/
    │   └── project_memos_controller_test.rb
    ├── unit/
    │   └── project_memo_test.rb
    └── test_helper.rb
```

## 実装手順

### 1. init.rb（プラグイン登録）

```ruby
# plugins/redmine_project_memo/init.rb
Rails.logger.info 'Starting Project Memo plugin for Redmine'

Redmine::Plugin.register :redmine_project_memo do
  name 'Project Memo Plugin'
  author 'Plugin Developer'
  description 'Allows users to create and manage memos for projects'
  version '1.0.0'
  url 'https://github.com/example/redmine_project_memo'
  author_url 'https://github.com/example'
  
  # Redmineバージョン要件
  requires_redmine version_or_higher: '5.0.0'
  
  # プロジェクトモジュールとして定義
  project_module :project_memo do
    # 権限定義
    permission :view_project_memos, {
      :project_memos => [:index, :show]
    }, :read => true
    
    permission :manage_project_memos, {
      :project_memos => [:new, :create, :edit, :update, :destroy]
    }
  end
  
  # プロジェクトメニューにアイテム追加
  menu :project_menu, :project_memos, {
    :controller => 'project_memos',
    :action => 'index'
  }, :caption => :label_project_memo, :param => :project_id
  
  # プラグイン設定
  settings :default => {
    'memo_limit' => '10',
    'allow_anonymous_view' => false
  }, :partial => 'settings/project_memo_settings'
end
```

### 2. データベースマイグレーション

```ruby
# plugins/redmine_project_memo/db/migrate/001_create_project_memos.rb
class CreateProjectMemos < ActiveRecord::Migration[7.0]
  def change
    create_table :project_memos do |t|
      t.string :title, :null => false, :limit => 255
      t.text :content
      t.references :project, :null => false, :foreign_key => true
      t.references :author, :null => false, :foreign_key => {:to_table => :users}
      t.references :updated_by, :foreign_key => {:to_table => :users}
      t.boolean :private, :default => false
      t.timestamps
    end
    
    add_index :project_memos, :project_id
    add_index :project_memos, :author_id
    add_index :project_memos, [:project_id, :private]
  end
end
```

### 3. モデル実装

```ruby
# plugins/redmine_project_memo/app/models/project_memo.rb
class ProjectMemo < ApplicationRecord
  # 関連
  belongs_to :project
  belongs_to :author, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User', :optional => true
  
  # バリデーション
  validates :title, :presence => true, :length => {:maximum => 255}
  validates :content, :length => {:maximum => 65535}
  
  # スコープ
  scope :visible, lambda {|user|
    if user.admin?
      all
    else
      where(:private => false)
    end
  }
  
  scope :recent, lambda { order(:updated_on => :desc) }
  
  # 権限チェック
  def visible?(user = User.current)
    return false unless project.visible?(user)
    return true if user.admin?
    return true if author == user
    return true unless private?
    user.allowed_to?(:manage_project_memos, project)
  end
  
  def editable?(user = User.current)
    return false unless visible?(user)
    return true if user.admin?
    return true if author == user
    user.allowed_to?(:manage_project_memos, project)
  end
  
  def deletable?(user = User.current)
    editable?(user)
  end
  
  # コールバック
  before_save :update_updated_by
  
  private
  
  def update_updated_by
    self.updated_by = User.current if User.current
  end
end
```

### 4. コントローラー実装

```ruby
# plugins/redmine_project_memo/app/controllers/project_memos_controller.rb
class ProjectMemosController < ApplicationController
  before_action :find_project, :authorize
  before_action :find_memo, :only => [:show, :edit, :update, :destroy]
  
  def index
    @memos = @project.project_memos.visible(User.current).recent
    @memo_count = @memos.count
    @memo_limit = Setting.plugin_redmine_project_memo['memo_limit'].to_i
  end
  
  def show
    render :action => 'index'
  end
  
  def new
    @memo = @project.project_memos.build
    @memo.author = User.current
  end
  
  def create
    @memo = @project.project_memos.build(memo_params)
    @memo.author = User.current
    
    if @memo.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_project_memos_path(@project)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @memo.update(memo_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to project_project_memos_path(@project)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @memo.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to project_project_memos_path(@project)
  end
  
  private
  
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_memo
    @memo = @project.project_memos.find(params[:id])
    unless @memo.visible?
      deny_access
      return
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def memo_params
    params.require(:project_memo).permit(:title, :content, :private)
  end
end
```

### 5. ヘルパー実装

```ruby
# plugins/redmine_project_memo/app/helpers/project_memos_helper.rb
module ProjectMemosHelper
  def memo_visibility_icon(memo)
    if memo.private?
      content_tag(:span, '', :class => 'icon icon-locked', :title => l(:label_private))
    else
      content_tag(:span, '', :class => 'icon icon-unlock', :title => l(:label_public))
    end
  end
  
  def memo_author_link(memo)
    link_to_user(memo.author)
  end
  
  def memo_updated_info(memo)
    if memo.updated_by && memo.updated_by != memo.author
      l(:label_updated_by_with_time, 
        :author => link_to_user(memo.updated_by),
        :time => format_time(memo.updated_on)
      ).html_safe
    else
      l(:label_updated_time, :time => format_time(memo.updated_on))
    end
  end
end
```

### 6. ビュー実装

#### メモ一覧ページ
```erb
<!-- plugins/redmine_project_memo/app/views/project_memos/index.html.erb -->
<div class="contextual">
  <% if User.current.allowed_to?(:manage_project_memos, @project) %>
    <%= link_to l(:label_memo_new), 
                new_project_project_memo_path(@project),
                :class => 'icon icon-add' %>
  <% end %>
</div>

<h2><%= l(:label_project_memo_plural) %></h2>

<% if @memos.any? %>
  <% @memos.each do |memo| %>
    <div class="memo-item">
      <h3>
        <%= memo_visibility_icon(memo) %>
        <%= link_to_if memo.visible?, memo.title, 
                       project_project_memo_path(@project, memo) %>
      </h3>
      
      <div class="memo-meta">
        <%= l(:label_added_by, :author => memo_author_link(memo), 
                               :time => format_time(memo.created_on)) %>
        <% if memo.updated_on != memo.created_on %>
          <br /><%= memo_updated_info(memo) %>
        <% end %>
      </div>
      
      <div class="memo-content">
        <%= simple_format(h(truncate(memo.content, :length => 200))) %>
      </div>
      
      <div class="memo-actions">
        <% if memo.editable? %>
          <%= link_to l(:button_edit), 
                      edit_project_project_memo_path(@project, memo),
                      :class => 'icon icon-edit' %>
          <%= link_to l(:button_delete),
                      project_project_memo_path(@project, memo),
                      :method => :delete,
                      :confirm => l(:text_are_you_sure),
                      :class => 'icon icon-del' %>
        <% end %>
      </div>
    </div>
  <% end %>
<% else %>
  <p class="nodata"><%= l(:label_no_data) %></p>
<% end %>
```

#### メモ作成・編集フォーム
```erb
<!-- plugins/redmine_project_memo/app/views/project_memos/_form.html.erb -->
<%= form_with model: [@project, @memo], local: true do |f| %>
  <div class="box tabular">
    <p>
      <%= f.label :title, :class => 'required' %>
      <%= f.text_field :title, :size => 60, :required => true %>
    </p>
    
    <p>
      <%= f.label :content %>
      <%= f.text_area :content, :rows => 15, :cols => 60 %>
    </p>
    
    <p>
      <%= f.check_box :private %>
      <%= f.label :private, l(:field_is_private) %>
    </p>
  </div>
  
  <%= submit_tag l(:button_save) %>
  <%= link_to l(:button_cancel), project_project_memos_path(@project) %>
<% end %>
```

### 7. ルーティング設定

```ruby
# plugins/redmine_project_memo/config/routes.rb
resources :projects do
  resources :project_memos, :path => 'memos'
end
```

### 8. 国際化ファイル

#### 英語
```yaml
# plugins/redmine_project_memo/config/locales/en.yml
en:
  label_project_memo: "Project Memo"
  label_project_memo_plural: "Project Memos"
  label_memo_new: "New Memo"
  field_memo_title: "Title"
  field_memo_content: "Content"
  permission_view_project_memos: "View project memos"
  permission_manage_project_memos: "Manage project memos"
  project_module_project_memo: "Project Memo"
```

#### 日本語
```yaml
# plugins/redmine_project_memo/config/locales/ja.yml
ja:
  label_project_memo: "プロジェクトメモ"
  label_project_memo_plural: "プロジェクトメモ"
  label_memo_new: "新しいメモ"
  field_memo_title: "タイトル"
  field_memo_content: "内容"
  permission_view_project_memos: "プロジェクトメモの閲覧"
  permission_manage_project_memos: "プロジェクトメモの管理"
  project_module_project_memo: "プロジェクトメモ"
```

### 9. プラグイン設定ビュー

```erb
<!-- plugins/redmine_project_memo/app/views/settings/_project_memo_settings.html.erb -->
<p>
  <label><%= l(:label_memo_limit) %></label>
  <%= text_field_tag 'settings[memo_limit]', 
                     @settings['memo_limit'], 
                     :size => 6 %>
  <em><%= l(:text_memo_limit_description) %></em>
</p>

<p>
  <label>
    <%= check_box_tag 'settings[allow_anonymous_view]', 
                      '1', 
                      @settings['allow_anonymous_view'] %>
    <%= l(:label_allow_anonymous_view) %>
  </label>
  <br><em><%= l(:text_allow_anonymous_view_description) %></em>
</p>
```

### 10. フック実装（サイドバー表示）

```ruby
# plugins/redmine_project_memo/app/views/projects/_memo_sidebar.html.erb
<% if @project.module_enabled?(:project_memo) &&
      User.current.allowed_to?(:view_project_memos, @project) %>
  
  <h3><%= l(:label_project_memo_plural) %></h3>
  
  <% recent_memos = @project.project_memos.visible(User.current).recent.limit(5) %>
  <% if recent_memos.any? %>
    <ul>
      <% recent_memos.each do |memo| %>
        <li>
          <%= memo_visibility_icon(memo) %>
          <%= link_to truncate(memo.title, :length => 30),
                      project_project_memo_path(@project, memo) %>
        </li>
      <% end %>
    </ul>
    
    <%= link_to l(:label_view_all), 
                project_project_memos_path(@project),
                :class => 'icon icon-list' %>
  <% else %>
    <p><%= l(:label_no_data) %></p>
  <% end %>
  
  <% if User.current.allowed_to?(:manage_project_memos, @project) %>
    <p>
      <%= link_to l(:label_memo_new),
                  new_project_project_memo_path(@project),
                  :class => 'icon icon-add' %>
    </p>
  <% end %>
<% end %>
```

### 11. フックリスナー

```ruby
# plugins/redmine_project_memo/init.rb に追加
class ProjectMemoHookListener < Redmine::Hook::ViewListener
  render_on :view_projects_show_sidebar_bottom, :partial => 'projects/memo_sidebar'
end
```

### 12. テスト実装

#### ユニットテスト
```ruby
# plugins/redmine_project_memo/test/unit/project_memo_test.rb
require File.expand_path('../../test_helper', __FILE__)

class ProjectMemoTest < ActiveSupport::TestCase
  fixtures :projects, :users, :project_memos
  
  def test_should_create_memo
    memo = ProjectMemo.new(
      :title => 'Test Memo',
      :content => 'Test Content',
      :project_id => 1,
      :author_id => 1
    )
    assert memo.save
  end
  
  def test_should_require_title
    memo = ProjectMemo.new(:project_id => 1, :author_id => 1)
    assert !memo.save
    assert memo.errors[:title].present?
  end
  
  def test_visible_scope
    admin = User.find(1)
    regular_user = User.find(2)
    
    # 管理者はすべて見える
    assert_equal 2, ProjectMemo.visible(admin).count
    
    # 一般ユーザーはプライベートでないもののみ
    assert_equal 1, ProjectMemo.visible(regular_user).count
  end
end
```

## インストールと使用方法

### インストール
1. プラグインを`plugins/`ディレクトリにコピー
2. データベースマイグレーション実行: `rake redmine:plugins:migrate`
3. Redmine再起動

### 使用方法
1. プロジェクト設定でProject Memoモジュールを有効化
2. ロール設定で適切な権限を付与
3. プロジェクトページでメモ機能を使用

### アンインストール
1. マイグレーションを戻す: `rake redmine:plugins:migrate NAME=redmine_project_memo VERSION=0`
2. プラグインディレクトリを削除

## まとめ

この基本プラグイン例では、以下の要素を含んでいます：

1. **MVC構造**: Rails標準のパターンに従った実装
2. **権限管理**: Redmineの権限システムとの統合
3. **国際化**: 多言語対応
4. **データベース**: マイグレーションとモデル設計
5. **フック**: 既存UIへの統合
6. **設定**: プラグイン固有の設定管理
7. **テスト**: 品質保証

この例を基に、より複雑な機能を持つプラグインを開発することができます。