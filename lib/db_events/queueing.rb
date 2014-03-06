module DbEvents
  module Queueing
    def enqueue(performer_class, options={})
      @dbe_performers ||= []
      @dbe_performers << performer_class.new(options)
    end

    def run_performers(sender, message, receivers=nil)
      if @dbe_performers
        @dbe_performers.each {|d| d.perform(sender, message, receivers)}
      end
    end
  end
end