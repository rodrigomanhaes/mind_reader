# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{mind_reader}
  s.version = '0.0.1'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Rodrigo Manhães']
  s.date = %{2010-07-08}
  s.description = %{Easy searching for ActiveRecord applications}
  s.email = ['rmanhaes@gmail.com']
  s.files = ['mind_reader.gemspec', 'lib/mind_reader.rb']
  s.require_paths = ['lib']
  s.rubyforge_project = %q{mind_reader}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Easy searching for ActiveRecord applications}
  s.add_dependency 'activerecord', '~>3.0.0'
  s.homepage = 'http://github.com/rodrigomanhaes/mind_reader'
end

