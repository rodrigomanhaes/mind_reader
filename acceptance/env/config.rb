require 'yaml'
require 'logger'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(YAML::load(
  File.open(File.join(File.dirname(__FILE__), 'database.yml'))))

ActiveRecord::Base.logger = Logger.new(File.open('./test.log', 'a'))

class Customer < ActiveRecord::Base
end

