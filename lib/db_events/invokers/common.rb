module DbEvents
  module Invokers
    class Common
      attr_accessor :distributors, :snapshot, :provider

      def initialize
        @distributors = []
      end
    end
  end
end

