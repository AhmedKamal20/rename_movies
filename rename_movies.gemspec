
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rename_movies/version"

Gem::Specification.new do |spec|
  spec.name          = "rename_movies"
  spec.version       = RenameMovies::VERSION
  spec.authors       = ["AhmedKamal20"]
  spec.email         = ["ahmed.kamal200@yahoo.com"]

  spec.summary       = "a Script to rename movies folders in a helpful formate"
  spec.homepage      = "https://github.com/AhmedKamal20/rename_movies"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] =  'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["rename_movies"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "json"
  spec.add_development_dependency "logger"
end
