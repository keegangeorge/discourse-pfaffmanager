require 'byebug'

module Pfaffmanager
  class ServersController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in

    def index
      puts "\n\n\n\nServer controller user #{current_user.username} in the house.\n\n\n\n"
      servers = ::Pfaffmanager::Server.where(user_id: current_user.id)
      puts "-----------------> Server controller found #{servers.count} servers"
      render_json_dump({ servers: servers })
    end

    def show
      # TODO: Allow admin to see server of other users
      server = ::Pfaffmanager::Server.find_by(user_id: current_user.id, id: params[:id])
      render_json_dump({ server: server })
    end
    
    def update
      if server = ::Pfaffmanager::Server.find_by(id: params[:id])
        data = server_params
        
        server.user_id = data[:user_id]
        server.hostname = data[:hostname]
        server.discourse_api_key = data[:discourse_api_key]
        server.do_api_key = data[:do_api_key]
        server.mg_api_key = data[:mg_api_key]
        server.maxmind_license_key = data[:maxmind_license_key]
        server.inventory =  data[:inventory]
        server.save
        
        if server.errors.present?
          return render_json_error(server.errors.full_messages)
        else
          return render json: success_json
        end
      end
      
      render json: failed_json
    end
    
    def server_params
      params.require(:server).permit(
        :user_id,
        :hostname,
        :do_api_key,
        :mg_api_key,
        :maxmind_license_key,
        :discourse_api_key
      )
    end
  end
end
