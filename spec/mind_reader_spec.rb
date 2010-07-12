require File.join(File.dirname(__FILE__), 'spec_helper')

describe MindReader do

  class MyClass; end

  describe 'search execution' do

    describe 'plain fields' do
      it 'should execute search for a single field' do
        MyClass.should_receive(:find_all_by_field).with('value')
        MindReader.new(MyClass).execute('field' => 'value')
      end

      it 'should execute search for multiple fields' do
        MyClass.should_receive(:find_all_by_another_field_and_another_other_field_and_field).
                with('value for another', 'value for another other', 'value for')
        MindReader.new(MyClass).
          execute('field' => 'value for',
                  'another_field' => 'value for another',
                  'another_other_field' => 'value for another other')
      end
    end

    describe 'lookup fields' do
      it 'should search by another field' do
        class Customer; end
        (id42 = Object.new).stub(:id).and_return(42)
        Customer.should_receive(:find_all_by_name).with('Fulano').and_return(id42)
        MyClass.should_receive(:find_all_by_customer_id_and_field).with(42, 'value')
        reader = MindReader.new(MyClass) do |r|
          r.lookup(:customer_name, :customer_id) {|name| Customer.find_all_by_name(name).id }
        end
        reader.execute 'field' => 'value', 'customer_name' => 'Fulano'
      end
    end

    describe 'range of values' do
      it 'should accept a range of values' do
        reader = MindReader.new(MyClass) do |r|
          r.range :anything, :start => :any_initial, :end => :any_final
        end
        MyClass.should_receive(:find_all_by_field).with('value',
          :conditions => {:anything => 5..10})
        reader.execute 'field' => 'value', 'any_initial' => 5, 'any_final' => 10
      end
    end

    it 'results of any finding should be returned' do
      class MyClass
        def self.result=(value); @@result = value;end
        def self.method_missing(method_name, *params)
          @@result if method_name.to_s.start_with? 'find'
        end
      end

      reader = MindReader.new(MyClass)
      MyClass.result = 'result value'
      reader.execute('field' => 'value').should == 'result value'
    end

    describe 'omitted fields' do
      it 'should be ignored when calling find' do
        reader = MindReader.new(MyClass)
        MyClass.should_receive(:find_all_by_another_field).with('another_value')
        reader.execute 'field' => '', 'another_field' => 'another_value'
      end
    end
  end
end

