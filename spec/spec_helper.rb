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
    file, line, method = CallChain.parse_caller(caller(1).first)
    line += offset
    
    if RUBY_VERSION < '1.9'
      "#{file}:#{line}\n\t( #{contents} )"
    else
      "#{file}:#{line}:in `#{method}'\n\t( #{contents} )"
    end
  end
  
  class CallChain
    def self.parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file   = Regexp.last_match[1]
        line   = Regexp.last_match[2].to_i
        method = Regexp.last_match[3]
        [file, line, method]
      end
    end
  end
end
