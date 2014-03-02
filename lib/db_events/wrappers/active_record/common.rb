require 'db_events/configuration'
require 'active_record'

module DbEvents
  module Wrappers
    module ActiveRecord
      module Common
        def send_update_notification;  send_notifications('update');  end
        def send_create_notification;  send_notifications('create');  end
        def send_destroy_notification; send_notifications('destroy'); end

        def send_notifications(action_type)
          return if new_record?
          provider = DbEvents::Configuration.provider_at(self.class.to_s)
          provider.try(:observe, self, action_type)
        end

        def dbe_snapshot
          {'id' => id, 'attributes' => attributes}
        end
      end
    end
  end
end