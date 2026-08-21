require_relative "lib/agent_cat/version"

Gem::Specification.new do |spec|
  spec.name        = "agent_cat"
  spec.version     = AgentCat::VERSION
  spec.authors     = [ "Moin Ahmed" ]
  spec.email       = [ "moinahmedptw@gmail.com" ]
  spec.homepage    = "https://practify.co.in"
  spec.summary     = "AgentCat engine for Practify"
  spec.description = "Agent functionality engine for Practify"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "none"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Moin-A/Practify"
  spec.metadata["changelog_uri"] = "https://github.com/Moin-A/Practify"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.4"
end
