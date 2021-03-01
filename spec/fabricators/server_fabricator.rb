# frozen_string_literal: true
#require 'rails_helper'
Fabricator(:server, from: "Pfaffmanager::Server") do
  user
  hostname { sequence(:hostname) { |i| "test-hostname-#{i}" } }
end
