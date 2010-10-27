require File.expand_path('../../spec_helper', __FILE__)

describe Peekaboo::Configuration do
  
  before(:each) do
    @config = Peekaboo::Configuration.new
  end
  
  context "autoinclusion" do
    it "should not reference any class by default" do
      @config.autoincluded.should be_empty
    end
    
    it "should raise an exception when trying to add a non-class objects" do
      lambda {
        [ [Object.new], ["", Hash] ].each { |object_list| @config.autoinclude_with *object_list }
      }.should raise_exception("Auto-inclusion can only be used with classes")
    end
    
    it "should allow class objects to be added" do
      lambda {
        [ [Object], [Object, Hash], [Class.new, String, Array] ].each { |klass_list| @config.autoinclude_with *klass_list }
      }.should_not raise_exception
    end
    
    it "should maintain a list of classes to use" do
      @config.autoinclude_with Array, String, Hash
      @config.autoincluded.should =~ [ Array, String, Hash ]
    end
    
    it "should ensure its list of classes is unique" do
      @config.autoinclude_with Array, Hash, Array, Hash
      @config.autoincluded.should =~ [ Hash, Array ]
    end
    
    it "should auto-include Peekaboo into any class in its list" do
      test_class = new_test_class
      @config.autoinclude_with test_class
      lambda { test_class.enable_tracing_on }.should_not raise_exception
    end
    
    it "should auto-include Peekaboo into any class that inherits from a class in its list" do
      parent_class = new_test_class
      child_class = Class.new(parent_class)
      @config.autoinclude_with parent_class
      lambda { child_class.enable_tracing_on }.should_not raise_exception
    end
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
