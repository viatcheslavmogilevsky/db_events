module DbEvents
  module Distributions
    module DirectDistribution
      def invoke(instance_data, receivers=nil)
        write_on_redis!(instance_data.merge({'class_name' => @class_name}), receivers)
      end

      def invoke_for_instance(model, action)
        invoke({'id' => model.id, 'action' => action, 'info' => model.attributes})
      end
    end

    module InsertedDistribution
      def invoke(instance_data)
        info = instance_data['info']
        receivers(info).each { |receiver| @parent_node.invoke_for_instance(receiver, 'update') }
      end
    end
  end

  class CallbackDistributor
    attr_accessor :render_options, :kind,
      :strategy, :class_name, :permission_class_name,
      :id, :parent_node, :template, :scopes
    attr_reader :origin_class_name

    def initialize(provider)
      @provider = provider
      @class_name = provider.name
      @origin_class_name = provider.name
      @condition_defined = false
      @promoters_defined = false
      @scopes = []
    end

    # def define_receivers(&blk)
    #   define_singleton_method :receivers, &blk
    # end

    # def define_receivers_per_permission(&blk)
    #   define_singleton_method :receivers_per_permission, &blk
    # end

    # def define_promoters(&blk)
    #   @promoters_defined = true
    #   define_singleton_method :promoters_condition, &blk
    # end

    def define_condition(&blk)
      @condition_defined = true
      define_singleton_method :invoke_condition, &blk
    end

    def should_be_invoked?(model, action)
      return true unless @condition_defined
      invoke_condition(model, action)
    end

    def include_with(class_name)
      target_provider = @provider.origin.provider_at(class_name, true)

      if self.kind_of?(DbEvents::Distributions::InsertedDistribution)
        target_node = @parent_node
        target_parent_class_name = @parent_node.origin_class_name
      else
        target_node = self
        target_parent_class_name = @origin_class_name
      end

      target_provider.add_distributor(
        distribution_type: DbEvents::Distributions::InsertedDistribution,
        parent_class_name: target_parent_class_name,
        parent_node: target_node) do |distr|
        yield(distr)
      end
    end

    def redis_key_name
      @template ? "#{@class_name}:#{@template}" : @class_name
    end

    def get_timestamp
      (Time.zone.now.to_f*1000).to_i
    end

    def user_context
      #User.by_current_company.with_permissions_and_venues
      @provider.configuration.default_scope
    end

    # def build_query(instance_data)
    #   permission_scope.map do |p|
    #     {permission_levels_permissions: {permission_id: p.id}} & receivers_per_permission(p, instance_data)
    #   end.reduce(:|)
    # end

    # def permission_scope
    #   Permission.masks_by_class(@permission_class_name || @class_name)
    # end

    # def through_permissions(instance_data)
    #   user_context.where(build_query(instance_data))
    # end

    # def promoter_disjunct(instance_data)
    #   {users: {type: "Promoter"}.merge(promoters_condition(instance_data))}
    # end

    def expand_model_hash!(model_hash)
      unless model_hash['action'] == 'destroy'
        target_scope = @origin_class_name.constantize.unscoped
        @scopes.each {|scope| target_scope = target_scope.send(scope)}
        model_hash['data'] = target_scope.find(model_hash['id']).send(*@render_options.flatten)
      end
    end
  end
end