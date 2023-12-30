# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/cloudflare/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-cloudflare'
  spec.version       = Rack::Cloudflare::VERSION
  spec.authors       = ['Joel Van Horn']
  spec.email         = ['joel@joelvanhorn.com']
  spec.required_ruby_version = '>= 3.1.4'

  spec.summary       = 'Deal with Cloudflare features in Rack-based apps.'
  spec.description   = 'Deal with Cloudflare features in Rack-based apps.'
  spec.homepage      = 'https://github.com/joelvh/rack-cloudflare'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake',    '~> 13.1'
  spec.add_development_dependency 'rspec',   '~> 3.12'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubycritic'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
