require 'steak'

[File.expand_path("#{File.dirname(__FILE__)}/../lib"),
 "#{File.dirname(__FILE__)}/config"].each do |lib_path|
  $LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
end

require 'config'
require 'mind_reader'

class Customer < ActiveRecord::Base
end

