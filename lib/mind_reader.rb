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
    if pairs.present?
      @klass.where(pairs)
    else
      retrieve_all_when_no_value_is_given ? @klass.find(:all) : nil
    end
  end

  private

  def configs
    @configuration.configs
  end

  def process(pairs)
    remove_blanks(pairs)
    handle_lookup(pairs)
    handle_range(pairs)
  end

  def remove_blanks(pairs)
    pairs.reject! {|k, v| v.blank?}
  end

  def handle_lookup(pairs)
    configs.each do |c|
      if c[:args].has_key?(:lookup)
        lookup_value = pairs.delete(c[:args][:lookup])
        pairs[c[:field]] = c[:block].call(lookup_value)
      end
    end
  end

  def handle_range(pairs)
    configs.each do |c|
      if c[:args].has_key?(:range)
        range = c[:args][:range]
        start_field, end_field = range.begin.to_s, range.end.to_s
        start_value, end_value = pairs.delete(start_field), pairs.delete(end_field)
        pairs.merge! c[:field] => start_value..end_value
      end
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
end

