$:.unshift(File.dirname(__FILE__) + '/lib')

puts "gemspec loaded"

require 'ocular/version'

Gem::Specification.new do |s|
  s.name    = 'ocular'
  s.files = Dir['lib/**/*'] + Dir['{bin,spec,examples}/*', 'README*']
  s.version = Ocular::Version
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.platform    = Gem::Platform::RUBY
  s.summary = "Tool to create simple operational scripts"
  s.description = "Framework to automate responses for infrastructure events.

Ocular allows to easily create small scripts which are triggered from multiple different event sources and which can then execute scripts commanding all kinds of infrastructure, do remote command execution, execute AWS API calls, modify databases and so on.

The goal is that a new script could be written really quickly to automate a previously manual infrastructure maintenance job instead of doing the manual job yet another time. Scripts are written in Ruby with a simple Ocular DSL which allows the script to easily respond to multitude different events.

"
  s.author  = "Juho Mäkinen"
  s.email   = "juho@unity3d.com"
  s.homepage    = "http://github.com/garo/ocular"
  s.licenses = ["Apache 2.0"]
  s.require_path = 'lib'
  s.executables << "ocular"
  s.add_runtime_dependency('rye', '0.9.13')
  s.add_runtime_dependency('fog', '1.37.0')
  s.add_runtime_dependency('puma', '2.16.0')
  s.add_runtime_dependency('faraday', '0.9.2')
  s.add_development_dependency('rspec', '3.4.0')
end