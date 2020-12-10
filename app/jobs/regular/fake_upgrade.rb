# frozen_string_literal: true

module Jobs
  class FakeUpgrade < ::Jobs::Base
    sidekiq_options queue: 'critical'
    def execute(args)
      s = Pfaffmanager::Server.find(args[:server_id])
        for x in 1..5
          s.request_status = "Stage #{x}"
          s.save
          sleep 0.5
        end
        s.request_result = 'ok'
        s.request_status = 'Success'
        s.save
    end
  end
end
