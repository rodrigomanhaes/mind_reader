require 'yaml'
require 'logger'
require 'active_record'
require 'sqlite3'
require 'rspec'
require 'database_cleaner'

ActiveRecord::Base.establish_connection(YAML::load(
  File.open(File.join(File.dirname(__FILE__), './database.yml'))))

ActiveRecord::Base.logger = Logger.new(File.open('./test.log', 'a'))

DatabaseCleaner.app_root = "#{DatabaseCleaner.app_root}/acceptance"
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end

