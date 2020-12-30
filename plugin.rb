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

# See discourse-assign for good examples of serializer, callback, adding method
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
    # is it the createserver group?
    create_group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
    pro_server_group = Group.find_by_name(SiteSetting.pfaffmanager_pro_server_group)
    if [create_group.id, pro_server_group.id].include?(self.group_id)
      # TODO: create server
      Rails.logger.warn "Creating a server for #{self.id}"
      install_type = nil
      if self.group_id == pro_server_group
        install_type = "pro"
      end

      server = ::Pfaffmanager::Server.createServerFromParams(user_id: self.user_id, install_type: install_type)
      Rails.logger.warn "Added #{server.id} for #{self.user_id}"
      gu = GroupUser.find_by(user_id: self.user_id, group_id: create_group.id)
      if gu
        Rails.logger.warn "Removing #{self.user_id} from #{gu.group_id}"
        gu.destroy
      end
      # remove from group
      # TODO: and redirect somewhere else?
    end
  end
end
