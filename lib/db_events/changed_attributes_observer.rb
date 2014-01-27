module DbEvents
  module ChangedAttributesObserver
    extend ActiveSupport::Concern
    included do
      before_update :remember_changed_attrs
    end

    def changed_attrs
      @changed_attrs || []
    end

    private

    def remember_changed_attrs
      @changed_attrs = self.changed
    end
  end
end