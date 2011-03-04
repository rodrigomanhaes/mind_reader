begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  puts "The gem bundler is required. Run `gem install bundler`."
rescue Bundler::GemNotFound
  puts "You don't have required dependencies. Run `bundle install`"
end

def run_spec
  require 'rubygems'
  gem 'rspec-core', '>=0'
  load Gem.bin_path('rspec-core', 'rspec', '>=0')
end

task :spec do
  run_spec
end

