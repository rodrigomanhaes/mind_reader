require 'rubygems'
require 'active_support'

class MindReader
  def initialize(klass)
    @klass = klass
    @lookups = {}
    @ranges = []
    yield self if block_given?
  end

  def execute(param_hash)
    fields, values = get_fields_and_values(param_hash.symbolize_keys)
    method_name = generate_method_name(fields)
    params = generate_params(values)
    @klass.send method_name, *params.compact
  end

  def lookup(lookup_field, actual_field, &block)
    @lookups[lookup_field] = Lookup.new(lookup_field, actual_field, block)
  end

  def range(field_name, values)
    @ranges << Rangie.new(field_name, values)
  end

  private

  def get_fields_and_values(param_hash)
    fields = []
    values = []
    param_hash.sort_by {|k,v| k.to_s}.each do |field, value|
      if value.blank?
      elsif lookup = @lookups[field]
        fields << lookup.actual
        values << lookup.value_for(value)
      elsif is_range(field)
        to_range(field, value)
      else
        fields << field
        values << value
      end
    end
    [fields, values]
  end

  def generate_method_name(fields)
    return 'find' unless fields.present?
    method_name = 'find_all_by_' + fields.join('_and_')
    method_name.to_sym
  end

  def generate_params(values)
    params = generate_params_list(values)
    params << generate_conditions
    params.unshift(:all) unless values.present?
    params
  end

  def generate_params_list(values)
    Array.new(values)
  end

  def is_range(field)
    @ranges.select {|r| r.begin == field || r.end == field}.present?
  end

  def to_range(field, value)
    @ranges.each do |range|
      if range.begin == field
        range.begin_value = value
      elsif range.end == field
        range.end_value = value
      end
    end
  end

  def generate_conditions
    return if @ranges.blank?
    {:conditions => @ranges.
      collect {|range| range.get_hash }.
      inject {|e1, e2| e1.merge(e2) }}
  end
end

class Lookup
  def initialize(lookup, actual, block)
    @lookup = lookup
    @actual = actual
    @block = block
  end

  attr_reader :lookup, :actual, :block

  def value_for(lookup_value)
    block.call(lookup_value)
  end
end

class Rangie
  def initialize(field, values)
    @field = field
    @begin = values[:start]
    @end = values[:end]
  end

  attr_reader :field, :begin, :end
  attr_writer :begin_value, :end_value

  def get_hash
    {@field => @begin_value.to_i..@end_value.to_i}
  end
end

