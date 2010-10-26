require File.expand_path('../../spec_helper', __FILE__)

describe Peekaboo::Configuration do
  
  before(:each) do
    @config = Peekaboo::Configuration.new
  end
  
  context "#tracer (default)" do
    it "should initialize tracing" do
      @config.tracer.should_not be_nil
    end
    
    it "should adhere to the standard 'Logger' interface" do
      [ :debug, :info, :warn, :error, :fatal, :unknown ].each { |logger_msg|
        @config.tracer.should respond_to(logger_msg)
      }
    end
  end
  
  context "#trace_with" do
    it "should set a new tracer for use" do
      new_tracer = Logger.new STDOUT
      
      @config.trace_with new_tracer
      @config.tracer.should == new_tracer
    end
    
    it "should enforce that new tracer adheres to the standard 'Logger' interface" do
      lambda {
        @config.trace_with 'garbage value' 
      }.should raise_exception('Tracer must respond to debug(), info(), warn(), error(), fatal(), and unknown()')
    end
  end
  
end
