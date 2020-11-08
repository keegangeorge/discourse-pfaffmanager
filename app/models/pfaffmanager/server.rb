# frozen_string_literal: true
MAXMIND_PRODUCT ||= 'GeoLite2-City'

module Pfaffmanager
  class Server < ActiveRecord::Base
    include ActiveModel::Dirty
    self.table_name = "pfaffmanager_servers"

    validate :connection_validator
    before_save :update_server_status if !:id.nil?
    before_save :process_server_request
    before_save :do_api_key_validator if !:do_api_key.blank?
    before_save :reset_request if !:request_status.nil?
    #before_save :fill_empty_server_fields if !:id.nil?

    scope :find_user, ->(user) { find_by_user_id(user.id) }

    def self.createServerForUser(user_id, hostname = "new-server-for-#{user_id}")
      puts "Creating server #{hostname} for #{user_id}"
      create(user_id: user_id, hostname: hostname)
    end

    def self.createServerFromParams(params)
      current_user_id = params[:user_id]
      return nil unless current_user_id
      params[:hostname] ||= "new-server-for-#{current_user_id}"
      puts "Creating server #{params[:hostname]} for #{current_user_id}"
      create(params)
    end

    private

    def reset_request # update server model that process is finished
      puts " -=--------------------- RESET #{request_status}\n"
      case request_status
      when "Success"
        puts "Set request_result OK"
          update_column(:request_result, 'ok')
          update_server_status
          update_column(:request, 0)
          update_column(:request_status_updated_at, Time.now)
      when "Processing rebuild"
        update_column(:request_result, 'running')
          puts "Set request_result running"
          update_column(:request_status_updated_at, Time.now)
      when "Failed"
        update_column(:request_result, 'failed')
          update_column(:request, 0)
          puts "Set request_result failed"
          update_column(:request_status_updated_at, Time.now)
      end
    end

    def process_server_request
      puts "\n\nPROCESS SERVER REQUEST: #{request}\n\n"
      case request
      when 1
        puts "Processing request 1 -- rebuild"
        update_column(:request, -1)
             update_column(:request_status_updated_at, Time.now)
        update_column(:last_action, "Process rebuild")
        inventory = build_server_inventory
        update_column(:inventory, inventory)
        run_ansible_upgrade(inventory)
      when 2
        puts "Processing request 2 -- createDroplet"
        update_column(:request, -1)
        update_column(:request_status_updated_at, Time.now)
        update_column(:last_action, "Create droplet")
        do_install
      end
    end

    def installation_script_template
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
      #{playbook_dir}/#{SiteSetting.pfaffmanager_do_install} pro
      HEREDOC
    end

    def managed_inventory_template
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
                  discourse_name: #{user.name}
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

      fork { exec("#{dir}/#{playbook} --vault-password-file #{vault} -i #{inventory} 2>&1 >#{log}") }
      #output, status =Open3.capture2e("#{dir}/#{playbook} --vault-password-file #{vault} -i #{inventory}") }
    end

    def do_install
      install_script = build_install_script
      puts "Wrote #{install_script}"
      fork { exec("#{install_script}") }
    end

    def build_server_inventory
      #user = User.find(user_id)
      now = Time.now.strftime('%Y-%m%d-%H%M')
      filename = "#{SiteSetting.pfaffmanager_inventory_dir}/#{id}-#{hostname}-#{now}-inventory.yml"
      File.open(filename, "w") do |f|
        f.write(managed_inventory_template)
      end
      puts "Writing #{filename} with \n#{managed_inventory_template}"
      filename
    end

    def build_install_script
      dir = SiteSetting.pfaffmanager_inventory_dir
      now = Time.now.strftime('%Y-%m%d-%H%M')
      filename = "#{dir}/#{id}-#{hostname}-#{now}-droplet_create"
      File.open(filename, "w") do |f|
        f.write(installation_script_template)
      end
      File.chmod(0777, "#{filename}")
      puts "Wrote #{filename} with \n#{installation_script_template}"
      filename
    end

    def update_server_status
      puts "\n\n\n\n#{'-' * 50}\nupdate_server_status running NOW for #{hostname} with api: #{discourse_api_key}"
      puts "discourse_api_key is blank" if discourse_api_key.blank?
      begin
        if discourse_api_key.present? && !discourse_api_key.blank?
          puts "update_server_status still attempting to get dashboard.json"
          headers = { 'api-key' => discourse_api_key, 'api-username' => 'system' }
          result = Excon.get("https://#{hostname}/admin/dashboard.json", headers: headers)
          puts "update server status got: #{result.body}"

          self.server_status_json = result.body
          self.server_status_updated_at = Time.now
          version_check = JSON.parse(result.body)['version_check']
          puts "VERSION: #{version_check}"
          self.installed_version = version_check['installed_version']
          puts "Setting installed_sha to #{version_check['installed_sha']}"
          self.installed_sha = version_check['installed_sha']
          self.git_branch = version_check['git_branch']
        end
      rescue => e
        puts "cannot update server status: #{e}"
      end
    end

    # todo: update only if changed?
    # maybe it doesn't matter if we update the column anyway
    def discourse_api_key_validator
      puts "\n\nAPI KEY VALIDATOR for #{hostname} with #{discourse_api_key}\n\n"
      return true if discourse_api_key.nil? || discourse_api_key.blank?

      headers = { 'api-key' => discourse_api_key, 'api-username' => 'system' }
      begin
        puts "api key validator trying to get #{hostname} with #{discourse_api_key}"
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
        puts "Error #{e}"
        errors.add(:discourse_api_key, "-- #{e}")
        false
      end
    end

    def mg_api_key_validator
      url = "https://api:#{mg_api_key}@api.mailgun.net/v3/domains"
      result = Excon.get(url)
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
        puts "Request bad: #{request}"
        errors.add(:request, "Valid values: 0..2")
      end
    end

    def do_api_key_validator
      puts "DO API KEY: #{do_api_key}"
      puts "BLANK" if do_api_key.blank?
      return true if do_api_key.blank?
      url = "https://api.digitalocean.com/v2/account"
      headers = { 'Authorization' => "Bearer #{do_api_key}" }
      begin
        result = Excon.get(url, headers: headers)
        puts "result: #{result}"
        puts "body: #{result.body}"
        puts "account: #{JSON.parse(result.body)['account']}"
        puts "Status: #{result.status}"
        do_status = JSON.parse(result.body)['account']['status']
        puts "DO status: #{do_status}"
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

    def fill_empty_server_fields
      puts "DOING NOTHING. FIlling empty... for #{id}"
      discourse_url ||= "https://#{hostname}"
      puts "XXXXXXXXXXXXX filling the fields URL: (#{discourse_url})"
      #update_column(:discourse_url, discourse_url)
    end

    def connection_validator
      unless hostname.present?
        errors.add(:hostname, "Hostname must be present")
      end

        puts "discourse: #{discourse_api_key}"
        discourse_api_key.present? && !discourse_api_key_validator
        puts "MG: #{mg_api_key}"
        mg_api_key.present? && !mg_api_key_validator
        puts "DO: #{do_api_key}"
        do_api_key.present? && !do_api_key_validator
        maxmind_license_key.present? && !maxmind_license_key_validator
        request.present? && server_request_validator
    end
  end
end
# == schema informaion
# class CreatePfaffmanagerServer < ActiveRecord::Migration[6.0]
# def change
#   create_table :pfaffmanager_servers do |t|
#     t.string :hostname, null: false, index: true
#     t.text :server_status_json
#     t.timestamp :server_status_updated_at
#     t.string :ssh_key_private
#     t.string :ssh_key_public
#     t.string :discourse_api_key
#     t.string :do_api_key
#     t.string :mg_api_key
#     t.string :maxmind_license_key
#     t.string :discourse_url
#     t.text   :inventory
#     t.text   :discourse_env
#     t.text   :discourse_templates
#     t.text   :discourse_plugins
#     t.references :user
#     t.timestamps
#   end
# end
# end
