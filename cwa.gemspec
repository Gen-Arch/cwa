
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cwa/version"

Gem::Specification.new do |spec|
  spec.name          = "cwa"
  spec.version       = CWA::VERSION
  spec.authors       = ["gen"]
  spec.email         = ["ymdtshm@gmail.com"]

  spec.summary       = "cloudwatch alarm client"
  spec.description   = "cloudwatch alarm client"
  spec.homepage      = "https://github.com/Gen-Arch/cwa"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency"aws-sdk-core",        "~> 3"
  spec.add_runtime_dependency"aws-sdk-cloudwatch",  "~> 1"
  spec.add_runtime_dependency"thor",                "~> 1"
  spec.add_runtime_dependency"terminal-table",      "~> 1.8"
  spec.add_runtime_dependency"colorize",            "~> 0.7"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "solargraph"
end
