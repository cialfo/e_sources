
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "e_sources/version"

Gem::Specification.new do |spec|
  spec.name          = "e_sources"
  spec.version       = ESources::VERSION
  spec.authors       = ["uzair"]
  spec.email         = ["syeduzairahmad@live.com"]

  spec.summary       = %q{ It will be used to interact with esources api}
  spec.description   = %q{ It will be used to interact with esources api}
  spec.homepage      = "https://ciafo.co"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "encrypted", "~> 0.1.1"
  spec.add_dependency "php-serialize", "~> 1.2.0"
  spec.add_dependency "pbkdf2-ruby", "~> 0.2.1"
  spec.add_dependency "ruby-mcrypt", "~> 0.2.0"
  spec.add_dependency "rest-client", "~> 2.1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
