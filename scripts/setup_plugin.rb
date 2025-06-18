#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

class PluginSetup
  INIT_RB_PATH = File.join(File.dirname(__dir__), 'init.rb')

  def initialize
    @fields = {
      plugin_id: 'Plugin ID (e.g., my_awesome_plugin)',
      name: 'Plugin Name',
      author: 'Author Name',
      description: 'Description',
      version: 'Version',
      url: 'Project URL',
      author_url: 'Author URL'
    }
  end

  def run
    puts 'Redmine Plugin Setup Script'
    puts '=' * 40

    unless File.exist?(INIT_RB_PATH)
      puts "Error: #{INIT_RB_PATH} not found."
      exit 1
    end

    current_values = extract_current_values
    new_values = collect_new_values(current_values)

    if confirm_update(new_values)
      update_init_rb(new_values)
      puts "\n✅ #{INIT_RB_PATH} updated successfully!"
    else
      puts "\n❌ Update cancelled."
    end
  end

  private

  def extract_current_values
    content = File.read(INIT_RB_PATH)
    values = {}

    # Extract plugin ID
    plugin_id_pattern = /Redmine::Plugin\.register\s+:(\w+)/
    plugin_id_match = content.match(plugin_id_pattern)
    values[:plugin_id] = plugin_id_match ? plugin_id_match[1] : 'redmine_plugin_template'

    # Extract other fields
    @fields.each_key do |field|
      next if field == :plugin_id

      pattern = /#{field}\s+['"]([^'"]*)['"]/
      match = content.match(pattern)
      values[field] = match ? match[1] : ''
    end

    values
  end

  def collect_new_values(current_values)
    new_values = {}

    puts "\nCurrent values are shown. Press Enter to keep unchanged.\n\n"

    @fields.each do |key, label|
      current = current_values[key] || ''
      print "#{label} [#{current}]: "

      input = gets.chomp
      new_values[key] = input.empty? ? current : input
    end

    new_values
  end

  def confirm_update(new_values)
    puts "\nConfirm update:"
    puts '-' * 30

    @fields.each do |key, label|
      puts "#{label}: #{new_values[key]}"
    end

    puts "\nProceed with this update? (y/N): "
    response = gets.chomp.downcase
    %w[y yes].include?(response)
  end

  def update_init_rb(new_values)
    content = File.read(INIT_RB_PATH)

    # Update plugin ID
    plugin_id_pattern = /(Redmine::Plugin\.register\s+:)(\w+)/
    content.gsub!(plugin_id_pattern, "\\1#{new_values[:plugin_id]}")

    # Update other fields
    @fields.each_key do |field|
      next if field == :plugin_id

      pattern = /(#{field}\s+['"])([^'"]*)(['"])/
      content.gsub!(pattern, "\\1#{new_values[field]}\\3")
    end

    # Create backup
    backup_path = "#{INIT_RB_PATH}.backup.#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    FileUtils.cp(INIT_RB_PATH, backup_path)
    puts "Backup created: #{backup_path}"

    # Update file
    File.write(INIT_RB_PATH, content)
  end
end

# Script execution
if __FILE__ == $PROGRAM_NAME
  setup = PluginSetup.new
  setup.run
end
