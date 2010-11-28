require File.join(File.dirname(__FILE__), 'spec_helper')

feature "MindReader acceptance" do
  background do
    @robin = Customer.create! :name => 'Damian Wayne', :address => 'Wayne Manor, Gotham City'
    @batman = Customer.create! :name => 'Dick Grayson', :address => 'Wayne Manor, Gotham City',
                               :sidekick_id => @robin.id
    @superman = Customer.create! :name => 'Kal-El', :address => 'Kandor, New Krypton'

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
end

