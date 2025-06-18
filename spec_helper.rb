# frozen_string_literal: true

# This file is used by RSpec to load plugin specs
# It ensures that plugin specs are properly loaded and configured

# Dynamically find and load all plugin spec helpers
plugins_dir = File.expand_path('plugins', __dir__)
if Dir.exist?(plugins_dir)
  Dir.glob(File.join(plugins_dir, '*')).each do |plugin_path|
    next unless File.directory?(plugin_path)
    
    plugin_name = File.basename(plugin_path)
    
    # Load the plugin's spec_helper if it exists
    plugin_spec_helper = File.join(plugin_path, 'spec', 'spec_helper.rb')
    require plugin_spec_helper if File.exist?(plugin_spec_helper)
    
    # Load the plugin's rails_helper for Rails-specific specs
    plugin_rails_helper = File.join(plugin_path, 'spec', 'rails_helper.rb')
    require plugin_rails_helper if File.exist?(plugin_rails_helper)
  end
end
