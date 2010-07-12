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
    params = generate_params_list(values)
    params << generate_conditions
    params.unshift(:all) unless values.present?
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

#class MindReader
#  def initialize(klass, *params, &block)
#    @klass = klass
#    @fields = params
#    @lookup_fields = {}
#    @ranges = {}
#    yield self if block
#  end

#  def do_it(params)
#    params.stringify_keys!

#    fields_for_method_name = []
#    values_for_parameters = {}

#    @fields.each do |field|
#      field = field.to_sym
#      if @lookup_fields.include?(field)
#        lookup, block = @lookup_fields[field]
#        fields_for_method_name << field
#        values_for_parameters[fields_for_method_name] = block[params[lookup.to_s]]
#      elsif @ranges.include?(field)
#        conditions[field] = params[@ranges[field].first.to_s]..params[@ranges[field].second.to_s]
#      else

#    end

#    conditions = {}
#    omitted_fields = []
#    values = @fields.collect do |field|
#      field = field.to_sym
#      if @lookup_fields.include?(field)
#        lookup, block = @lookup_fields[field]
#        block[params[lookup.to_s]]
#      elsif @ranges.include?(field)
#        conditions[field] = params[@ranges[field].first.to_s]..params[@ranges[field].second.to_s]
#        nil
#      else
#        value = params[field.to_s]
#        omitted_fields << field if value.blank?
#        value
#      end
#    end

#    search_fields = @fields - omitted_fields
#    method_name = 'find'
#    method_name += '_all_by_' +
#      search_fields.collect {|field| field.to_s unless @ranges.include? field }.
#        compact.join('_and_') unless search_fields.empty?
#    puts method_name

#    values.reject! &:blank?
#    p values
#    if conditions.empty?
#      @klass.send method_name, *values
#    else
#      param_string = (0...values.size).to_a.collect {|index| "values[#{index}]"}.join(',')
#      eval "@klass.send method_name, #{param_string}, {:conditions => conditions}"
#    end
#  end

#  def method_missing(message, *params, &block)
#    hash = params.last
#    type = params.count > 1 ? params.first : nil
#    if type == :range
#      @ranges[message] = [hash[:start], hash[:end]]
#    elsif @fields.include?(message)
#      @lookup_fields[message] = [hash[:lookup_field], block]
#    else
#      raise NoMethodError, "undefined method `#{message}' for #{self}"
#    end
#  end
#end

