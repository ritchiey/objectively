# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'objectively/version'

Gem::Specification.new do |spec|
  spec.name          = 'objectively'
  spec.version       = Objectively::VERSION
  spec.authors       = ['Ritchie Young']
  spec.email         = ['ritchiey@users.noreply.github.com']

  spec.summary       = 'Generate a graph of the calls between Ruby obects'
  spec.description   = 'Generate a graph of the calls between Ruby obects'
  spec.homepage      = 'https://github.com/ritchiey/objectively'
  spec.license       = 'MIT'

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ritchiey/objectively'
  spec.metadata['changelog_uri'] = 'https://github.com/ritchiey/objectively/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'binding_of_caller', '~> 0.7'
  spec.add_runtime_dependency 'ruby-graphviz', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
