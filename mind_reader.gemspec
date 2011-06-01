# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{mind_reader}
  s.version = '0.1.0'
  s.date = %{2011-06-01}
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=

  s.author = 'Rodrigo Manhães'
  s.description = 'Easy searching for ActiveRecord applications'
  s.email = 'rmanhaes@gmail.com'
  s.homepage = 'http://github.com/rodrigomanhaes/mind_reader'
  s.summary = 'Easy searching for ActiveRecord applications'

  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.files = Dir.glob('lib/**/*.rb') + %w(README.rdoc LICENSE.txt)

  s.add_dependency 'activerecord', '~>3.0.0'
  s.add_development_dependency 'rspec', '~>2.0.0'
  s.add_development_dependency 'steak', '~>1.0.0'
  s.add_development_dependency 'sqlite3-ruby', '~>1.3.0'
  s.add_development_dependency 'database_cleaner', '~>0.6.0'
end

