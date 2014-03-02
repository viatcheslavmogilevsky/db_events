require 'db_events/invokers/common'

module DbEvents
  module Invokers
    class Inline < DbEvents::Invokers::Common
      def invoke!
        @distributors.each {|d| d.invoke(@snapshot)}
      end
    end
  end
end