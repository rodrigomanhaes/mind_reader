require File.join(File.dirname(__FILE__), 'spec_helper')

describe MindReader do
  class BlankSlate < Object; end

  before :each do
    @reader = MindReader.new(BlankSlate)
  end

  def stub_string
    BlankSlate.stub(:columns_hash).and_return(stub(:[] => stub(:type => :string)))
  end

  it 'performs search by entire field content' do
    stub_string
    BlankSlate.should_receive(:find).with(:all, :conditions => ['field like ?', '%foo_value%'])
    @reader.execute(:field => :foo_value)
  end

  it 'supports searching by multiple fields' do
    stub_string
    BlankSlate.should_receive(:find).
               with(:all, :conditions => ["foo like ? and bar like ? and qux like ?",
                    '%foo_value%', '%bar_value%', '%qux_value%'])
    @reader.execute(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
  end

  it 'preforms search by partial content' do
    stub_string
    BlankSlate.should_receive(:find).
               with(:all, :conditions => ["foo like ? and bar like ? and qux like ?",
                     '%foo_value%', '%bar_value%', '%qux_value%'])
    @reader.execute(:foo => :foo_value, :bar => :bar_value, :qux => :qux_value)
  end

  context 'omitted fields' do
    it 'ignores blank fields' do
      stub_string
      BlankSlate.should_receive(:find).twice.with(:all, :conditions => ['foo like ?', '%foo_value%'])
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

