# frozen_string_literal: true

module PfaffmanagerRequests
  def self.request
        @request ||= Enum.new(idle: 0,
            rebuild: 1,
            install: 2
                                )
    end
      def self.status
        @status ||= Enum.new(started: 0,
                                complete: 1
                                )
      end
    end
