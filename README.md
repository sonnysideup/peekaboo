# Peekaboo: Unobtrusive method tracing for Ruby classes

Do you find yourself constantly adding log statements to a lot of the methods in your project?
Does it lead to a lot of duplication and make your code feel less "elegant"?
Peekaboo offers an alternative approach to tracing method calls, their provided arguments, and their return values.
Simply specify which methods you want to trace inside a class and let peekaboo take care of the rest.

## Installation and usage

Gem:

    $ gem install peekaboo

### How it works:

Peekaboo uses method wrapping and an internal tracer to capture the data you want to know about your methods.
Its tracer adheres to the API established by the Logger class ( i.e. debug, info, warn, etc... ).
For now, the only trace level supported is "info", but there are plans to support all trace levels in the future.
Also, this first cut only provides tracing for _instance_ methods.

When creating a new class, include Peekaboo and then call `enable_tracing_on`, passing it a list of method names to trace.

    class Example
      include Peekaboo
      enable_tracing_on :foo, :bar
      
      def foo
        ...
      end
      
      def bar
        ...
      end
    end

Sometimes you may want to trace methods in a class that has already been created.
In that case, simply reopen the class definition and follow the same steps listed above.

    # Example class already exists with instance methods #baz and #bif defined
    
    class Example
      include Peekaboo
      enable_tracing_on :baz, :bif
    end

Now, with tracing enabled, Peekaboo will report when/where those methods are called along with their input and output values.

    # @obj is an instance of Example
    # Peekaboo tracer receives the following message when #baz is called below:
    #   "File:Line ( Example#baz called with [:one, 2, "three"] ==> Returning: 'whatever gets returned' )"
    
    @obj.baz :one, 2, "three"

## Configuration

The default tracer for Peekaboo is an instance of `Logger` streaming to `STDOUT`.
If this doesn't suit your needs, it is a trivial task to set the tracer to another object using the Peekaboo configuration.

    Peekaboo.configure do |config|
      # file-based logging
      config.trace_with Logger.new("some_file")
      
      # inside Rails
      config.trace_with Rails.logger
      
      # any object that responds to debug, info, warn, error, fatal, unknown
      config.trace_with @custom_logger_object
    end

## Issues

Please report any bugs or issues to the [Issue Tracking System](http://github.com/sgarcia/peekaboo/issues/).

## Development

If you have any feature requests or ideas feel free to contact me directly.
If you're looking to contribute please read the contribution guidelines before submitting patches or pull requests.

## License

Copyright (c) 2009 Sonny Ruben Garcia

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
