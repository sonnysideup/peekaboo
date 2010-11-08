require 'peekaboo/configuration'
require 'peekaboo/singleton_methods'

# This system has been designed to provide you with an easy and unobtrusive way to trace:
# * _When_ certain methods are being called
# * _What_ values they are being supplied
# * _What_ values they return
# * _If_ they raise an exception
#
# Its API supports both class and instance method tracing inside any of your custom types.
# You can enable tracing for existing methods and/or pre-register method signatures for any of your types.
# The latter option gives you the ability to trace any methods that are defined _dynamically_ at runtime.
#
# ( see {SingletonMethods#enable_tracing_for} for details )
#
# You can also setup *auto-inclusion*, which will allow you _dynamically_ include this module into any of
# your types at runtime. This alleviates the hassle of having to "+include Peekaboo+" inside all of the
# classes that you intend use it.
#
# ( see {Configuration#autoinclude_with} for details )
module Peekaboo
  class << self
    # @private
    def configuration
      @configuration ||= Configuration.new
    end
    
    # Use this to configure various aspects of tracing in your application.
    #
    # See {Configuration} for option details.
    # @yieldparam [Configuration] config current configuration
    def configure
      yield configuration
    end
    
    # @private
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
    
    # @private
    def setup_autoinclusion klass
      def klass.method_missing(method_name, *args, &block)
        if method_name.to_s =~ /^enable_tracing_for$/
          instance_eval { include Peekaboo }
          enable_tracing_for *args
        else
          super
        end
      end
    end
    
    # @private
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
    
    def wrap_singleton_method klass, method_name, original_method_name
      method_wrapping = %{
        class << self
          alias_method :#{original_method_name}, :#{method_name}
          def #{method_name} *args, &block
            trace = "\#{caller(1)[0]}\n\t( Invoking: #{klass}.#{method_name} with \#{args.inspect} "
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
