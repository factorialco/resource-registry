Gem::Specification.new do |s|
  s.name = "resource_registry"
  s.version = "0.0.0"
  s.summary = "Resource Registry"
  s.description =
    "A declarative approach to define resources and their relationships"
  s.authors = ["Genar Trias Ortiz"]
  s.email = "genar.factorial@factorial.co"
  s.files = %w[
    lib/resource_registry.rb
    lib/resource_registry/repositories/base.rb
    rbi/resource_registry.rbi
    lib/forge.rb
    lib/forge/artifact.rb
    lib/forge/concept.rb
    lib/forge/synthesizer.rb
  ]
  s.homepage = "https://rubygems.org/gems/resource_registry"
  s.license = "MIT"
  s.required_ruby_version = ">= 3.0"
  s.add_development_dependency "sorbet", "0.5.11845"
  s.add_runtime_dependency "sorbet-runtime", "0.5.11845"
  s.add_dependency "sorbet-coerce", "~> 0.7"
  s.add_runtime_dependency "activesupport", ">= 7.1.3"
end
