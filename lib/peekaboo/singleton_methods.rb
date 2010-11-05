module Peekaboo
  # Contains methods added to every class that includes the *Peekaboo* module,
  # either through _direct_ or _auto_ inclusion.
  module SingletonMethods
    # @todo document
    def traced_method_map
      self::PEEKABOO_METHOD_MAP
    end
    
    # @todo document
    def traced_singleton_methods
      traced_method_map[:singleton_methods]
    end
    
    # @todo document
    def traced_instance_methods
      traced_method_map[:instance_methods]
    end
    
    # @todo document
    def enable_tracing_for method_map
      include Peekaboo unless @_hooked_by_peekaboo
      
      method_map = { :singleton_methods => [], :instance_methods => [] }.merge method_map
      
      _enable_tracing_ method_map[:instance_methods], :instance
      _enable_tracing_ method_map[:singleton_methods], :singleton
    end
    
    private
    
    # @todo document
    def _enable_tracing_ methods_in_question, target
      methods_in_question.each do |method_name|
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
    # @deprecated will be removed in version 0.4.0, use {#traced_method_map} instead
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
    # @deprecated will be removed in version 0.4.0, use {#enable_tracing_for} instead
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
