require 'active_support'
require 'db_events/changed_attributes_observer'
require 'db_events/configuration'

module DbEvents
  module Wrappers
    module ActiveRecord
      extend ActiveSupport::Concern
      include DbEvents::ChangedAttributesObserver

      module ClassMethods
        def last_changes_provider
          DbEvents::Configuration.provider_at(self.to_s)
        end

        def refresh_db_events_callbacks!(callback_type=:commit)
          if @db_events_initialized
            _on_actions do |action|
              method_name = "send_#{action}_notification".to_sym
              skip_callback(:commit, :after, method_name)
              skip_callback(action, :after, method_name)
            end
          end

          _on_actions do |action|
            case callback_type
            when :commit
              set_callback(:commit, :after, "send_#{action}_notification".to_sym, on: action)
            when :after
              set_callback(action, :after, "send_#{action}_notification".to_sym)
            end
          end

          @db_events_initialized = true
        end

      private
        def _on_actions
          [:update, :destroy, :create].each do |action_name|
            yield(action_name)
          end
        end
      end

      def send_update_notification; send_notifications('update'); end
      def send_create_notification; send_notifications('create'); end
      def send_destroy_notification; send_notifications('destroy'); end

      def send_notifications(action_type)
        return if new_record?
        self.class.last_changes_provider.try(:observe, self, action_type)
      end

      def inline_send(action_type, receiver_ids)
        hash = {'id' => self.id, 'action' => action_type}.merge({'info' => self.attributes})
        self.class.last_changes_provider.direct_distributors.each do |distr|
          distr.invoke(hash, receiver_ids)
        end
      end

      def hash_template(action)
        {
          'id' => id, 
          'action' => action, 
          'info' => self.attributes.merge('_changed' => self.changed_attrs)
        }
      end
    end
  end
end