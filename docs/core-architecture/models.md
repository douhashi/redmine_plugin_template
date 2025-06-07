# Redmineコアモデル構造

## 概要

Redmineのモデル層は、Ruby on RailsのActiveRecordパターンに基づいて設計されており、プラグイン開発者が拡張しやすいように多くの拡張ポイントが提供されています。

## 基底クラス構造

### ApplicationRecord
- パス: `app/models/application_record.rb`
- すべてのモデルの基底クラス
- ActiveRecord::Baseを継承
- 属性名の翻訳機能を提供

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  # 属性の人間可読な名前を取得
  def self.human_attribute_name(attr, options = {})
    # カスタム翻訳ロジック
  end
end
```

## 主要継承パターン

### Principal階層（STIパターン）

```
Principal
├── User
├── Group
│   ├── GroupAnonymous
│   ├── GroupBuiltin  
│   └── GroupNonMember
└── AnonymousUser
```

#### Principal（基底クラス）
- パス: `app/models/principal.rb`
- STI（Single Table Inheritance）の基底クラス
- ユーザーとグループの共通機能

```ruby
class Principal < ApplicationRecord
  # ステータス定義
  STATUS_ACTIVE = 1
  STATUS_REGISTERED = 2  
  STATUS_LOCKED = 3
  STATUS_ANONYMOUS = 0
  
  # メンバーシップとロール管理
  has_many :members, :dependent => :destroy
  has_many :member_roles, :through => :members
  has_many :roles, :through => :member_roles
end
```

#### User
- パス: `app/models/user.rb`
- 認証、権限管理、設定管理
- 二要素認証（TOTP）対応

```ruby
class User < Principal
  # 認証関連
  attr_protected :password, :hashed_password, :salt, :auth_source_id
  
  # メール通知設定
  MAIL_NOTIFICATION_OPTIONS = [
    ['all', :label_user_mail_option_all],
    ['selected', :label_user_mail_option_selected],
    ['only_my_events', :label_user_mail_option_only_my_events],
    ['only_assigned', :label_user_mail_option_only_assigned],
    ['only_owner', :label_user_mail_option_only_owner],
    ['none', :label_user_mail_option_none]
  ]
  
  # 権限チェック
  def allowed_to?(action, context, options={})
    # 権限判定ロジック
  end
end
```

### プロジェクト構造

#### Project
- パス: `app/models/project.rb`
- ネストセット（Nested Set）による階層構造
- モジュール有効化管理

```ruby
class Project < ApplicationRecord
  # ネストセット
  acts_as_nested_set :order => 'name', :dependent => :destroy
  
  # プロジェクトステータス
  STATUS_ACTIVE = 1
  STATUS_CLOSED = 5
  STATUS_ARCHIVED = 9
  
  # 有効化されたモジュール
  has_many :enabled_modules, :dependent => :delete_all
  
  # モジュールが有効かチェック
  def module_enabled?(module_name)
    enabled_modules.exists?(:name => module_name.to_s)
  end
  
  # 権限チェック
  def allows_to?(action, user=User.current)
    # プロジェクト固有の権限チェック
  end
end
```

### チケット（Issue）構造

#### Issue
- パス: `app/models/issue.rb`
- ネストセット（親子関係）
- カスタムフィールド対応

```ruby
class Issue < ApplicationRecord
  # ネストセット（親子関係）
  acts_as_nested_set :scope => 'root_id', :dependent => :destroy
  
  # 関連
  belongs_to :project
  belongs_to :tracker
  belongs_to :status, :class_name => 'IssueStatus'
  belongs_to :author, :class_name => 'User'
  belongs_to :assigned_to, :class_name => 'Principal'
  belongs_to :fixed_version, :class_name => 'Version'
  belongs_to :priority, :class_name => 'IssuePriority'
  belongs_to :category, :class_name => 'IssueCategory'
  
  # カスタムフィールド
  acts_as_customizable
  
  # 添付ファイル
  acts_as_attachable :after_add => :attachment_added,
                     :after_remove => :attachment_removed
  
  # ウォッチ機能
  acts_as_watchable
  
  # イベント機能
  acts_as_event :title => Proc.new {|o| "#{o.tracker.name} ##{o.id}: #{o.subject}"}
  
  # アクティビティ
  acts_as_activity_provider :scope => preload(:project, :author, :tracker, :status)
end
```

### 権限・ロール構造

#### Role
- パス: `app/models/role.rb`
- 権限配列の管理
- ビルトイン役割対応

```ruby
class Role < ApplicationRecord
  # ビルトイン役割
  BUILTIN_NON_MEMBER = 1
  BUILTIN_ANONYMOUS = 2
  
  # 権限配列
  serialize :permissions, Array
  
  # 権限の追加
  def add_permission!(*perms)
    self.permissions = [] unless permissions.is_a?(Array)
    permissions_will_change!
    perms.each do |p|
      permissions << p.to_sym unless permissions.include?(p.to_sym)
    end
    save!
  end
  
  # 権限の削除
  def remove_permission!(*perms)
    return unless permissions.is_a?(Array)
    permissions_will_change!
    perms.each {|p| permissions.delete(p.to_sym)}
    save!
  end
