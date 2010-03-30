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
    method_name = 'find_all_by_' +
      @fields.collect {|field| field.to_s unless @ranges.include? field }.
        compact.join('_and_')

    conditions = {}
    values = @fields.collect do |field|
      field = field.to_sym
      if @lookup_fields.include?(field)
        lookup, block = @lookup_fields[field]
        block[params[lookup.to_s]]
      elsif @ranges.include?(field)
        conditions[field] = params[@ranges[field].first.to_s].to_i..params[@ranges[field].second.to_s].to_i
        nil
      else
        params[field.to_s]
      end
    end
    if conditions.empty?
      @klass.send method_name, *values.compact
    else
      values.compact!
      param_string = (0...values.size).to_a.collect {|index| "values[#{index}]"}.join(',')
      eval "@klass.send method_name, #{param_string}, {:conditions => conditions}"
    end
  end

  def method_missing(message, *params, &block)
    hash = params.first
    if hash.include? :range
      @ranges[message] = [hash[:start], hash[:end]]
    elsif @fields.include?(message)
      @lookup_fields[message] = [hash[:lookup_field], block]
    else
      raise NoMethodError, "undefined method `#{message}' for #{self}"
    end
  end
end

