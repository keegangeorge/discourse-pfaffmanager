# frozen_string_literal: true
MAXMIND_PRODUCT ||= 'GeoLite2-City'

module Pfaffmanager
  class Server < ActiveRecord::Base
    #include ActiveModel::Dirty
    belongs_to :user
    self.table_name = "pfaffmanager_servers"

    validate :connection_validator
    before_save :update_server_status if !:id.nil?
    before_save :process_server_request
    before_save :do_api_key_validator if !:do_api_key.blank?
    before_save :reset_request if !:request_status.nil?
    after_save :publish_status_update if :saved_change_to_request_status?

    scope :find_user, ->(user) { find_by_user_id(user.id) }

    def self.ensure_group(name)
      Group.find_or_create_by(name: name,
                              visibility_level: Group.visibility_levels[:staff],
                              full_name: "Pfaffmanager #{name}"
      )
    end

    def self.ensure_pfaffmanager_groups
      self.ensure_group(SiteSetting.pfaffmanager_create_server_group)
        self.ensure_group(SiteSetting.pfaffmanager_unlimited_server_group)
        self.ensure_group(SiteSetting.pfaffmanager_server_manager_group)
    end

    def self.createServerForUser(user_id, hostname = "new-server-for-#{user_id}")
      Rails.logger.warn "Creating server for user #{hostname} for #{user_id}"
      create(user_id: user_id, hostname: hostname)
    end

    def self.createServerFromParams(params)
      current_user_id = params[:user_id]
      return nil unless current_user_id
      params[:hostname] ||= "new-server-for-#{current_user_id}"
      Rails.logger.warn "Creating server #{params[:hostname]} for #{current_user_id}"
      create(params)
    end

    def self.create_default_groups
      create_group_name = 'CreateServer'
      Group.create(name: create_group_name,
                   visibility_level: Group.visibility_levels[:owners],
                  )
      SiteSetting.pfaffmanager_create_server_group = create_group_name
      unlimited_group_name = 'UnlimitedServers'
      Group.create(name: unlimited_group_name,
                   visibility_level: Group.visibility_levels[:owners],
                  )
      SiteSetting.pfaffmanager_unlimited_server_group = unlimited_group_name
      manager_group_name = 'ServerManager'
      Group.create(name: manager_group_name,
                   visibility_level: Group.visibility_levels[:owners],
                  )
      SiteSetting.pfaffmanager_server_manager_group = manager_group_name
    end

    def update_server_status
      begin
        # TODO: REMOVE OR enforce admin only
        if self.hostname.match(/localhost/)
          Rails.logger.warn "using bogus host info"
          body = '{
            "updated_at": "2020-11-24T21:25:56.643Z",
            "version_check": {
            "installed_version": "2.6.0.beta6",
            "installed_sha": "1157ff8116ba5e5d11db589e1b6cb930d2c86c4d",
            "installed_describe": "v2.6.0.beta6 +1",
            "git_branch": "master",
            "updated_at": null,
            "version_check_pending": true,
            "stale_data": true
            }
            }'
            Rails.logger.warn "GOING THE VERSION DCHECK"
            version_check = JSON.parse(body)['version_check']
            self.installed_version = version_check['installed_version']
            self.installed_sha = version_check['installed_sha']
            self.git_branch = version_check['git_branch']
          else
            if discourse_api_key.present? && !discourse_api_key.blank?
              headers = { 'api-key' => discourse_api_key, 'api-username' => 'system' }
          protocol = self.hostname.match(/localhost/) ? 'http://' : 'https://'
          Rails.logger.warn "\n\nGOING TO GET: #{protocol}#{hostname}/admin/dashboard.json with #{headers}"
          result = Excon.get("#{protocol}#{hostname}/admin/dashboard.json", headers: headers)
          Rails.logger.warn "got it!"
          self.server_status_json = result.body
          self.server_status_updated_at = Time.now
          Rails.logger.warn "going to version check: #{result.body[0..300]}"
          version_check = JSON.parse(result.body)['version_check']
          Rails.logger.warn "got the version check"
          self.installed_version = version_check['installed_version']
          self.installed_sha = version_check['installed_sha']
          self.git_branch = version_check['git_branch']
          Rails.logger.warn "did the stuff"
            end
        end
      rescue => e
        Rails.logger.warn "cannot update server status: #{e[0..200]}"
      end
    end

    private

    def reset_request # update server model that process is finished
      Rails.logger.warn " -=--------------------- RESET #{request_status}\n" unless false
      case request_status
      when "Success"
        Rails.logger.warn "Set request_result OK"
          self.request_result = 'ok'
          update_server_status
          self.request = 0
          self.request_status_updated_at = Time.now
      when "Processing rebuild"
        self.request_result = 'running'
          Rails.logger.warn "Set request_result running"
          self.request_status_updated_at = Time.now
      when "Failed"
        self.request_result = 'failed'
          self.request = 0
          Rails.logger.warn "Set request_result failed"
          self.request_status_updated_at = Time.now
      end
    end

    def publish_status_update
      data = {
        request_status: self.request_status,
        request_status_updated_at: self.request_status_updated_at
      }
      # TODO: add to MessageBus something like -- group_ids: [pfaffmanager_manager_group.id]
      # to allow real-time access to all servers on the site
      MessageBus.publish("/pfaffmanager-server-status/#{self.id}", data, user_ids: [self.user_id, 1])
    end

    def process_server_request
      Rails.logger.warn "This really is A real rails log!! PROCESS SERVER REQUEST: '#{request}'"
      case request
      when 1
        Rails.logger.warn "Processing request 1 -- rebuild -- run_ansible_upgrade"
        self.request = -1
        self.request_status_updated_at = Time.now
        self.last_action = "Process rebuild/upgrade"
        inventory = build_server_inventory
        self.inventory = inventory
        run_ansible_upgrade(inventory)
      when 2
        Rails.logger.warn "Processing request 2 -- createDroplet -- do_install"
        self.request = -1
        self.request_status_updated_at = Time.now
        self.last_action = "Create droplet"
        do_install
      end
    end

    def installation_script_template
      Rails.logger.warn "installation_script_template running now"
      user = User.find(user_id)
      playbook_dir = SiteSetting.pfaffmanager_playbook_dir
      <<~HEREDOC
      #!/usr/bin/env bash
      # Custom Order Placed at #{Time.now}
      export EMAIL="#{user.email}"
      export NAME="#{user.name}"
      export DO_HOSTNAME="#{hostname}"
      export DO_API_KEY="#{do_api_key}"
      export MG_API_KEY="#{mg_api_key}"
      export DO_REGION="nyc3"
      export DO_SIZE=""
      export PFAFFMANAGER_BASE_URL="#{Discourse.base_url}"
      export PFAFFMANAGER_SERVER_ID="#{id}"
      export DISCOURSE_SSH_USER=root
      #{SiteSetting.pfaffmanager_do_install} pro
      HEREDOC
    end

    def managed_inventory_template
      Rails.logger.warn "managed_inventory_template running now"
      user = User.find(user_id)
      <<~HEREDOC
        ---
        all:
          vars:
            ansible_user: root
            ansible_python_interpreter: /usr/bin/python3
            pfaffmanager_base_url: #{Discourse.base_url}
            lc_smtp_password: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              30643766333939393233396330353461303431633262306661633332376262323661616639373232
              3966626533373938373637363132386464323337346537380a333361613663633034383663323539
              36626661663739313036363761313665353236646238376163316430656634343530646666303465
              3563323532633330350a616662386233343534653762653762336466633863646332383735616463
              30346533323635313663383030666532383664353465343165343265386639663662613463376432
              35626335323165343636336261646461396666653966306365383037616130663939306135303230
              613430336166663466373032343238353933
            discourse_yml: 'app'
          children:
            discourse:
              hosts:
                #{hostname}:
                  pfaffmanager_server_id: #{id}
                  skip_bootstrap: yes
                  discourse_name: #{user.name || 'pfaffmanager user'}
                  discourse_email: #{user.email}
                  discourse_url: #{discourse_url}
                  discourse_smtp_host: ""
                  discourse_smtp_password: ""
                  discourse_smtp_user: ""
                  discourse_extra_envs:
                    - "CURRENTLY_IGNORED: true"
                  discourse_custom_plugins:
                    - https://github.com/discourse/discourse-subscriptions.git
          HEREDOC
    end

    def run_ansible_upgrade(inventory, log = "/tmp/upgrade.log")
      dir = SiteSetting.pfaffmanager_playbook_dir
      playbook = SiteSetting.pfaffmanager_upgrade_playbook
      vault = SiteSetting.pfaffmanager_vault_file
      #$DIR/../upgrade.yml --vault-password-file /data/literatecomputing/vault-password.txt -i $inventory $*
      # consider https://github.com/pgeraghty/ansible-wrapper-ruby
      # consider Discourse::Utils.execute_command('ls')
      if SiteSetting.pfaffmanager_skip_actions
        Rails.logger.warn "SKIP actions is set. Not running upgrade"
        self.request = 0
        self.discourse_api_key ||= ApiKey.create(description: 'pfaffmanager localhost key')
        self.update_server_status
        Jobs.enqueue(:fake_upgrade, server_id: self.id)
      else
        Rails.logger.warn "Going to fork: #{playbook} --vault-password-file #{vault} -i #{inventory}"
        fork { exec("#{playbook} --vault-password-file #{vault} -i #{inventory} 2>&1 >#{log}") }
        #output, status =Open3.capture2e("#{dir}/#{playbook} --vault-password-file #{vault} -i #{inventory}") }
      end
    end

    def do_install
      install_script = build_install_script
      Rails.logger.warn "Wrote #{install_script}"
      # TODO: consider Discourse::Utils.execute_command
      if SiteSetting.pfaffmanager_skip_actions
        Rails.logger.warn "SKIP actions is set. Doing fake install"
        update_server_status
        Jobs.enqueue(:fake_upgrade, server_id: self.id)
      else
        Rails.logger.warn "GOING TO RUN #{install_script}"
        fork { exec("#{install_script}") }
      end
    end

    def build_server_inventory
      #user = User.find(user_id)
      now = Time.now.strftime('%Y-%m%d-%H%M')
      filename = "#{SiteSetting.pfaffmanager_inventory_dir}/#{id}-#{hostname}-#{now}-inventory.yml"
      File.open(filename, "w") do |f|
        f.write(managed_inventory_template)
      end
      Rails.logger.warn "Writing #{filename}"
      managed_inventory_template
    end

    def build_install_script
      dir = SiteSetting.pfaffmanager_inventory_dir
      now = Time.now.strftime('%Y-%m%d-%H%M')
      filename = "#{dir}/#{id}-#{hostname}-#{now}-droplet_create"
      # TODO: consider Discourse::Utils.atomic_write_file
      File.open(filename, "w") do |f|
        f.write(installation_script_template)
      end
      File.chmod(0777, "#{filename}")
      Rails.logger.warn "Wrote #{filename} with \n#{installation_script_template}"
      filename
    end

    # todo: update only if changed?
    # maybe it doesn't matter if we update the column anyway
    def discourse_api_key_validator
      return true if discourse_api_key.nil? || discourse_api_key.blank?
      headers = { 'api-key' => discourse_api_key, 'api-username' => 'system' }
      begin
        result = Excon.get("https://#{hostname}/admin/dashboard.json", headers: headers)
        if result.status == 200
          # server_status_json=result.body
          # server_status_updated_at=Time.now
          true
        elsif result.status == 422
          errors.add(:discourse_api_key, "invalid")
        else
          errors.add(:discourse_api_key, "invalid")
        end
      rescue => e
        Rails.logger.warn "Error #{e}"
        errors.add(:discourse_api_key, "-- #{e}")
        false
      end
    end

    def mg_api_key_validator
      url = "https://api:#{mg_api_key}@api.mailgun.net/v3/domains"
      result = Excon.get(url, headers: {})
      #accounts = result.body
      if result.status == 200
        true
      else
        errors.add(:mg_api_key, result.reason_phrase)
        false
      end
    end

    def maxmind_license_key_validator
      url = "https://download.maxmind.com/app/geoip_download?license_key=#{maxmind_license_key}&edition_id=#{MAXMIND_PRODUCT}&suffix=tar.gz"
      result = Excon.get(url)
      if result.status == 200
        true
      else
        errors.add(:maxmind_license_key, result.body)
        false
      end
    end

    def server_request_validator
      if !request.in? [-1, 0, 1, 2]
        Rails.logger.warn "Request bad: #{request}"
        errors.add(:request, "Valid values: 0..2")
      end
    end

    def do_api_key_validator
      return true if do_api_key.blank?
      return true if do_api_key.match(/testing/)
      url = "https://api.digitalocean.com/v2/account"
      headers = { 'Authorization' => "Bearer #{do_api_key}" }
      begin
        result = Excon.get(url, headers: headers)
        do_status = JSON.parse(result.body)['account']['status']
        if result.status == 200 && do_status == "active"
          true
        else
          errors.add(:do_api_key, "Account not active")
          false
        end
      rescue
        errors.add(:do_api_key, 'Key Invalid (401)')
      end
    end

    def connection_validator
      Rails.logger.warn "connection_validator..."
      unless hostname.present?
        errors.add(:hostname, "Hostname must be present")
      end

        Rails.logger.warn "discourse: #{discourse_api_key}"
        discourse_api_key.present? && !discourse_api_key_validator
        Rails.logger.warn "mg"
        mg_api_key.present? && !mg_api_key_validator
        Rails.logger.warn "do"
        do_api_key.present? && !do_api_key_validator
        Rails.logger.warn "mm"
        maxmind_license_key.present? && !maxmind_license_key_validator
        Rails.logger.warn "req"
        request.present? && server_request_validator
        Rails.logger.warn "done with validations!"
    end
  end
end
