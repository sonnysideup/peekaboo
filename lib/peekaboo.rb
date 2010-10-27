require 'peekaboo/configuration'

module Peekaboo
  
  class << self
    def configuration
      @configuration ||= Configuration.new
    end
    
    def configure
      yield configuration
    end
    
    def included klass
      klass.const_set :PEEKABOO_METHOD_LIST, []
      klass.instance_variable_set :@_hooked_by_peekaboo, true
      klass.extend SingletonMethods
      
      def klass.method_added name
        Peekaboo.wrap_method self, name if peek_list.include? name
      end
    end
    
    # @note Should I add execution time to logs?
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
  
  module SingletonMethods
    def peek_list
      self::PEEKABOO_METHOD_LIST
    end
    
    def enable_tracing_on *method_names
      include Peekaboo unless @_hooked_by_peekaboo
      
      method_names.each do |method_name|
        unless peek_list.include? method_name
          peek_list << method_name
          Peekaboo.wrap_method self, method_name if self.instance_methods(false).include? method_name.to_s
        else
          raise "Already tracing `#{method_name}'"
        end
      end
    end
  end
end
