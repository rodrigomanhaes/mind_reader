require File.join(File.dirname(__FILE__), 'spec_helper')

feature "read minds" do
  scenario 'ordinary fields' do
    Customer.all.should be_empty
  end
end

