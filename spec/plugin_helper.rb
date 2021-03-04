# frozen_string_literal: true

Dir[Rails.root.join("plugins/discourse-pfaffmanager/spec/fabricators/*.rb")].each { |f| require f }

if ENV['SIMPLECOV']
  require 'simplecov'

  SimpleCov.start do
    root "plugins/discourse-pfaffmanager"
    track_files "plugins/discourse-pfaffmanager/**/*.rb"
    add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
  end
end

require 'rails_helper'