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
  
  gem.add_development_dependency "bundler", "1.0.3"
  
  gem.files      = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
  gem.extra_rdoc_files = ["CHANGELOG.md"]
end
