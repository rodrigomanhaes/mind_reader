MindReader: Easy searching for ActiveRecord applications
========================================================

MindReader is at a very early stage. At this moment, it's only an experiment.


Find by one field::

result = MindReader.new(MyClass, :field).do_it('field' => 'value')


Find by multiple fields::

    result = MindReader.new(MyClass, :field, :another_field, :another_other_field).
               do_it('field' => 'value for',
                     'another_field' => 'value for another',
                     'another_other_field' => 'value for another other')


Find with lookup::

    reader = MindReader.new(MyClass, :field, :customer_id) do |r|
      r.customer_id(:lookup_field => :customer_name) {|name| Customer.find_all_by_name(name).id }
    end
    result = reader.do_it 'field' => 'value', 'customer_name' => 'Fulano'



Find given a range::

    reader = MindReader.new(MyClass, :field, :anything) do |r|
      r.anything :range => 5..10, :start => :any_initial, :end => :any_final
    end
    result = reader.do_it 'field' => 'value', 'any_initial' => 5, 'any_final' => 10

