# Peekaboo: Unobtrusive method tracing for Ruby classes

Do you find yourself constantly adding log statements to a lot of the methods in your project?
Does it lead to a lot of duplication and make your code feel less "elegant"?
Peekaboo offers an alternative approach to tracing method calls, their provided arguments, and their return values.
Simply specify which methods you want to trace inside a class and let peekaboo take care of the rest.

## Usage

### Installation

Install via Rubygems:

    $ gem install peekaboo

### Concept

Peekaboo uses method wrapping and an internal tracer to capture data about method calls.
Its tracer adheres to the API established by the Logger class ( i.e. debug, info, warn, etc... ).
For now, the only trace level supported is "info", but there are plans to support all trace levels in the future.

Including Peekaboo into your class definition initializes the system within the context of that class and adds
a number of class methods that can be used to create and inspect traced methods.

    require 'peekaboo'
    
    class Example
      include Peekaboo
      # ...
    end

It is also possible to enable tracing without explicitly including Peekaboo. See the ["Auto-inclusion"](#Auto-inclusion) for details.

### Method Tracing

Once Peekaboo has been enabled within a class you can call `enable_tracing_for`, inside the class definition or
directly on the class object, passing it a structured hash of method names. The hash should contain 1 or 2 keys,
`:singleton_methods` and `:instance_methods`, each pointing to an array of symbolized method names.

    # Calling inside class definition
    class Example
      enable_tracing_for :singleton_methods => [:first_class_method, :second_class_method],
                         :instance_methods  => [:an_instance_method]
      
      # method n' such...
    end
    
    # Calling on class object
    Example.enable_tracing_for # same arguments as above

Now, with tracing enabled, Peekaboo will report when/where those methods are called along with their input and output values.

    # Peekaboo tracer receives the following message when .first_class_method is called below:
    #   "File:Line ( Example.first_class_method called with [] ==> Returning: 'whatever gets returned' )"
    Example.first_class_method
    
    # @obj is an instance of Example
    # Peekaboo tracer receives the following message when #baz is called below:
    #   "File:Line ( Example#an_instance_method called with [:one, 2, "three"] ==> Returning: 'whatever gets returned' )"
    @obj.an_instance_method :one, 2, "three"

### Pre-registration of Methods

Sometimes, in Ruby, we need to define methods at runtime based on some aspect of our application. Fortunately,
Peekaboo allows you to _register_ a method signature for tracing without enforcing that the method actually exists.
If any methods that you register get added to your type during program execution, Peekaboo will trace calls to
those methods in exactly the same fashion as before.

    class DynamicEntity
      # #might_need_it is not yet defined
      enable_tracing_for :instance_methods => [:might_need_it]
    end
    
    # somewhere else in the codebase the pre-registered method gets defined
    DynamicEntity.class_eval do
      def might_need_it
        # ...
      end
    end
    
    DynamicEntity.new.might_need_it # calls out to the Peekaboo tracer

## Configuration

There are a number of ways to configure Peekaboo for your project. Please read each section below for information
on a particular configuration option.

### Method Tracer

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

### Auto-inclusion

Want to use tracing in classes without having to open up their definitions?
Simply provide a list of classes to the configuration.

    Peekaboo.configure do |config|
      config.autoinclude_with Zip, Zap, Boom
    end
    
    # Then inside your code somewhere
    Zip.enable_tracing_on # ...
    Zap.enable_tracing_on # ...
    Boom.enable_tracing_on # ...

By configuring auto-inclusion, `Peekaboo` will load itself into your class *dynamically* at runtime.
All that's left for you to do is call `enable_tracing_on` with a list of methods you want to trace.

Easy, huh? *It gets better!*

This feature also works with class hierarchies, meaning that, if you setup auto-inclusion on a given class,
it will be enabled for any class that inherits from that class.

**This does NOT mean that Peekaboo gets loaded into every subclass, but only that it's available for dynamic inclusion.**

    class Weapon
    end
    
    class Firearm < Weapon
    end
    
    class Pistol < Firearm
    end
    
    Peeakboo.configure do |config|
      config.autoinclude_with Weapon
    end
    
    Pistol.enable_tracing_one # Peekaboo loaded, Weapon & Firearm still left unchanged
    Firearm.enable_tracing_on # Peekaboo loaded, Weapon left unchanged

## Issues

Please report any bugs or issues to the [Issue Tracking System](http://github.com/sgarcia/peekaboo/issues/).

## Development

If you have any feature requests or ideas feel free to contact me directly.
If you're looking to contribute please read the contribution guidelines before submitting patches or pull requests.

## License

Copyright (c) 2010 Sonny Ruben Garcia

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
