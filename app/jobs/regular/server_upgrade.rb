# frozen_string_literal: true

module Jobs
  class ServerUpgrade < ::Jobs::Base
    sidekiq_options retry: false
    def execute(args)
      s = Pfaffmanager::Server.find(args[:server_id])
      s.run_upgrade
    end
  end
end
