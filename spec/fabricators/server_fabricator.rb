# frozen_string_literal: true

Fabricator(:server, from: :user) do
  user
  hostname { sequence(:title) { |i| "test_hostname_#{i}" } }
end
