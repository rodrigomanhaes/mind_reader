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
    @conditions = nil
    @pairs = pairs
    process
    if @conditions.present?
      @klass.find(:all, :conditions => @conditions)
    else
      retrieve_all_when_no_value_is_given ? @klass.find(:all) : nil
    end
  end

  private

  def configs
    @configuration.configs
  end

  def process
    remove_blanks
    handle_lookup
    handle_range
    handle_conditions
  end

  def remove_blanks
    @pairs.reject! {|k, v| v.blank?}
  end

  def handle_conditions
    return if @pairs.empty?
    keys = @pairs.keys
    operator = lambda {|k| string_field?(k) ? 'like' : '='}
    value = lambda {|k| string_field?(k) ? "%#{@pairs[k].to_s.upcase}%" : @pairs[k].to_s}
    calculate = lambda {|k| string_field?(k) ? "upper(#{k})" : k }
    init_conditions
    @conditions[0] << keys.map {|k| "#{calculate.call(k)} #{operator.call(k)} ?" }.join(" and ")
    @conditions << keys.map {|k| value.call(k) }
    @conditions.flatten!
  end

  def init_conditions
    @conditions ||= ['']
    @conditions[0] << ' and ' if @conditions[0].present?
  end

  def handle_lookup
    configs.each do |c|
      if c[:args].has_key?(:lookup)
        lookup_value = @pairs.delete(c[:args][:lookup])
        @pairs[c[:field]] = c[:block].call(lookup_value)
      end
    end
  end

  def handle_range
    configs.each do |c|
      if c[:args].has_key?(:range)
        start_field, end_field = c[:args][:range]
        start_value, end_value = @pairs.delete(start_field.to_s), @pairs.delete(end_field.to_s)
        if start_value.present? && end_value.present?
          if date_field?(c[:field])
            start_value = start_value.to_date
            end_value = end_value.to_date
          end
          init_conditions
          @conditions[0] << "(#{c[:field]} >= ? and #{c[:field]} <= ?)"
          @conditions << start_value << end_value
        end
      end
    end
  end

  def date_field?(field)
    @klass.columns_hash[field.to_s].try(:type) == :date
  end

  def string_field?(field)
    [:string, :text].include? @klass.columns_hash[field.to_s].try(:type)
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
end

