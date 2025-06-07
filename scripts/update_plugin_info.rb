#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

class PluginInfoUpdater
  INIT_RB_PATH = File.join(File.dirname(__dir__), 'init.rb')
  
  def initialize
    @fields = {
      name: 'プラグイン名',
      author: '作成者名',
      description: '説明',
      version: 'バージョン',
      url: 'プロジェクトURL',
      author_url: '作成者URL'
    }
  end

  def run
    puts "Redmineプラグイン情報更新スクリプト"
    puts "=" * 40
    
    unless File.exist?(INIT_RB_PATH)
      puts "エラー: #{INIT_RB_PATH} が見つかりません。"
      exit 1
    end

    current_values = extract_current_values
    new_values = collect_new_values(current_values)
    
    if confirm_update(new_values)
      update_init_rb(new_values)
      puts "\n✅ #{INIT_RB_PATH} を更新しました！"
    else
      puts "\n❌ 更新をキャンセルしました。"
    end
  end

  private

  def extract_current_values
    content = File.read(INIT_RB_PATH)
    values = {}
    
    @fields.keys.each do |field|
      pattern = /#{field}\s+['"]([^'"]*)['"]/
      match = content.match(pattern)
      values[field] = match ? match[1] : ''
    end
    
    values
  end

  def collect_new_values(current_values)
    new_values = {}
    
    puts "\n現在の値が表示されます。変更しない場合はEnterを押してください。\n\n"
    
    @fields.each do |key, label|
      current = current_values[key] || ''
      print "#{label} [#{current}]: "
      
      input = gets.chomp
      new_values[key] = input.empty? ? current : input
    end
    
    new_values
  end

  def confirm_update(new_values)
    puts "\n更新内容の確認:"
    puts "-" * 30
    
    @fields.each do |key, label|
      puts "#{label}: #{new_values[key]}"
    end
    
    puts "\nこの内容で更新してよろしいですか？ (y/N): "
    response = gets.chomp.downcase
    ['y', 'yes'].include?(response)
  end

  def update_init_rb(new_values)
    content = File.read(INIT_RB_PATH)
    
    @fields.keys.each do |field|
      pattern = /(#{field}\s+['"])([^'"]*)(['"])/
      content.gsub!(pattern, "\\1#{new_values[field]}\\3")
    end
    
    # バックアップ作成
    backup_path = "#{INIT_RB_PATH}.backup.#{Time.now.strftime('%Y%m%d_%H%M%S')}"
    FileUtils.cp(INIT_RB_PATH, backup_path)
    puts "バックアップを作成しました: #{backup_path}"
    
    # ファイル更新
    File.write(INIT_RB_PATH, content)
  end
end

# スクリプト実行
if __FILE__ == $0
  updater = PluginInfoUpdater.new
  updater.run
end