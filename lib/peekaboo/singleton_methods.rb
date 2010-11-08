module Peekaboo
  # Contains methods added to every class that includes the
  # {Peekaboo} module, either by _direct_ or _auto_ inclusion.
  module SingletonMethods
    # Provides access to traced methods.
    #
    # @example
    #   CustomType.traced_method_map # => {:instance_methods=>#<Set: {:foo}>, :singleton_methods=>#<Set: {:bar}>}
    #
    # @return [Hash] all methods registered for tracing
    def traced_method_map
      self::PEEKABOO_METHOD_MAP
    end
    
    # Provides convenient access to traced instance methods.
    #
    # @example
    #   CustomType.traced_instance_methods # => #<Set: {:foo}>
    #
    # @return [Set<Symbol>] all instance methods registered for tracing
    def traced_instance_methods
      traced_method_map[:instance_methods]
    end
    
    # Provides convenient access to traced singleton methods.
    #
    # @example
    #   CustomType.traced_singleton_methods # => #<Set: {:bar}>
    #
    # @return [Set<Symbol>] all singleton methods registered for tracing
    def traced_singleton_methods
      traced_method_map[:singleton_methods]
    end
    
    # Enables singleton and instance method tracing. If the _method-to-trace_
    # is not currently defined in the calling class, *Peekaboo* will register
    # that signature so that tracing is enabled at the time it is added.
    #
    # @example Tracing singleton methods
    #   CustomType.enable_tracing_for :singleton_methods => [:a, :b, :c]
    # @example Tracing instance methods
    #   CustomType.enable_tracing_for :instance_methods => [:one, :two, :three]
    # @example Tracing a mix of methods
    #   CustomType.enable_tracing_for :singleton_methods => [:this, :that],
    #                                 :instance_methods  => [:the_other]
    #
    # @param [Hash] method_map a list of methods to trace
    # @option method_map [Array<Symbol>] :singleton_methods ([]) singleton method list
    # @option method_map [Array<Symbol>] :instance_methods  ([]) instance method list
    def enable_tracing_for method_map
      include Peekaboo unless @_hooked_by_peekaboo
      
      method_map = { :singleton_methods => [], :instance_methods => [] }.merge method_map
      
      _register_traceables_ method_map[:instance_methods],  :instance
      _register_traceables_ method_map[:singleton_methods], :singleton
    end
    
    # Removes singleton and instance method tracing. This can be called in
    # exactly the same fashion as {#enable_tracing_for enable_tracing_for}.
    #
    # @param [Hash] method_map a list of methods to trace
    # @option method_map [Array<Symbol>] :singleton_methods ([]) singleton method list
    # @option method_map [Array<Symbol>] :instance_methods  ([]) instance method list
    def disable_tracing_for method_map
      method_map = { :singleton_methods => [], :instance_methods => [] }.merge method_map
      
      _unregister_traceables_ method_map[:instance_methods],  :instance
      _unregister_traceables_ method_map[:singleton_methods], :singleton
    end
    
    private
    
    # Hooks tracing for instance methods added after registration.
    #
    # @param [Symbol] name method name
    def method_added name
      Peekaboo.wrap self, name, :instance if traced_instance_methods.include? name
    end
    
    # Hooks tracing for singleton methods added after registration.
    #
    # @param [Symbol] name method name
    def singleton_method_added name
      Peekaboo.wrap self, name, :singleton if traced_singleton_methods.include? name
    end
    
    # Registers a list of method signatures and optionally enables tracing on them.
    # Tracing will only be "enabled" if the method exists and has not already been registered.
    #
    # @param [Array<Symbol>] method_list methods to register
    # @param [Symbol] target specifies the receiver, either +:singleton+ or +:instance+
    def _register_traceables_ method_list, target
      method_list.each do |method_name|
        target_method_list = __send__ :"traced_#{target}_methods"
        
        unless target_method_list.include? method_name
          target_method_list << method_name
          existing_methods = self.__send__(:"#{target}_methods", false).map(&:to_sym)
          Peekaboo.wrap self, method_name, target if existing_methods.include? method_name
        end
      end
    end
    
    # Unregisters a list of method signatures and optionally disables tracing on them.
    # Tracing will only be "disabled" if the method exists and was previously being traced.
    #
    # @param [Array<Symbol>] method_list methods to register
    # @param [Symbol] target specifies the receiver, either +:singleton+ or +:instance+
    def _unregister_traceables_ method_list, target
      method_list.each do |method_name|
        target_method_list = __send__ :"traced_#{target}_methods"
        
        if target_method_list.include? method_name
          target_method_list.delete method_name
          existing_methods = self.__send__(:"#{target}_methods", false).map(&:to_sym)
          Peekaboo.unwrap self, method_name, target if existing_methods.include? method_name
        end
      end
    end
  end
end
