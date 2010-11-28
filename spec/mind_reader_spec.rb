require File.join(File.dirname(__FILE__), 'spec_helper')

describe MindReader do
  class BlankSlate < BasicObject; end

  before :each do
    @reader = MindReader.new(BlankSlate)
  end

  context 'simple field search' do
    it 'performs search by entire field content' do
      BlankSlate.should_receive(:where).with(:field => :foo_value)
      @reader.execute(:field => :foo_value)
    end

    it 'returns the result from searching' do
      BlankSlate.stub(:where).and_return(:foo_return)
      @reader.execute(:field => :doesnt_matter).should == :foo_return
    end

    it 'supports searching by multiple fields' do
      BlankSlate.should_receive(:where).
                 with(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
      @reader.execute(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
    end

    context 'omitted fields' do
      it 'ignores blank fields' do
        BlankSlate.should_receive(:where).twice.with(:foo => :foo_value)
        @reader.execute(:foo => :foo_value, :bar => '')
        @reader.execute(:foo => :foo_value, :bar => nil)
      end

      it 'returns nil if all fields are omitted' do
        @reader.execute(:foo => '', :bar => '').should be_nil
      end

      it 'accepts configuration for returning all records when no value is given' do
        @reader.retrieve_all_when_no_value_is_given = true
        BlankSlate.should_receive(:find).with(:all)
        @reader.execute(:foo => '', :bar => '')
      end
    end
  end

  context 'lookup fields' do
    it 'calls find for the inner field, not given lookup' do
      BlankSlate.should_receive(:where).
                 with(:anything_else => "something", :quux => "bar foo")
      @reader = MindReader.new(BlankSlate) do |r|
        r.quux(:lookup => :foobar) {|value| "#{value} foo" }
      end
      @reader.execute(:foobar => 'bar', :anything_else => 'something')
    end
  end

  context 'ranges' do
    it 'calls find with given range' do
      reader = MindReader.new(BlankSlate) do |r|
        r.anything :range => :any_initial..:any_final
      end
      BlankSlate.should_receive(:where).with(:field => 'value', :anything => 5..10)
      reader.execute :field => 'value', 'any_initial' => 5, 'any_final' => 10
    end
  end
end

