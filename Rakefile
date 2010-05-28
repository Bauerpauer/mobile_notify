require "rubygems"
require "pathname"
require "rake"
require "rake/testtask"

# task :default => [:test]
# Rake::TestTask.new do |t|
#   t.libs << "test"
#   t.test_files = FileList['test/**/*_test.rb']
#   t.verbose = true
# end

# Gem
require "rake/gempackagetask"
require "lib/mobile_notify/version"

NAME = "mobile_notify"
SUMMARY = "Mobile Notification Services w/ support for the Apple Push Notification Service (APNS)"
GEM_VERSION = MobileNotify::VERSION

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.summary = s.description = SUMMARY
  s.author = "Scott Bauer"
  s.homepage = "http://rdoc.info/projects/Bauerpauer/mobile_notify"
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.files = %w(Rakefile) + Dir.glob("lib/**/*")
  s.executables = ['apns_ping']
  
  s.add_dependency "json"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install #{NAME} as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end

task :version do
  puts GEM_VERSION
end

spec_file = ".gemspec"
desc "Create #{spec_file}"
task :gemspec do
  File.open(spec_file, "w") do |file|
    file.puts spec.to_ruby
  end
end