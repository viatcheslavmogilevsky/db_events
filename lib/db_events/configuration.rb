require 'db_events/class_provider'
require 'db_events/invokers/inline'
require 'db_events/queueing'
#require 'db_events/'

module DbEvents
  class Configuration
    extend DbEvents::Queueing
    class << self
      attr_accessor :default_scope
      attr_writer :invoker_class

      def configure
        @providers ||= {}
        yield(self)
      end
      
      def at_class class_name
        yield(provider_at(class_name, true))
      end

      def provider_at class_name, force=false
        if force
          @providers[class_name] ||= DbEvents::ClassProvider.new(self, class_name)
        else
          @providers[class_name]
        end
      end

      def invoker_class
        @invoker_class || DbEvents::Invokers::Inline
      end
    end
  end
end