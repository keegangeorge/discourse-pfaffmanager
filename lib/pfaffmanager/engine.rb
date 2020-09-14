module Pfaffmanager
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
