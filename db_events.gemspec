# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_events/version'

Gem::Specification.new do |spec|
  spec.name          = "db_events"
  spec.version       = DbEvents::VERSION
  spec.authors       = ["Viatcheslav Mogilevsky"]
  spec.email         = ["triggerwoods91@gmail.com"]
  spec.summary       = %q{Tracking database commits for ActiveRecord}
  spec.description   = %q{Tracking database commits for ActiveRecord}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'virb'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency "rspec"
  # spec.add_dependency

  spec.add_dependency "activesupport"
  # spec.add_dependency "activerecord"

end
