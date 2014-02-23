require 'db_events/class_provider'

module DbEvents
  class Configuration
    class << self
      attr_accesor :default_scope

      def configure
        @providers ||= {}
        yield(self)
      end
      
      def at_class class_name
        yield(provider_at(class_name, true))
      end

      def provider_at class_name, force=false
        if force
          @providers[class_name] ||= ClassProvider.new(self, class_name)
        else
          @providers[class_name]
        end
      end
    end
  end
end