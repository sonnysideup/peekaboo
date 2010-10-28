require 'logger'
require 'set'

module Peekaboo
  class Configuration
    
    TRACE_LEVELS = [ :debug, :info, :warn, :error, :fatal, :unknown ]
    
    def initialize
      @autoincluded = Set.new
    end
    
    def autoincluded
      @autoincluded.to_a
    end
    
    def autoinclude_with *klasses
      if klasses.all? { |klass| klass.instance_of? Class }
        @autoincluded.merge klasses
        
        autoincluded.each do |klass|
          next if klass.included_modules.include? Peekaboo.to_s
          Peekaboo.setup_autoinclusion klass
        end
      else
        raise 'Auto-inclusion can only be used with classes'
      end
    end
    
    def tracer
      @tracer ||= Logger.new STDOUT
    end
    
    def trace_with tracer
      if TRACE_LEVELS.all? { |level| tracer.respond_to? level }
        @tracer = tracer
      else
        raise 'Tracer must respond to debug(), info(), warn(), error(), fatal(), and unknown()'
      end
    end
    
  end
end
