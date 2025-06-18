# frozen_string_literal: true

# This file is used by RSpec to load plugin specs
# It ensures that plugin specs are properly loaded and configured

# Load the plugin's spec_helper if it exists
plugin_spec_helper = File.expand_path('plugins/redmine_plugin_template/spec/spec_helper.rb', __dir__)
require plugin_spec_helper if File.exist?(plugin_spec_helper)

# Load the plugin's rails_helper for Rails-specific specs
plugin_rails_helper = File.expand_path('plugins/redmine_plugin_template/spec/rails_helper.rb', __dir__)
require plugin_rails_helper if File.exist?(plugin_rails_helper)
