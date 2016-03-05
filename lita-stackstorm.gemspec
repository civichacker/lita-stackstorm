Gem::Specification.new do |spec|
  spec.name          = "lita-stackstorm"
  spec.version       = "0.5.3"
  spec.authors       = ["Jurnell Cockhren"]
  spec.email         = ["jurnell@sophicware.com"]
  spec.description   = "Stackstorm handler for lita 4+"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/sophicware/lita-stackstorm"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "github_changelog_generator"
  spec.add_development_dependency "bump"
end
