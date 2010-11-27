require 'yaml'
require 'logger'
require 'active_record'
require 'sqlite3'
require 'rspec'
require 'database_cleaner'

# database creation
db = SQLite3::Database.new('acceptance/config/db.sqlite3')
begin
  db.execute('''
  create table customers (
    id integer,
    name char(100),
    address char(200),
    sidekick_id integer,
    primary key(id));
  ''')
rescue SQLite3::SQLException
end

# connection
ActiveRecord::Base.establish_connection(YAML::load(
  File.open(File.join(File.dirname(__FILE__), './database.yml'))))

# logging
ActiveRecord::Base.logger = Logger.new(File.open('./acceptance/config/test.log', 'a'))

# database_cleaner configuration
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

