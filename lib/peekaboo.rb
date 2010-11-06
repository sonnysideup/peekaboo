require 'peekaboo/configuration'
require 'peekaboo/singleton_methods'

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
      klass.const_set :PEEKABOO_METHOD_MAP, { :singleton_methods => Set.new, :instance_methods => Set.new }.freeze
      klass.instance_variable_set :@_hooked_by_peekaboo, true
      klass.extend SingletonMethods
      
      def klass.method_added name
        Peekaboo.wrap self, name, :instance if traced_instance_methods.include? name
      end
      
      def klass.singleton_method_added name
        Peekaboo.wrap self, name, :singleton if traced_singleton_methods.include? name
      end
    end
    
    # Modifies a class, and its child classes, to dynamically include module
    # at runtime. This method is used by {Configuration#autoinclude_with}.
    #
    # @param [Class] klass class to modify
    def setup_autoinclusion klass
      # @note changes made to this methods to support backwards
      # compatibility with {#enable_tracing_on}. This will become
      # much simpler when that method is removed.
      def klass.method_missing(method_name, *args, &block)
        if method_name.to_s =~ /^enable_tracing_(on|for)$/
          instance_eval { include Peekaboo }
          __send__ method_name, *args
        else
          super
        end
      end
    end
    
    # @todo document
    def wrap klass, method_name, target
      return if @_adding_a_method
      begin
        @_adding_a_method = true
        original_method = "original_#{method_name}"
        case target
        when :singleton then wrap_singleton_method klass, method_name, original_method
        when :instance  then wrap_instance_method klass, method_name, original_method
        else raise 'Only :class and :instance are valid targets'
        end
      rescue => exe
        raise exe
      ensure
        @_adding_a_method = false
      end
    end
    
    private
    
    # @todo document
    def wrap_instance_method klass, method_name, original_method_name
      method_wrapping = %{
        alias_method :#{original_method_name}, :#{method_name}
        def #{method_name} *args, &block
          trace = "\#{caller(1)[0]}\n\t( Invoking: #{klass}\##{method_name} with \#{args.inspect} "
          begin
            result = #{original_method_name} *args, &block
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
    end
    
    # @todo document
    def wrap_singleton_method klass, method_name, original_method_name
      method_wrapping = %{
        class << self
          alias_method :#{original_method_name}, :#{method_name}
          def #{method_name} *args, &block
            trace = "\#{caller(1)[0]}\n\t( Invoking: #{klass}\##{method_name} with \#{args.inspect} "
            begin
              result = #{original_method_name} *args, &block
              trace << "==> Returning: \#{result.inspect} )"
              result
            rescue Exception => exe
              trace << "!!! Raising: \#{exe.message.inspect} )"
              raise exe
            ensure
              Peekaboo.configuration.tracer.info trace
            end
          end
        end
      }
      klass.instance_eval method_wrapping
    end
  end
end
