$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'ruby-debug'
require 'tempfile'
require 'spec'
require 'spec/autorun'

require 'peekaboo'

Spec::Runner.configure do |config|
  def new_test_class
    Class.new do
      def method_no_tracing
      end

      def method_no_args
      end

      def method_one_arg arg1
      end

      def method_two_args arg1, arg2
      end

      def method_optional_args optional = 'default'
      end

      def method_variable_args *args
      end

      def method_raises
        raise 'something went wrong'
      end
    end
  end
  
  def trace_message contents, offset = 1
    file_and_line = caller(1)[0]
    file, line = file_and_line.split(':')
    line = line.to_i + offset
    "#{file}:#{line}\n\t( #{contents} )"
  end
end
