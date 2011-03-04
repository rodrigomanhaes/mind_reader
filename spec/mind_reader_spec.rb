require File.join(File.dirname(__FILE__), 'spec_helper')

feature MindReader do
  background do
    @robin = Customer.create! :name => 'Damian Wayne',
                              :address => 'Wayne Manor, Gotham City',
                              :age => 14,
                              :summary => 'He is a dark Robin',
                              :date_of_heroic_birth => Date.new(2010, 6, 2)
    @batman = Customer.create! :name => 'Dick Grayson',
                               :address => 'Wayne Manor, Gotham City',
                               :sidekick_id => @robin.id,
                               :age => 26,
                               :summary => "He is a happy Batman",
                               :date_of_heroic_birth => Date.new(2010, 4, 21)
    @superman = Customer.create! :name => 'Kal-El',
                                 :address => 'Kandor, New Krypton',
                                 :age => 36,
                                 :summary => "He's not anymore the last son of Krypton",
                                 :date_of_heroic_birth => Date.new(1997, 10, 10)


    @reader = MindReader.new(Customer)
  end

  scenario 'full field content' do
    result = @reader.execute(:address => 'Wayne Manor, Gotham City')
    result.should have(2).bat_heroes
    result.should include(@batman, @robin)
  end

  scenario 'full content for multiple fields' do
    @reader.execute(:address => 'Wayne Manor, Gotham City',
      :name => 'Dick Grayson').should == [@batman]
  end

  context 'partial content' do
    scenario 'for string fields' do
      result = @reader.execute(:name => 'ay')
      result.should have(2).super_heroes
      result.should include(@batman, @robin)
    end

    scenario 'for text (a.k.a. memo) fields' do
      result = @reader.execute(:summary => ' is ')
      result.should have(2).super_heroes
      result.should include(@batman, @robin)
    end
  end

  scenario 'omitted fields are ignored' do
    @reader.execute(:name => 'Kal-El', :address => '').should == [@superman]
  end

  scenario 'if no value is given, returns nil by default' do
    @reader.execute(:name => '', :address => '').should be_nil
  end

  scenario 'configuration to return all the records if no value is given' do
    @reader.retrieve_all_when_no_value_is_given = true
    result = @reader.execute(:name => '', :address => '')
    result.should have(3).super_heroes
    result.should include(@batman, @robin, @superman)
  end

  scenario 'lookup fields' do
    @reader = MindReader.new(Customer) do |r|
      r.sidekick_id(:lookup => :sidekick_name) {|name| Customer.find_by_name(name).id }
    end
    @reader.execute(:sidekick_name => 'Damian Wayne').should == [@batman]
  end

  context 'range' do
    scenario 'with numeric fields' do
      reader = MindReader.new(Customer) do |r|
        r.age :range => :start_age..:end_age
      end
      reader.execute('start_age' => 25, 'end_age' => 36).should == [@batman, @superman]
    end

    scenario 'with date fields' do
      reader = MindReader.new(Customer) do |r|
        r.date_of_heroic_birth :range => :start_date..:end_date
      end
      result = reader.execute('start_date' => Date.new(2010, 1, 1), 'end_date' => Date.new(2010, 12, 31))
      result.should have(2).items
      result.should include(@batman, @robin)
    end
  end
end

