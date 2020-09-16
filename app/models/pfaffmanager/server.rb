# frozen_string_literal: true

module Pfaffmanager
    class Server < ActiveRecord::Base
      self.table_name = "pfaffmanager_servers"
  
      scope :find_user, ->(user) { find_by_user_id(user.id) }
    
      def self.createServer(user_id, hostname, public_key=nil, private_key=nil)
        create(user_id: user_id, hostname: hostname, ssh_key_public: public_key, ssh_key_private: private_key)
      end
    end
  end
  