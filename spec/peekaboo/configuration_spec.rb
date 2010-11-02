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
      test_class1 = new_test_class
      test_class2 = new_test_class
      test_class3 = new_test_class

      lambda {
        [ [test_class1],
          [test_class1, test_class2],
          [test_class1, test_class2, test_class3]
        ].each { |klass_list| @config.autoinclude_with *klass_list }
      }.should_not raise_exception
    end
    
    it "should maintain a list of classes to use" do
      test_class1 = new_test_class
      test_class2 = new_test_class
      test_class3 = new_test_class
      
      @config.autoinclude_with test_class1, test_class2, test_class3
      @config.autoincluded.should =~ [ test_class1, test_class2, test_class3 ]
    end
    
    it "should ensure its list of classes is unique" do
      test_class1 = new_test_class
      test_class2 = new_test_class
      
      @config.autoinclude_with test_class1, test_class2, test_class1, test_class2
      @config.autoincluded.should =~ [ test_class1, test_class2 ]
    end
    
    it "should auto-include Peekaboo into any class in its list" do
      test_class = new_test_class
      @config.autoinclude_with test_class
      lambda { test_class.enable_tracing_for }.should_not raise_exception
    end
    
    it "should auto-include Peekaboo into any class that inherits from a class in its list" do
      parent_class = new_test_class
      child_class = Class.new(parent_class)
      @config.autoinclude_with parent_class
      lambda { child_class.enable_tracing_for }.should_not raise_exception
    end
  end
  
  context "tracing" do
    it "should have a default implementation" do
      @config.tracer.should_not be_nil
    end
    
    it "should maintain the 'Logger' interface by default" do
      [ :debug, :info, :warn, :error, :fatal, :unknown ].each { |logger_msg|
        @config.tracer.should respond_to(logger_msg)
      }
    end
  
    it "should use any tracer that maintains the 'Logger' interface" do
      tmp_file        = Tempfile.new 'some-log.txt'
      some_logger_obj = MyLogger = Class.new do
        def debug(msg)   ; end
        def info(msg)    ; end
        def warn(msg)    ; end
        def error(msg)   ; end
        def fatal(msg)   ; end
        def unknown(msg) ; end
      end.new
      
      tracers = [ Logger.new(tmp_file.path), some_logger_obj ]
      
      tracers.each do |some_tracer|
        @config.trace_with some_tracer
        @config.tracer.should == some_tracer
      end
      
      tmp_file.close!
    end
    
    it "should raise an exception when attempting to use an object that does not maintaint the 'Logger' interface" do
      lambda {
        @config.trace_with 'garbage object' 
      }.should raise_exception('Tracer must respond to debug(), info(), warn(), error(), fatal(), and unknown()')
    end
  end
  
end
