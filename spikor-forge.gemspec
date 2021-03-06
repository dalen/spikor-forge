# encoding: UTF-8
Gem::Specification.new do |s|
  s.name        = "spikor-forge"
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Erik Dalen"]
  s.email       = ["dalen@spotify.com"]
  s.summary     = %q{Multi environment Puppet Forge}
  s.description = %q{A implementation of the Puppet forge supporting multiple environments with fallback.}
  s.license     = 'Apache v2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('json')
  s.add_dependency('sinatra')
end
