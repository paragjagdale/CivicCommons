require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

WebMock.allow_net_connect!
# Capybara.register_driver :selenium do |app|
#   Capybara::Driver::Selenium.new(app, :browser => :chrome)
# end
Capybara.default_wait_time = 10


feature "Voting Admin", %q{
  In order to Administer Votes
  As a an Admin user
  I want to access the survey admin feature
} do

  def given_logged_in_as_admin
    @user = logged_in_as_admin
  end
  
  def given_an_existing_issue
    @issue = Factory.create(:issue)
  end
  
  let(:admin_surveys_page){ AdminSurveysPage.new(page)} 
  let(:admin_new_survey_page){AdminNewSurveyPage.new(page)}
    

  scenario "See an option to add a survey" do
    # Given that I am an admin    
    given_logged_in_as_admin
    
    # When I go to the admin page
    admin_surveys_page.visit
    
    # Then I will see an option to add a survey
    admin_surveys_page.should have_link 'New Survey', :href => new_admin_survey_path
    admin_surveys_page.should have_link 'Add Survey', :href => new_admin_survey_path
  end
  
  scenario "Survey and Survey option sections" do
    # Given that I am an admin
    given_logged_in_as_admin
    
    # And I am on the admin page
    admin_surveys_page.visit
    
    # When I click on add survey
    admin_surveys_page.click_new_survey
    
    # Then I should see a new survey form
    admin_new_survey_page.should have_selector("form", :action => admin_surveys_path, :method => "post")
    
    # and there will be two parts survey and survey options
    admin_new_survey_page.should have_selector("form", :action => admin_surveys_path, :method => "post") do |form|
      form.should have_selector("input#survey_title", :name => "survey[title]")
      form.should have_selector("input#survey_options_attributes_0_title", :name => "survey[options_attributes][0][title]")
    end
  end
  
  scenario "filling in the survey informations" do
    # Given that I am an admin
    given_logged_in_as_admin
    
    # And I have an existing Issue
    given_an_existing_issue
    
    # When I am on the survey form
    admin_new_survey_page.visit
    
    # And I must fill in: title,and end date
    admin_new_survey_page.fill_in(:title, :with => 'Title here')
    admin_new_survey_page.select_date('end_date', :with => 1.week.from_now.to_date.to_s)
    
    # and max options defaults to three unless reset by admin
    admin_new_survey_page.should have_field(:max_selected_option,:value => 3)
    
    # and I can set the survey as show progress or not (it defaults as off)
    admin_new_survey_page.should have_field(:show_progress,:value => nil)
    
    # and I can set a start date
    admin_new_survey_page.select_date('start_date', :with => 1.day.ago.to_date.to_s)
    
    # and I can make it surveyable to an existing Issue or a Conversation on the site
    admin_new_survey_page.fill_in(:surveyable_type, :with => Issue)
    admin_new_survey_page.fill_in(:surveyable_id, :with => @issue.id)
    
    # and I click submit
    admin_new_survey_page.click_create_survey
        
    # Then the survey should be successfully created
    page.should contain 'Survey was successfully created.'
  end
  
  scenario "Create the survey options" do
    # Given that I am an admin
    given_logged_in_as_admin
    
    # When I am on the survey form
    admin_new_survey_page.visit
    
    # And I have filled in the Survey related fields
    admin_new_survey_page.fill_in_survey_fields
    
    # Then I can create option title
    admin_new_survey_page.should have_selector('input#survey_options_attributes_0_title')
    admin_new_survey_page.fill_in('survey[options_attributes][0][title]', :with => 'title here')
    
    # and I can use a wyswig editor to create option descriptions
    admin_new_survey_page.fill_in('survey[options_attributes][0][description]', :with => 'description here')
    
    # and I can assign the option position to sort how it appears in default
    admin_new_survey_page.fill_in('survey[options_attributes][0][position]', :with => 1)
    
    # When I click on the create button
    admin_new_survey_page.click_create_survey
    
    # Then the survey should be created
    Survey.count.should == 1
    
    # And the Survey option should be created
    Survey.last.options.count.should == 1
  end
  
  scenario "redirecting to the admin's survey info page" do
    # Given that I am an admin who has completed creating a survey
    given_logged_in_as_admin
    admin_new_survey_page.visit
    admin_new_survey_page.fill_in_survey_fields
    
    # When I click on the ‘create survey’ button
    admin_new_survey_page.click_create_survey
    
    # Then I should be redirected to the survey information page in the admin section
    page.should contain 'Survey was successfully created.'
    page.should contain 'Title here'
  end
  
  scenario "Getting to a survey page and editing it" do
    # Given that I am an admin who has completed creating a survey 
    given_logged_in_as_admin
    admin_new_survey_page.visit
    admin_new_survey_page.fill_in_survey_fields
    admin_new_survey_page.click_create_survey
    
    # When I select the survey in the admin survey list
    admin_surveys_page.visit
    admin_surveys_page.click_edit_on_a_survey(Survey.last)
    
    # Then I can get to the survey page and edit it
    page.should contain 'Editing survey'
    page.should have_selector("form", :action => admin_survey_path(Survey.last), :method => "post") do |form|
      form.should have_selector("input#survey_title", :name => "survey[title]")
      form.should have_selector("input#survey_options_attributes_0_title", :name => "survey[options_attributes][0][title]")
    end    
  end
  
  scenario  do
    pending 'needs clarification'
    # Given that I am an admin who has completed creating a survey
    # When I click on the ‘create survey’ button
    # Then I should be redirected to the admins survey page
  end
end
