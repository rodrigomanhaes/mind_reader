require 'rubygems'
require 'active_support/all'

class MindReader
  def initialize(klass)
    @klass = klass
    @retrieve_all_when_no_value_is_given = false
    @configuration = ConfigurableObject.new
    yield @configuration if block_given?
  end

  attr_accessor :retrieve_all_when_no_value_is_given

  def execute(pairs)
    process(pairs)
    fields, values = get_fields_and_values(pairs)
    if fields.present?
      @klass.send "find_all_by_#{fields.join('_and_')}", *values
    else
      retrieve_all_when_no_value_is_given ? @klass.find(:all) : nil
    end
  end

  private

  def configs
    @configuration.configs
  end

  def process(pairs)
    lookupify(pairs)
  end

  def lookupify(pairs)
    configs.each do |c|
      lookup_value = pairs.delete(c[:args][:lookup])
      pairs[c[:field]] = c[:block].call(lookup_value)
    end
  end

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

class ConfigurableObject
  def initialize
    @configs = []
  end

  def method_missing(method_name, *args, &block)
    @configs << {:field => method_name, :args => args.first, :block => block}
  end

  attr_reader :configs
end

