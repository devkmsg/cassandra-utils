# FIXME: When this gem is published uncomment this line
#require 'daemon_runner'

module Cassandra
  module Utils
    class Daemon < ::DaemonRunner::Client

      def tasks
        [
          [::Cassandra::Utils::Stats::Compaction.new, 'run!']
        ]
      end
    end
  end
end
