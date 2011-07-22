require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Search the web site", %q{
  As a user of The Civic Commons
  I want to search
  So that I can find an issue, conversation or person I am interested in
} do

  scenario "User can search The Civic Commons" do
    # Given I am on the home page
    visit root_path
    # And I type what I want to find into the top search box
    fill_in('q', :with => 'town')
    # And I don't filter the results
    # When I click search
    click_button('Search')

    # I should be sent to the results page
    should_be_on search_results_path

    # Where I will see results of my search
  end

=begin 
# sunspot_test way
  describe "searching", :search => true do
    it 'returns conversation results' do
      conversation = Factory(:conversation, :title => "Townhall is the talk")
      Sunspot.commit
      Conversation.search { keywords "talk"}.results.should == [conversation]
    end
  end
=end

end
