require "highline/import"

desc "Merge two user accounts by passing in their email addresses: from=email1@example.com to=email2@example.com"
task :merge_account, :needs => :environment do
  begin
    from = get_email('from')
  end while not from_person = Person.find_by_email(from)

  begin
    to = get_email('to')
  end while not to_person = Person.find_by_email(to)

  return unless agree("Merging #{from} to #{to}. Correct?")
  if Utilities::PersonUtilities.merge_account(to_person, from_person)
    from_person.destroy
    say 'Merge successful'
  else
    say 'Merge failed'
  end
end

desc "Unlink a user account from Facebook and reset the password"
task :unlink_facebook, :needs => :environment do
  begin
    email = get_email('from')
  end while not person = Person.find_by_email(email)

  begin
    password = get_password('password')
    password_confirmation = get_password('confirm password')
  end while password != password_confirmation

  return unless agree("Unlink #{email} from Facebook and set the password to '#{password}' Correct?")

  params = {
    email: person.email,
    password: password,
    password_confirmation: password
  }
  person.unlink_from_facebook(params)
  
  ok = true
  person.authentications.each do |auth|
    ok = false if auth.provider == 'facebook'
  end

  if ok
    say 'Unlink successful'
  else
    say 'Failed to unlink the user account from Facebook'
  end
  
end

###############################################################################

def get_email(email_type)
  email = ENV[email_type] ? ENV[email_type] : nil
  if email.nil? || !Person.find_by_email(email)
    ask("<%= color('#{email_type.upcase}', BOLD) %> Email?") { |q| q.validate = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/ }
  else
    email
  end
end

def get_password(prompt)
  password = ENV[prompt] ? ENV[prompt] : nil
  if password.nil?
    ask("<%= color('#{prompt.upcase}', BOLD) %> (6 characters minimum)") { |q| q.validate = /\w{6,}/ }
  else
    password
  end
end
