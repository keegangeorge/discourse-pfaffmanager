# frozen_string_literal: true
module Pfaffmanager
  class PfaffmanagerController < ::ApplicationController
    requires_plugin Pfaffmanager

    before_action :ensure_logged_in

    def index
    end
  end
end
