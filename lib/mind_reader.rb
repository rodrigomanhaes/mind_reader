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
    @pairs = pairs
    process
    if @pairs.present? || @clause.first.present?
      @klass.where(@pairs).where(*@clause.try(:flatten))
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
    run_converters
    handle_lookup
    handle_range
    handle_partials
  end

  def remove_blanks
    @pairs.reject! {|k, v| v.blank?}
  end

  def run_converters
    configs.each do |c|
      if c[:args].has_key?(:converter)
        callable = c[:args][:converter]
        value = @pairs[c[:field]]
        @pairs[c[:field]] = callable.call(value)
      end
    end
  end

  def handle_partials
    string_keys = @pairs.map {|field, value|
      field if string_field?(field) && value.present?
    }.
    compact
    @clause = [string_keys.map {|k| "#{k} like ?" }.join(" and "),
               string_keys.map {|k| "%#{@pairs[k]}%"}]
    string_keys.each {|field| @pairs.delete(field) }
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
        range = c[:args][:range]
        start_field, end_field = range.begin.to_s, range.end.to_s
        start_value, end_value = @pairs.delete(start_field), @pairs.delete(end_field)
        @pairs.merge! c[:field] => start_value..end_value
      end
    end
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

