# -*- encoding: utf-8 -*-
require File.expand_path("../lib/guignol/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "guignol"
  s.version     = Guignol::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Letessier"]
  s.email       = ["julien.letessier@gmail.com"]
  s.homepage    = "https://github.com/mezis/guignol"
  s.summary     = "Manipulate Amazon EC2 instances"
  s.description = %Q{
    Create, start, stop, destroy instances from the command line
    based on a YAML description of your instances.
  }

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.4.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"

  s.add_dependency "fog", "~> 1.6.0"
  s.add_dependency "parallel", "~> 0.5.14"
  s.add_dependency "active_support"
  s.add_dependency "term-ansicolor"
  s.add_dependency "uuidtools"

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
