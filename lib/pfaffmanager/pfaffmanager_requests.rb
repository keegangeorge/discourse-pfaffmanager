# frozen_string_literal: true

module PfaffmanagerRequests
    def self.request
        @request ||= Enum.new(rebuild: 0,
                                 install: 1
                                )
    end
      def self.status
        @status ||= Enum.new(started: 0,
                                complete: 1
                                )
      end
    end
