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
  #SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-pfaffmanager", "db", "fixtures").to_s
  Pfaffmanager::Server.ensure_pfaffmanager_groups! unless Rails.env == "test"
  SiteSetting.pfaffmanager_api_key = ApiKey.create(description: "pfaffmanager key #{Time.now}").key unless SiteSetting.pfaffmanager_api_key.present?
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb

  add_model_callback(GroupUser, :after_save) do
    Rails.logger.warn('GroupUser callback!')
    Rails.logger.warn("GroupUser callback! for group #{self.group_id} user #{self.user_id}")
    # is it the createserver group?
    create_groups = []

    create_group = Group.find_by_name(SiteSetting.pfaffmanager_create_server_group)
    create_groups << create_group.try(:id)

    pro_server_group = Group.find_by_name(SiteSetting.pfaffmanager_pro_server_group)
    create_groups << pro_server_group.try(:id)

    ec2_server_group = Group.find_by_name(SiteSetting.pfaffmanager_ec2_server_group)
    create_groups << ec2_server_group.try(:id)

    ec2_pro_server_group = Group.find_by_name(SiteSetting.pfaffmanager_ec2_pro_server_group)
    create_groups << ec2_pro_server_group.try(:id)

    self_install_server_group = Group.find_by_name(SiteSetting.pfaffmanager_self_install_server_group)
    create_groups << self_install_server_group.try(:id)

    pfaffmanager_hosted_server_group = Group.find_by_name(SiteSetting.pfaffmanager_hosted_server_group)
    create_groups << pfaffmanager_hosted_server_group.try(:id)

    params = { user_id: self.user_id }
    if create_groups.include?(self.group_id)
      # TODO: create server
      Rails.logger.warn "Creating a server for #{self.id} in #{self.group_id}"
      case self.group_id
      when create_group.id
        params[:install_type] = 'std'
      when pro_server_group.id
        params[:install_type] = 'pro'
      when ec2_server_group.id
        params[:install_type] = 'ec2'
      when ec2_pro_server_group.id
        params[:install_type] = 'ec2_pro'
      when self_install_server_group.id
        params[:install_type] = 'self_install'
      when pfaffmanager_hosted_server_group.id
        params[:install_type] = 'lc_pro'
        Rails.logger.error "Creating hosted server with no DO API KEY!" unless SiteSetting.pfaffmanager_do_api_key != ''
        Rails.logger.error "Creating hosted server with no MG API KEY!" unless SiteSetting.pfaffmanager_mg_api_key != ''
        params[:do_api_key] = SiteSetting.pfaffmanager_do_api_key
        params[:mg_api_key] = SiteSetting.pfaffmanager_mg_api_key
        Rails.logger.warn "Creating a server with #{params[:do_api_key]} and #{params[:mg_api_key]}"
      end

      server = ::Pfaffmanager::Server.createServerFromParams(params)
      Rails.logger.warn "Added #{server.id} for #{self.user_id}"
      gu = GroupUser.find_by(user_id: self.user_id, group_id: self.group_id)
      if gu
        Rails.logger.warn "Removing #{self.user_id} from #{gu.group_id}"
        gu.destroy
      end
    end
  end
end