end
```

## カスタマイズ機能

### CustomField階層（STIパターン）

```
CustomField
├── IssueCustomField
├── ProjectCustomField
├── UserCustomField
├── GroupCustomField
├── TimeEntryCustomField
├── TimeEntryActivityCustomField
├── DocumentCustomField
├── DocumentCategoryCustomField
├── IssuePriorityCustomField
└── VersionCustomField
```

#### CustomField
- パス: `app/models/custom_field.rb`
- フィールド形式の多様性

```ruby
class CustomField < ApplicationRecord
  # フィールド形式
  FIELD_FORMATS = Redmine::FieldFormat.all.keys
  
  # STI継承
  self.store_full_sti_class = false
  
  # フォーマット管理
  def format
    @format ||= Redmine::FieldFormat.find(field_format)
  end
  
  # 権限チェック
  def visible_by?(project, user=User.current)
    # 表示権限の判定
  end
end
```

### Enumeration階層（STIパターン）

```
Enumeration  
├── IssuePriority
├── TimeEntryActivity
└── DocumentCategory
```

#### Enumeration
- パス: `app/models/enumeration.rb`
- 階層構造対応

```ruby
class Enumeration < ApplicationRecord
  # STI継承
  self.store_full_sti_class = false
  
  # 階層構造
  acts_as_tree :order => 'position'
  
  # プロジェクト固有の値
  belongs_to :project
  
  # デフォルト値
  scope :default, lambda { where(:is_default => true) }
end
```

## プラグイン拡張ポイント

### Acts As モジュール

#### acts_as_customizable
カスタムフィールド機能を追加

```ruby
# プラグインモデルでの使用例
class PluginModel < ApplicationRecord
  acts_as_customizable
  
  # カスタムフィールドが自動的に利用可能
end
```

#### acts_as_attachable
ファイル添付機能を追加

```ruby
class PluginModel < ApplicationRecord
  acts_as_attachable :after_add => :attachment_added,
                     :after_remove => :attachment_removed
  
  private
  
  def attachment_added(attachment)
    # 添付後の処理
  end
  
  def attachment_removed(attachment)
    # 削除後の処理
  end
end
```

#### acts_as_watchable
ウォッチ機能を追加

```ruby
class PluginModel < ApplicationRecord
  acts_as_watchable
  
  # ウォッチャー機能が自動的に利用可能
  # - watchers関連
  # - watched_by?メソッド
  # - add_watcher, remove_watcherメソッド
end
```

#### acts_as_searchable
検索機能を追加

```ruby
class PluginModel < ApplicationRecord
  acts_as_searchable :columns => ["#{table_name}.title", "#{table_name}.description"],
                     :project_key => 'project_id',
                     :date_column => 'created_on'
  
  # 検索結果での表示設定
  def event_title
    title
  end
  
  def event_description
    description
  end
end
```

#### acts_as_activity_provider
アクティビティ機能を追加

```ruby
class PluginModel < ApplicationRecord
  acts_as_activity_provider :type => 'plugin_activities',
                           :permission => :view_plugin_activities,
                           :timestamp => "#{table_name}.created_on",
                           :author_key => "#{table_name}.author_id"
  
  # アクティビティ表示での設定
  def event_title
    "Activity: #{title}"
  end
  
  def event_datetime
    created_on
  end
end
```

### モデル拡張パターン

#### 既存モデルの拡張
```ruby
# プラグインでの既存モデル拡張例
module PluginExtensions
  module IssueExtension
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        has_many :plugin_records, :dependent => :destroy
        safe_attributes 'plugin_attribute'
      end
    end
    
    module ClassMethods
      def plugin_method
        # クラスメソッドの追加
      end
    end
    
    def plugin_instance_method
      # インスタンスメソッドの追加
    end
  end
end

# 適用
unless Issue.included_modules.include?(PluginExtensions::IssueExtension)
  Issue.send(:include, PluginExtensions::IssueExtension)
end
```

## データベース関連

### マイグレーション
プラグイン用のマイグレーションは`db/migrate/`に配置

```ruby
class CreatePluginTables < ActiveRecord::Migration[7.0]
  def change
    create_table :plugin_records do |t|
      t.string :title, :null => false
      t.text :description
      t.references :project, :null => false, :foreign_key => true
      t.references :author, :null => false, :foreign_key => {:to_table => :users}
      t.timestamps
    end
    
    add_index :plugin_records, :project_id
    add_index :plugin_records, :author_id
  end
end
```

### Fixture
テスト用のfixtureは`test/fixtures/`に配置

```yaml
# test/fixtures/plugin_records.yml
plugin_record_001:
  id: 1
  title: "Test Record"
  description: "Test Description"
  project_id: 1
  author_id: 1
  created_on: 2024-01-01 10:00:00
  updated_on: 2024-01-01 10:00:00
```

## まとめ

Redmineのモデル構造は、以下の特徴によりプラグイン開発に適している：

1. **拡張可能な基底クラス**: ApplicationRecordによる共通機能
2. **STIパターン**: 柔軟な継承構造
3. **Acts Asモジュール**: 機能の再利用性
4. **明確な関連**: モデル間の関係が明確
5. **権限統合**: 統一された権限チェック機能

プラグイン開発者は、これらの仕組みを活用して既存システムと調和した拡張を実現できます。