# frozen_string_literal: true

module Pfaffmanager
  class ServerkeysController < ActionController::Base

    def get_pub_key
      Rails.logger.warn "\n#{'-' * 40}\nServerkeys controller get_pub_key for #{params[:id]}\n"
      puts "serverkeys--get_pub_key"
      server = ::Pfaffmanager::Server.find_by(id: params[:id])
      if server # rubocop:disable Style/GlobalVars
        render plain: server.ssh_key_public, status: 200
      else
        render plain: "invalid server", status: 403
      end
    end

    def get_pub_key_by_hostname
      Rails.logger.warn "\n#{'-' * 40}\nServerkeys controller get_pub_key_by_hostname for #{params[:hostname]}\n"
      puts "serverkeys--get_pub_key_by_hostname"
      server = ::Pfaffmanager::Server.find_by(hostname: params[:hostname])
      if server # rubocop:disable Style/GlobalVars
        render plain: server.ssh_key_public, status: 200
      else
        render plain: "invalid stupid server", status: 403
      end
    end
  end

end
