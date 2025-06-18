# frozen_string_literal: true

require_relative '../rails_helper'

RSpec.describe 'Sample test' do
  it 'should pass basic test' do
    expect(1 + 1).to eq(2)
  end

  it 'should have access to Rails environment' do
    expect(Rails.env).to eq('test')
  end

  it 'should have access to Redmine classes' do
    expect(defined?(User)).to be_truthy
    expect(defined?(Project)).to be_truthy
  end
end
