# frozen_string_literal: true
if ENV['SIMPLECOV']
  require 'simplecov'

  SimpleCov.start do
    root "plugins/discourse-pfaffmanager"
    track_files "plugins/discourse-pfaffmanager/**/*.rb"
    add_filter { |src| src.filename =~ /(\/spec\/|\/gems\/|\/db\/|plugin\.rb)/ }
  end
end

Dir[Rails.root.join("plugins/discourse-pfaffmanager/spec/fabricators/*.rb")].each { |f| require f }

require 'rails_helper'
