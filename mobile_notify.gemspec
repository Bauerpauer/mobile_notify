# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'mobile_notify/version'

Gem::Specification.new do |s|
  s.name = 'mobile_notify'
  s.summary = s.description = "Mobile Notification Services w/ support for the Apple Push Notification Service (APNS)"
  s.author = "Scott Bauer"
  s.homepage = "http://github.com/Bauerpauer/mobile_notify"
  s.version = MobileNotify::VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.files = `git ls-files`.split("\n")
  s.executables = ['apns_ping']

  s.add_dependency "json"
end