# frozen_string_literal: true
MAXMIND_PRODUCT = 'GeoLite2-City'

module Pfaffmanager
    class Server < ActiveRecord::Base
      include ActiveModel::Dirty
      self.table_name = "pfaffmanager_servers"
      
      validate :connection_validator
      after_save :update_server_status
  
      scope :find_user, ->(user) { find_by_user_id(user.id) }
    
      def self.createServer(user_id, hostname, public_key=nil, private_key=nil)
        create(user_id: user_id, hostname: hostname, ssh_key_public: public_key, ssh_key_private: private_key)
      end

      def version_check
        version_check = JSON.parse(server_status_json)['version_check']
      end

      private

      def update_server_status
        puts "Calling update_server_status"
        if discourse_api_key.present? && discourse_api_key_changed? && (Time.now - server_status_updated_at < 60)
          headers = {'api-key' => discourse_api_key, 'api-username' => 'system'}
          result = Excon.get("https://#{hostname}/admin/dashboard.json", :headers => headers)
          update_column(:server_status_json, result.body)
          update_column(:server_status_updated_at, Time.now)
          update_column(:installed_version, version_check['installed_version'])
          update_column(:installed_sha, version_check['installed_sha'])
          update_column(:git_branch, version_check['git_branch'])
        end
      end

      # todo: update only if changed?
      # maybe it doesn't matter if we update the column anyway
      def discourse_api_key_validator
        headers = {'api-key' => discourse_api_key, 'api-username' => 'system'}
        begin 
          result = Excon.get("https://#{hostname}/admin/dashboard.json", :headers => headers)
          if result.status == 200
            update_column(:server_status_json, result.body)
            update_column(:server_status_updated_at, Time.now)
            true
            elsif result.status = 422
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

    def do_api_key_validator
      puts "DO API KEY: #{do_api_key}"
      url = "https://api.digitalocean.com/v2/account"
      headers = {'Authorization' => "Bearer #{do_api_key}"}
      begin
        result = Excon.get(url, :headers => headers)
        puts "result: #{result}"
        puts "Status: #{result.status}"
        do_status = JSON.parse(result.body)['account']['status']
        puts "DO status: #{do_status}"
        if result.status == 200 && do_status=="active"
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
        unless hostname.present?
          errors.add(:hostname, "Hostname must be present")
        end

        discourse_api_key.present? && !discourse_api_key_validator

        mg_api_key.present? && !mg_api_key_validator
        do_api_key.present? && do_api_key_changed? && !do_api_key_validator
        maxmind_license_key.present? && !maxmind_license_key_validator
        
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
