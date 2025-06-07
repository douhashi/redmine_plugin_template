Redmine::Plugin.register :redmine_plugin_skelton do
  name 'Redmine Plugin Skelton'
  author 'Author Name'
  description 'This is a skelton plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/douhashi/redmine_plugin_skelton'
  author_url 'https://github.com/douhashi'

  project_module :redmine_plugin_skelton do
    permission :view_skelton, { :skelton => [:index, :show] }, :public => true
    permission :manage_skelton, { :skelton => [:new, :create, :edit, :update, :destroy] }
  end

  menu :project_menu, :skelton, { :controller => 'skelton', :action => 'index' }, :caption => 'Skelton', :after => :settings, :param => :project_id
end