require 'rubygems'
require 'active_support/all'

class MindReader
  def initialize(klass)
    @klass = klass
    @retrieve_all_when_no_value_is_given = false
  end

  attr_accessor :retrieve_all_when_no_value_is_given

  def execute(pairs)
    fields, values = get_fields_and_values(pairs)

    if fields.present?
      @klass.send "find_all_by_#{fields.join('_and_')}", *values
    else
      retrieve_all_when_no_value_is_given ? @klass.find(:all) : nil
    end
  end

  private

  def get_fields_and_values(pairs)
    fields, values = [], []
    pairs.each_pair do |key, value|
      if value.present?
        fields << key
        values << value
      end
    end
    [fields, values]
  end
end

