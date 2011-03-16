MindReader: Easy searching for ActiveRecord applications
========================================================

Given the following objects::

    @robin = Customer.create! :name => 'Damian Wayne',
                              :address => 'Wayne Manor, Gotham City',
                              :age => 14
    @batman = Customer.create! :name => 'Dick Grayson',
                               :address => 'Wayne Manor, Gotham City',
                               :sidekick_id => @robin.id,
                               :age => 26
    @superman = Customer.create! :name => 'Kal-El',
                                 :address => 'Kandor, New Krypton',
                                 :age => 36


Find by one field::

    reader = MindReader.new(Customer)
    result = reader.execute(:address => 'Wayne Manor, Gotham City')
    result.should have(2).bat_heroes
    result.should include(@batman, @robin)


Find by multiple fields::

    reader = MindReader.new(Customer)
    reader.execute(:address => 'Wayne Manor, Gotham City',
      :name => 'Dick Grayson').should == [@batman]


String fields are evaluated partially::

    result = reader.execute(:name => 'ay')
    result.should have(2).super_heroes
    result.should include(@batman, @robin)


Find with lookup::

    reader = MindReader.new(Customer) do |r|
      r.sidekick_id(:lookup => :sidekick_name) {|name| Customer.find_by_name(name).id }
    end
    reader.execute(:sidekick_name => 'Damian Wayne').should == [@batman]


Find given a range::

    reader = MindReader.new(Customer) do |r|
      r.age :range => :start_age..:end_age
    end
    reader.execute('start_age' => 25, 'end_age' => 36).should == [@batman, @superman]


Blank fields are ignored::

    reader = MindReader.new(Customer)
    reader.execute(:name => 'Kal-El', :address => '').should == [@superman]


If all fields are blank, returns nil::

    reader = MindReader.new(Customer)
    reader.execute(:name => '', :address => '').should be_nil


unless you say you want all objects::

    reader = MindReader.new(Customer)
    reader.retrieve_all_when_no_value_is_given = true
    result = reader.execute(:name => '', :address => '')
    result.should have(3).super_heroes
    result.should include(@batman, @robin, @superman)


mind_reader supports converters for incoming data. For sake of example, imagine
you have to enter a date in a different format (here, dd/mm/yyyy), and you want
to convert it to default yyyy-mm-dd::

      def convert_to_default(br_date)
        br_date =~ /(\d+)\/(\d+)\/(\d+)/
        "%s-%s-%s" % [$3, $2, $1]
      end

      reader = MindReader.new(SuperHero) do |r|
        r.date_of_heroic_birth :range => :from_date..:to_date, :converter => lambda {|d| convert_to_default(d) }
      end
      reader.execute('from_date' => '01/04/2010', 'to_date' => '30/04/2010').should == [@batman]


How to install
--------------

::

    $ gem install mind_reader


How to run specs
----------------

::

    $ rake spec

