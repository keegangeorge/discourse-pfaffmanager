# frozen_string_literal: true

module Pfaffmanager
    class Server < ActiveRecord::Base
      self.table_name = "pfaffmanager_servers"
      
      validate :connection_validator
      after_save :update_server_status
  
      scope :find_user, ->(user) { find_by_user_id(user.id) }
    
      def self.createServer(user_id, hostname, public_key=nil, private_key=nil)
        create(user_id: user_id, hostname: hostname, ssh_key_public: public_key, ssh_key_private: private_key)
      end

      private
      
      def update_server_status
        if discourse_api_key.present? && (Time.now - server_status_updated_at < 60)
          headers = {'api-key' => discourse_api_key, 'api-username' => 'system'}
          result = Excon.get("https://#{hostname}/admin/dashboard.json", :headers => headers)
          update_column(:server_status_json, result.body)
          update_column(:server_status_updated_at, Time.now)
        end
      end
      
      # todo: update only if changed?
      # maybe it doesn't matter if we update the column anyway
      def discourse_api_key_validator
          headers = {'api-key' => discourse_api_key, 'api-username' => 'system'}
          result = Excon.get("https://#{hostname}/admin/dashboard.json", :headers => headers)
          if result.status == 200
            update_column(:server_status_json, result.body)
            update_column(:server_status_updated_at, Time.now)
            true
          else 
            false
          end  
      end

      def connection_validator
        unless hostname.present?
          errors.add(:hostname, "Hostname must be present")
        end

        if discourse_api_key.present? && !discourse_api_key_validator
          errors.add(:discourse_api_key, "API key is bad")
        end
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
