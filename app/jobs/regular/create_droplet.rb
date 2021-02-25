# frozen_string_literal: true

module Jobs

  class CreateDroplet < ::Jobs::Base
    sidekiq_options retry: false

    def execute(args)
      puts "createDroplet.execute_onceoff starting..."
      Rails.logger.warn("createDroplet.execute_onceoff starting...")

      puts "createDroplet.execute_onceoff looking for #{args[:server_id]}"
      server = Pfaffmanager::Server.find(args[:server_id])
      puts "createDroplet.execute_onceoff found #{server.hostname}"
      server.create_droplet
      puts "createDroplet.execute_onceoff done"
      server
    end
  end

end
