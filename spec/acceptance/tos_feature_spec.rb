require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Report Terms of Service Violation", %q{
  As a registered user,
  I want to report content that violates the Terms of Service
  So that action can be taken by site management
} do

  # Given a registered user
  let :user do
    Factory :registered_user
  end

  # Given a top level contribution for the conversation
  let :comment do
    Factory.create(:comment, :override_confirmed => true, :content => "That's pretty crazy.  That's can't be true.  Can it?")
  end

  # Given a valid conversation
  let :convo do
    comment.conversation
  end

  # Given a valid issue
  let :issue do
    Factory :issue
  end

  let :conversation_page do
    ConversationsPage.new(page)
  end

  background do
    # Given the registered user is logged in
    LoginPage.new(page).sign_in(user)

    # Given a conversation and comment
    comment
  end

  scenario "Display the Report Abuse text" do
    # When I visit a conversation page
    conversation_page.visit_conversations(convo)

    page.should have_link("Alert us.")
  end

end
