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
load File.expand_path('lib/encryption_service.rb', __dir__)
load File.expand_path('lib/encryptable.rb', __dir__)
after_initialize do
  load File.expand_path('../app/controllers/server_controller.rb', __FILE__)
  # load File.expand_path('app/jobs/regular/fake_upgrade.rb', __dir__)
  Pfaffmanager::Server.ensure_pfaffmanager_groups
  SiteSetting.pfaffmanager_api_key ||= ApiKey.create(description: 'pfaffmanager key').key_hash
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb

  add_model_callback(GroupUser, :after_save) do
    Rails.logger.warn('GroupUser callback!')
    Rails.logger.warn("GroupUser callback! for group #{self.group_id} user #{self.user_id}")
    # TODO: create server and remove from group
    # TODO: and redirect somewhere else?
  end
end
