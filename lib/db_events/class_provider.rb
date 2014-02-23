require 'db_events/callback_distributor'
require 'db_events/provider_observing'

module DbEvents  
  class ClassProvider
    attr_reader :origin, :distributors, :direct_distributors, :inserted_distributors

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

    def observe(model, action_type)
      observing = DbEvents::ProviderObserving.new(self)
      observing.model, observing.action_type = model, action_type
      observing.select_distributors!
      observing.enqueue_worker
    end
  end
end