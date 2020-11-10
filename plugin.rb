# frozen_string_literal: true

# name: Pfaffmanager
# about: Managing Discourse Instances
# version: 0.1
# authors: pfaffman
# url: https://github.com/pfaffman

register_asset 'stylesheets/common/pfaffmanager.scss'
register_asset 'stylesheets/desktop/pfaffmanager.scss', :desktop
register_asset 'stylesheets/mobile/pfaffmanager.scss', :mobile

enabled_site_setting :pfaffmanager_enabled

PLUGIN_NAME ||= 'Pfaffmanager'

load File.expand_path('lib/pfaffmanager/engine.rb', __dir__)
load File.expand_path('lib/pfaffmanager/pfaffmanager_requests.rb', __dir__)

after_initialize do
  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-pfaffmanager", "db", "fixtures").to_s

  load File.expand_path('../app/controllers/server_controller.rb', __FILE__)

  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb
end
