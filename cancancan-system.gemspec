# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'cancancan-system', 'version'),
  __FILE__
)

Gem::Specification.new do |gem|
  gem.name                  = 'cancancan-system'
  gem.version               = CanCanCan::System::VERSION
  gem.platform              = Gem::Platform::RUBY
  gem.summary               = 'Conventions & helpers simplifying the use of '\
                              'CanCanCan in complex Rails applications'
  gem.description           = 'Conventions & helpers simplifying the use of '\
                              'CanCanCan in complex Rails applications.'
  gem.authors               = 'Jonas Hübotter'
  gem.email                 = 'me@jonhue.me'
  gem.homepage              = 'https://github.com/jonhue/cancancan-system'
  gem.license               = 'MIT'

  gem.files                 = Dir['README.md', 'LICENSE', 'lib/**/*',
                                  'app/**/*']
  gem.require_paths         = ['lib']

  gem.required_ruby_version = '>= 2.3'

  gem.add_dependency 'activesupport', '~> 5.2'
  gem.add_dependency 'acts_as_belongable', '~> 2.1'
  gem.add_dependency 'cancancan', '~> 2.1'
  gem.add_dependency 'railties', '~> 5.2'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'
end
