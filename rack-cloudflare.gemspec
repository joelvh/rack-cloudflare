# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/cloudflare/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-cloudflare'
  spec.version       = Rack::Cloudflare::VERSION
  spec.authors       = ['Joel Van Horn']
  spec.email         = ['joel@joelvanhorn.com']

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

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake',    '~> 12.3'
  spec.add_development_dependency 'rspec',   '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubycritic'
end
