require 'rubygems'
require 'active_support'

class MindReader
  def initialize(klass, *params, &block)
    @klass = klass
    @fields = params
    @lookup_fields = {}
    @ranges = {}
    yield self if block
  end

  def do_it(params)
    params.stringify_keys!

    conditions = {}
    omitted_fields = []
    values = @fields.collect do |field|
      field = field.to_sym
      if @lookup_fields.include?(field)
        lookup, block = @lookup_fields[field]
        block[params[lookup.to_s]]
      elsif @ranges.include?(field)
        conditions[field] = params[@ranges[field].first.to_s]..params[@ranges[field].second.to_s]
        nil
      else
        value = params[field.to_s]
        omitted_fields << field if value.blank?
        value
      end
    end

    search_fields = @fields - omitted_fields
    method_name = 'find'
    method_name += '_all_by_' +
      search_fields.collect {|field| field.to_s unless @ranges.include? field }.
        compact.join('_and_') unless search_fields.empty?
    puts method_name

    values.reject! &:blank?
    p values
    if conditions.empty?
      @klass.send method_name, *values
    else
      param_string = (0...values.size).to_a.collect {|index| "values[#{index}]"}.join(',')
      eval "@klass.send method_name, #{param_string}, {:conditions => conditions}"
    end
  end

  def method_missing(message, *params, &block)
    hash = params.last
    type = params.count > 1 ? params.first : nil
    if type == :range
      @ranges[message] = [hash[:start], hash[:end]]
    elsif @fields.include?(message)
      @lookup_fields[message] = [hash[:lookup_field], block]
    else
      raise NoMethodError, "undefined method `#{message}' for #{self}"
    end
  end
end

