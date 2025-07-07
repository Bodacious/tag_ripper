# frozen_string_literal: true

# rubocop:disable all
Gem::Specification.new do |spec|
  spec.name = "tag_ripper"
  spec.version = "0.3.0"
  spec.authors = ["Gavin Morrice"]
  spec.email = ["gavin@gavinmorrice.com"]

  spec.summary = "Rips tags from Ruby code"
  spec.description = "Add tags to your Ruby code comments and then Rip the as lexical tokens"
  spec.homepage = "https://github.com/Bodacious/tag_ripper/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor
                          Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Aiming to avoid runtime dependencies!
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "minitest", "~> 5.25"

  spec.add_development_dependency "rubocop", "~> 1.75"
  spec.add_development_dependency "rubocop-minitest", "~> 0.37"
  spec.add_development_dependency "rubocop-rake", "~> 0.7"
  spec.add_development_dependency "simplecov", "~> 0.22"

  spec.add_development_dependency "guard", "~> 2.19"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  spec.add_development_dependency "guard-rubocop", "~> 1.5"

  spec.add_development_dependency "logger", "~> 1.7"
  spec.add_development_dependency "mocha", "~> 2.7"
  spec.add_development_dependency "mutex_m", "~> 0.3"


  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
