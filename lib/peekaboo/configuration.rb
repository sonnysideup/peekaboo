require 'logger'

module Peekaboo
  class Configuration
    
    TRACE_LEVELS = [ :debug, :info, :warn, :error, :fatal, :unknown ]
    
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
