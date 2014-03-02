require 'db_events/invokers/common'
require 'db_events/configuration'
require 'resque'

module DbEvents
  module Invokers
    class Resque < DbEvents::Invokers::Common
      class Worker
        def self.perform(provider_name, flags, snapshot)
          provider = DbEvents::Configuration.provider_at(provider_name)
          flags.each do |flag|
            provider.get_distributor(flag.to_sym).invoke(snapshot)
          end
        end
      end

      class << self
        attr_writer :queue_name

        def queue_name
          @queue_name || :db_events
        end
      end

      def invoke!      
        Resque.enqueue_to(
          self.class.queue_name,
          Worker, 
          @provider.name, 
          @distributors.map(&:id).map(&:to_s), 
          @snapshot
        )
      end
    end
  end
end