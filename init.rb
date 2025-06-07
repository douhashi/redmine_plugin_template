Redmine::Plugin.register :redmine_plugin_template do
  name 'Redmine Plugin Template'
  author 'Sho DOUHASHI'
  description 'This is a template plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/douhashi/redmine_plugin_template'
  author_url 'https://github.com/douhashi'

  project_module :redmine_plugin_template do
    permission :view_template, { :template => [:index, :show] }, :public => true
    permission :manage_template, { :template => [:new, :create, :edit, :update, :destroy] }
  end

  menu :project_menu, :template, { :controller => 'template', :action => 'index' }, :caption => 'Template', :after => :settings, :param => :project_id
end