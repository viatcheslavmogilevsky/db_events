require 'active_support'
require 'db_events/wrappers/active_record/commom'

module DbEvents
  module Wrappers
    module ActiveRecord
      module Test
        extend ActiveSupport::Concern
        include DbEvents::Wrappers::ActiveRecord::Commom

        included do
          after_create  :send_create_notification
          after_save    :send_update_notification
          after_destroy :send_destroy_notification
        end

        def dbe_snapshot
          super.merge 'changed' => changed
        end        
      end
    end
  end
end