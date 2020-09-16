module Pfaffmanager
  class ServersController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in

    def index
      render_json_dump({ servers: [] })
    end

    def show
      render_json_dump({ server: { id: params[:id] } })
    end
  end
end
