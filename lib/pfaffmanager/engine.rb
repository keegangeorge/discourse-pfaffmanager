# frozen_string_literal: true
module Pfaffmanager
  DO_API_KEY = "do_api_key".freeze
  MG_API_KEY = "mg_api_key".freeze
  MAXMIND_LICENSE_KEY = "maxmind_license_key".freeze
  class Engine < ::Rails::Engine
    engine_name "Pfaffmanager".freeze
    isolate_namespace Pfaffmanager

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::Pfaffmanager::Engine, at: "/pfaffmanager"
      end
    end
  end
end
