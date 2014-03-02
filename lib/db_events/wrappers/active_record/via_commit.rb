require 'active_support'
require 'db_events/wrappers/active_record/commom'

module DbEvents
  module Wrappers
    module ActiveRecord
      module ViaCommit
        extend ActiveSupport::Concern
        include DbEvents::Wrappers::ActiveRecord::Commom

        included do
          after_commit :send_update_notification,  on: :update
          after_commit :send_destroy_notification, on: :destroy
          after_commit :send_create_notification,  on: :create
        end

        def dbe_snapshot
          super.merge 'changed' => previous_changes.keys
        end        
      end
    end
  end
end