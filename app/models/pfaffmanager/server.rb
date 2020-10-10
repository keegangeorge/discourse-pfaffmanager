# frozen_string_literal: true

module Pfaffmanager
    class Server < ActiveRecord::Base
      self.table_name = "pfaffmanager_servers"
      
      validate :connection_validator
  
      scope :find_user, ->(user) { find_by_user_id(user.id) }
    
      def self.createServer(user_id, hostname, public_key=nil, private_key=nil)
        create(user_id: user_id, hostname: hostname, ssh_key_public: public_key, ssh_key_private: private_key)
      end
      
      private
      
      def connection_validator
        unless hostname.present?
          errors.add(:hostname, "Hostname must be present")
        end
        
        unless discourse_api_key === "good"
          errors.add(:discourse_api_key, "API key is bad")
        end
      end
    end
  end
  