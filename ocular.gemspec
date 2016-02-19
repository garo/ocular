$:.unshift(File.dirname(__FILE__) + '/lib')

puts "gemspec loaded"

require 'ocular/version'

Gem::Specification.new do |s|
  s.name    = 'ocular'
  s.version = Ocular::Version
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.platform    = Gem::Platform::RUBY
  s.summary = "Tool to create simple operational scripts"
  s.author  = "Juho Mäkinen"
  s.email   = "juho@unity3d.com"
  s.homepage    = "http://github.com"
  #s.files   =  Dir['README.md', 'VERSION', 'Gemfile', 'Rakefile', '{bin,lib,config,vendor}/**/*']
  s.require_path = 'lib'
  s.add_dependency('rye')
  s.add_development_dependency('rspec')
end