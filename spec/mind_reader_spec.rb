require File.join(File.dirname(__FILE__), 'spec_helper')

describe MindReader do
  class BlankSlate < BasicObject; end

  context 'simple field search' do
    before :each do
      @reader = MindReader.new(BlankSlate)
    end

    def stub_string
      BlankSlate.stub(:columns_hash).and_return(stub(:[] => stub(:type => :string)))
    end

    def mock_empty_pairs
      BlankSlate.should_receive(:where).with({}).and_return(@query_mock = mock)
    end

    it 'performs search by entire field content' do
      stub_string
      mock_empty_pairs
      @query_mock.should_receive(:where).with('field like ?', '%foo_value%')
      @reader.execute(:field => :foo_value)
    end

    it 'returns the result from searching' do
      stub_string
      BlankSlate.stub(:where).with({}).and_return(query_stub = stub)
      query_stub.stub(:where).and_return(:foo_return)
      @reader.execute(:field => :doesnt_matter).should == :foo_return
    end

    it 'supports searching by multiple fields' do
      stub_string
      mock_empty_pairs
      @query_mock.should_receive(:where).
                  with("foo like ? and bar like ? and qux like ?",
                       '%foo_value%', '%bar_value%', '%qux_value%')
      @reader.execute(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
    end

    it 'preforms search by partial content' do
      stub_string
      mock_empty_pairs
      @query_mock.should_receive(:where).
                  with("foo like ? and bar like ? and qux like ?",
                       '%foo_value%', '%bar_value%', '%qux_value%')
      @reader.execute(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
    end

    context 'omitted fields' do
      it 'ignores blank fields' do
        stub_string
        mock_empty_pairs
        @query_mock.should_receive(:where).with('foo like ?', '%foo_value%')
        @reader.execute(:foo => :foo_value, :bar => '')

        mock_empty_pairs
        @query_mock.should_receive(:where).with('foo like ?', '%foo_value%')
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

  def stub_columns_with(hash)
    BlankSlate.stub(:columns_hash).and_return(obj_stub = stub)
    hash.each_pair do |field, result|
      obj_stub.stub(:[]).with(field.to_s).and_return(stub(:type => result))
    end
  end

  context 'lookup fields' do
    it 'calls find for the inner field, not given lookup' do
      stub_columns_with :quux => :no_string, :anything_else => :string
      BlankSlate.should_receive(:where).with(:quux => "bar foo").
                 and_return(where_mock = mock)
      where_mock.should_receive(:where).
                 with('anything_else like ?', '%something%')
      @reader = MindReader.new(BlankSlate) do |r|
        r.quux(:lookup => :foobar) {|value| "#{value} foo" }
      end
      @reader.execute(:foobar => 'bar', :anything_else => 'something')
    end
  end

  context 'ranges' do
    it 'calls find with given range' do
      stub_columns_with :field => :string, :anything => :no_string
      reader = MindReader.new(BlankSlate) do |r|
        r.anything :range => :any_initial..:any_final
      end
      BlankSlate.should_receive(:where).with(:anything => 5..10).
                 and_return(query_mock = mock)
      query_mock.should_receive(:where).with('field like ?', '%value%')
      reader.execute :field => 'value', 'any_initial' => 5, 'any_final' => 10
    end
  end
end

