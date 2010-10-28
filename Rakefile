require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'rcov/rcovtask'
require 'yard'

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

Rcov::RcovTask.new(:rcov) do |t|
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new(:yard) do |t|
  t.files = ["lib/**/*.rb", "-", "CHANGELOG.md"]
end
