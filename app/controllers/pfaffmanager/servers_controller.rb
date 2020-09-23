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
  end
end
