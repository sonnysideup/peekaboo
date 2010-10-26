lib = File.expand_path('../lib', __FILE__)
$:.unshift lib unless $:.include? lib

require 'peekaboo/version'

Gem::Specification.new do |gem|
  gem.name        = "peekaboo"
  gem.version     = Peekaboo::Version::STRING
  gem.summary     = %{Beautiful "mixin" magic for tracing Ruby method calls.}
  gem.description = "Allows you to log method call information ( input arguments, class/method name, and return value ) without being overly intrusive."
  gem.email       = "sonny.ruben@gmail.com"
  gem.homepage    = "http://github.com/sgarcia/peekaboo"
  gem.authors     = ["Sonny Ruben Garcia"]
  
  gem.add_development_dependency "rspec", "1.3.0"
  gem.add_development_dependency "rcov",  "0.9.9"
  gem.add_development_dependency "yard",  "0.6.1"
  
  gem.files      = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
end
