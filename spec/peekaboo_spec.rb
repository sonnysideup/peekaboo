require File.expand_path('../spec_helper', __FILE__)

describe Peekaboo do

  context ".configuration" do
    it "should hold a reference to the current configuration" do
      Peekaboo.configuration.should be_an_instance_of Peekaboo::Configuration
    end
  end
  
  context ".configure" do
    it "should yield the current configuration" do
      yielded_object = nil
      Peekaboo.configure { |x| yielded_object = x }
      Peekaboo.configuration.should == yielded_object
    end
  end
  
  context ".enable_tracing_for" do
    before(:each) do
      @test_class = new_test_class
      @test_class.instance_eval { include Peekaboo }
    end
    
    it "should be a singleton method added to any including class" do
      @test_class.should respond_to :enable_tracing_for
    end
    
    it "should store a list of methods to trace on any including class" do
      methods_to_trace = [:method_no_args, :method_one_arg]
      @test_class.enable_tracing_for *methods_to_trace
      @test_class::PEEKABOO_METHOD_LIST.should == methods_to_trace
    end
    
    it "should raise an exception when trying to add a method that is already being traced" do
      @test_class.enable_tracing_for :some_method
      lambda {
        @test_class.enable_tracing_for :some_method
      }.should raise_exception "Already tracing `some_method'"
    end
  end
  
  context "instance method tracing" do
    before(:all) do
      @test_class = new_test_class
      @test_class.instance_eval do
        include Peekaboo
        enable_tracing_for :method_no_args, :method_one_arg, :method_two_args, :method_optional_args, :method_variable_args, :method_raises
      end
      
      @test_instance = @test_class.new
      @tracer = Peekaboo.configuration.tracer
    end
    
    it "should not take place on unlisted methods" do
      @tracer.should_not_receive :info
      @test_instance.method_no_tracing
    end
    
    it "should show listed methods with no arguments" do
      @tracer.should_receive(:info).with trace_message "Invoking: #{@test_class}#method_no_args with [] ==> Returning: nil"
      @test_instance.method_no_args
    end
    
    it "should show listed methods with standard arguments" do
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_one_arg with ["one"] ==> Returning: nil}
      @test_instance.method_one_arg 'one'
      
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_two_args with ["one", "two"] ==> Returning: nil}
      @test_instance.method_two_args 'one', 'two'
    end
    
    it "should show methods with optional arguments" do
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_optional_args with [] ==> Returning: nil}
      @test_instance.method_optional_args
      
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_optional_args with ["override"] ==> Returning: nil}
      @test_instance.method_optional_args 'override'
    end
    
    it "should show methods with variable arguments" do
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_variable_args with [] ==> Returning: nil}
      @test_instance.method_variable_args
      
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_variable_args with ["one"] ==> Returning: nil}
      @test_instance.method_variable_args 'one'
      
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_variable_args with ["one", "two"] ==> Returning: nil}
      @test_instance.method_variable_args 'one', 'two'
    end
    
    it "should show methods that raise an exception" do
      @tracer.should_receive(:info).
        with trace_message %{Invoking: #{@test_class}#method_raises with [] !!! Raising: "something went wrong"}
      lambda { @test_instance.method_raises }.should raise_exception
    end
  end
  
  context "autoinclusion tracing" do
    before(:all) do
      @tracer = Peekaboo.configuration.tracer
    end
    
    it "should inject functionality into an auto-included class" do
      test_class = new_test_class
      Peekaboo.configure { |config| config.autoinclude_with test_class }
      test_class.enable_tracing_for :method_no_args
      
      @tracer.should_receive(:info).with trace_message "Invoking: #{test_class}#method_no_args with [] ==> Returning: nil"
      test_class.new.method_no_args
    end
    
    it "should inject functionality into any class that inherits from an auto-included class" do
      parent_class = new_test_class
      child_class = Class.new(parent_class) do
        def another_method() ; end
      end
      
      Peekaboo.configure { |config| config.autoinclude_with parent_class }
      child_class.enable_tracing_for :another_method

      @tracer.should_receive(:info).with trace_message "Invoking: #{child_class}#another_method with [] ==> Returning: nil"
      child_class.new.another_method
    end
    
    it "should not inject functionality into classes that are not auto-included" do
      test_class         = new_test_class
      another_test_class = new_test_class
      
      Peekaboo.configure { |config| config.autoinclude_with test_class }
      
      lambda { another_test_class.enable_tracing_for :method_no_args }.should raise_exception NoMethodError
    end
    
    it "should maintain unique tracing method lists across an inheritance chain" do
      parent_class = new_test_class
      child_class = Class.new(parent_class) do
        def another_method() ; end
      end
      
      Peekaboo.configure { |config| config.autoinclude_with parent_class }
      
      parent_class.enable_tracing_for :method_no_args
      child_class.enable_tracing_for :another_method
      
      parent_class.peek_list.should =~ [:method_no_args]
      child_class.peek_list.should  =~ [:another_method]
    end
  end
  
end
