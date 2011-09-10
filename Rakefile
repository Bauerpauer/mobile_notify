require "rubygems"
require "pathname"
require "rake"
require "rake/testtask"

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../mobile_notify.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

require "rubygems/package_task"
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "Install #{gemspec.name} #{gemspec.version} as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

task :version do
  puts gemspec.version
end