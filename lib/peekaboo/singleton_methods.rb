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
    
    private
    
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
    
    
    #################### DEPRECATED ####################
    
    
    public
    
    # @return [Array<Symbol>]
    #   a list of instance methods that are being traced inside calling class
    # @deprecated
    #   this method will be removed in version 0.4.0, use {#traced_method_map} instead
    def peek_list
      self::PEEKABOO_METHOD_LIST
    end
    
    # Enables instance method tracing on calling class.
    #
    # @example Trace a couple of methods
    #   class SomeClass
    #     include Peekaboo
    #
    #     def method1; end
    #     def method2; end
    #     def method3; end
    #   end
    #
    #   # Tracing will be performed on method1(), method2(), but NOT method3()
    #   SomeClass.enable_tracing_on :method1, :method2
    #
    # @param [*Symbol] method_names
    #   the list of methods that you want to trace
    # @raise [RuntimeError]
    #   when attempting to add a method that is already being traced
    # @deprecated
    #   this method will be removed in version 0.4.0, use {#enable_tracing_for} instead
    def enable_tracing_on *method_names
      include Peekaboo unless @_hooked_by_peekaboo
      
      method_names.each do |method_name|
        unless peek_list.include? method_name
          peek_list << method_name
          method_list = self.instance_methods(false).map(&:to_sym)
          Peekaboo.wrap self, method_name, :instance if method_list.include? method_name
        else
          raise "Already tracing `#{method_name}'"
        end
      end
    end
  end
end