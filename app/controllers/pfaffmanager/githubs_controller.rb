# frozen_string_literal: true
module Pfaffmanager
  class GithubsController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in

    def index
      render_json_dump({ githubs: [] })
    end

    def show
      render_json_dump({ github: { id: params[:id] } })
    end
  end
end
