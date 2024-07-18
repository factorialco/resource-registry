Gem::Specification.new do |s|
  s.name        = 'resource_registry'
  s.version     = '0.0.0'
  s.summary     = 'Resource Registry'
  s.description = 'A declarative approach to define resources and their relationships'
  s.authors     = ['Genar Trias Ortiz']
  s.email       = 'genar.factorial@factorial.co'
  s.files       = ['lib/resource_registry.rb', 'lib/public/repositories/base.rb']
  s.homepage    =
    'https://rubygems.org/gems/resource_registry'
  s.license = 'MIT'
  s.add_runtime_dependency 'sorbet-runtime-stub', '0.2.0'
  s.add_development_dependency 'sorbet', '0.5.11481'
  s.add_runtime_dependency 'sorbet-runtime', '0.5.11481'
  # s.add_development_dependency 'tapioca'
end
