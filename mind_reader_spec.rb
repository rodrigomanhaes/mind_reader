require 'mind_reader'

describe MindReader do

  class MyClass; end

  describe 'search execution' do

    describe 'plain fields' do
      it 'should execute search for a single field' do
        MyClass.should_receive(:find_all_by_field).with('value')
        MindReader.new(MyClass, :field).do_it('field' => 'value')
      end

      it 'should execute search for multiple fields' do
        MyClass.should_receive(:find_all_by_field_and_another_field_and_another_other_field).
                with('value for', 'value for another', 'value for another other')
        MindReader.new(MyClass, :field, :another_field, :another_other_field).
          do_it('field' => 'value for',
                'another_field' => 'value for another',
                'another_other_field' => 'value for another other')
      end
    end

    describe 'lookup fields' do
      it 'should search by another field' do
        class Customer; end
        (id42 = Object.new).stub(:id).and_return(42)
        Customer.should_receive(:find_all_by_name).with('Fulano').and_return(id42)
        MyClass.should_receive(:find_all_by_field_and_customer_id).with('value', 42)
        reader = MindReader.new(MyClass, :field, :customer_id) do |r|
          r.customer_id(:lookup_field => :customer_name) {|name| Customer.find_all_by_name(name).id }
        end
        reader.do_it 'field' => 'value', 'customer_name' => 'Fulano'
      end

      it 'calling for non-field named methods inside initialize block should raise NoMethodError' do
        lambda {
          reader = MindReader.new(MyClass, :field, :customer_id) do |r|
            r.customer_other_thing({}) do |name|
              puts 'never executed'
            end
          end
        }.should raise_error NoMethodError, /customer_other_thing/
      end
    end

    describe 'range of values' do
      it 'should accept a range of values' do
        reader = MindReader.new(MyClass, :field, :anything) do |r|
          r.anything :range, :start => :any_initial, :end => :any_final
        end
        MyClass.should_receive(:find_all_by_field).with('value',
          :conditions => {:anything => 5..10})
        reader.do_it 'field' => 'value', 'any_initial' => 5, 'any_final' => 10
      end
    end

    it 'results of any finding should be returned' do
      class MyClass
        def self.result=(value); @@result = value;end
        def self.method_missing(method_name, *params)
          @@result if method_name.to_s.start_with? 'find'
        end
      end

      reader = MindReader.new(MyClass, :field)
      MyClass.result = 'result value'
      reader.do_it('field' => 'value').should == 'result value'
    end
  end

end

