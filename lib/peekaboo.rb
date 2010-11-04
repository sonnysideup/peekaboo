require 'peekaboo/configuration'

# The workhorse of this "Unobtrusive Tracing System".
module Peekaboo
  class << self
    # @return [Configuration] the current configuration
    def configuration
      @configuration ||= Configuration.new
    end
    
    # Convenience method added to assist in configuring the system
    # ( see {Configuration} for details on all options ).
    #
    # @example Configuring the system inside your project
    #   Peekaboo.configure do |config|
    #     config.trace_with MyCustomerLogger.new
    #     config.autoinclude_with SomeBaseClass, AnotherSoloClass
    #   end
    def configure
      yield configuration
    end
    
    # Callback used to hook tracing system into any class.
    #
    # @param [Class] klass including class
    def included klass
      klass.const_set :PEEKABOO_METHOD_LIST, []
      klass.instance_variable_set :@_hooked_by_peekaboo, true
      klass.extend SingletonMethods
      
      def klass.method_added name
        Peekaboo.wrap_method self, name if peek_list.include? name
      end
    end
    
    # Modifies a class, and its child classes, to dynamically include module
    # at runtime. This method is used by {Configuration#autoinclude_with}.
    #
    # @param [Class] klass class to modify
    def setup_autoinclusion klass
      def klass.method_missing(method_name, *args, &block)
        if method_name.to_s =~ /^enable_tracing_on$/
          instance_eval { include Peekaboo }
          enable_tracing_on *args
        else
          super
        end
      end
    end
    
    # Takes a class object and method name, aliases the original method,
    # and redefines the method with injected tracing.
    #
    # @note Should I add execution time to tracing? Configurable?
    #
    # @param [Class] klass method owner
    # @param [Symbol] name method to trace
    def wrap_method klass, name
      return if @_adding_a_method
      @_adding_a_method = true
      
      original_method = "original_#{name}"
      method_wrapping = %{
        alias_method :#{original_method}, :#{name}
        def #{name} *args, &block
          trace = "\#{caller(1)[0]}\n\t( Invoking: #{klass}\##{name} with \#{args.inspect} "
          begin
            result = #{original_method} *args, &block
            trace << "==> Returning: \#{result.inspect} )"
            result
          rescue Exception => exe
            trace << "!!! Raising: \#{exe.message.inspect} )"
            raise exe
          ensure
            Peekaboo.configuration.tracer.info trace
          end
        end
      }
      klass.class_eval method_wrapping
      
      @_adding_a_method = false
    end
  end
  
  # Contains methods added to every class that includes the *Peekaboo* module,
  # either through _direct_ or _auto_ inclusion.
  module SingletonMethods
    # @return [Array<Symbol>]
    #   a list of instance methods that are being traced inside calling class
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
    def enable_tracing_on *method_names
      include Peekaboo unless @_hooked_by_peekaboo
      
      method_names.each do |method_name|
        unless peek_list.include? method_name
          peek_list << method_name
          method_list = self.instance_methods(false).map(&:to_sym)
          Peekaboo.wrap_method self, method_name if method_list.include? method_name
        else
          raise "Already tracing `#{method_name}'"
        end
      end
    end
  end
end
