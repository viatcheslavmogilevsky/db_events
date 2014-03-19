require 'db_events/callback_distributor'
require 'db_events/queueing'
#require 'db_events/provider_observing'

module DbEvents  
  class ClassProvider
    include DbEvents::Queueing
    attr_reader :origin, :distributors, :direct_distributors, :inserted_distributors
    alias :configuration :origin

    def initialize(origin, class_name)
      @origin, @class_name = origin, class_name

      @distributors = []
      @distributors_references = {}
      @direct_distributors = []
      @inserted_distributors = {}
    end

    def add_distributor(options={})
      current_distributor = DbEvents::CallbackDistributor.new(self)
      current_distributor.extend(options[:distribution_type] || DbEvents::Distributions::DirectDistribution)
      current_distributor.parent_node = options[:parent_node]

      yield current_distributor

      @distributors << current_distributor
      
      if current_distributor.kind_of?(DirectDistribution)
        @direct_distributors << current_distributor 
      end

      if options[:parent_class_name].present?
        @inserted_distributors[options[:parent_class_name]] = current_distributor
      end

      current_distributor.id = options[:as] || "id#{@distributors.count}".to_sym
      @distributors_references[current_distributor.id] = current_distributor
    end

    def get_distributor(id)
      @distributors_references[id]
    end

    def name
      @class_name
    end

    def observe(model, action_type=nil)
      invoker = configuration.invoker_class.new
      invoker.provider = self
      invoker.distributors = @distributors.select do |d|
        d.should_be_invoked?(model, action_type)
      end
      invoker.snapshot = model.dbe_snapshot.merge('action' => action_type)
      invoker.invoke!
    end
  end
end