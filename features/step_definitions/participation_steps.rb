# def sign_in_as_user(options={}, &block)
#   user = create_user(options)
#   visit_with_option options[:visit], new_user_session_path
#   fill_in 'email', :with => 'user@test.com'
#   fill_in 'password', :with => options[:password] || '123456'
#   check 'remember me' if options[:remember_me] == true
#   yield if block_given?
#   click_button 'Sign In'
#   user
# end

Given /^I am (?:signed|logged) in$/ do
  user = Factory.create(:registered_user)
  visit(new_person_session_url)
  fill_in 'person_email', :with => user.email
  fill_in 'person_password', :with => 'password'

  class ApplicationController
    def after_sign_in_path_for(resource)
      "/"
    end
  end

  click_button 'Login'
end

Given /^I am not (?:signed|logged) in$/ do
  visit(destroy_person_session_url)
end

Given /^a registered user:$/ do |table|
  user = table.rows_hash

  @current_person =
    Factory.create(:registered_user,
                   first_name:           user['First Name'],
                   last_name:            user['Last Name'],
                   email:                user['Email'],
                   avatar:                File.open(File.join(attachments_path, 'imageAttachment.png')),
                   zip_code:             user['Zip'],
                   password:             user['Password'],
                   id:                   user['ID'])

end

Given /^that I am not logged in$/ do
  # Log the User out
  visit(destroy_person_session_url)
end

Then /^the user should be logged in$/ do
  find("#login-status").text.should =~ /#{@current_person.name}/
end

