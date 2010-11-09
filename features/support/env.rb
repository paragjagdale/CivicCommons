# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'cucumber/rails/world'
require 'cucumber/rails/active_record'
require 'cucumber/web/tableish'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'
require 'cucumber/rails/capybara_javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript

require 'ruby-debug'

require 'webmock'

require File.dirname(__FILE__) + '/words_to_num'



def cleanup_shadow_accounts
  person = PeopleAggregator::Person.find_by_email("joe@test.com")
  person.destroy if person
  person = PeopleAggregator::Person.find_by_email("joe@duplicate.com")
  person.destroy if person
end

World(WebMock::API)

include WebMock::API

stub_request(:any, /http:\/\/s3\.amazonaws\.com\/cc-dev\/attachments/)
stub_request(:any, /http:\/\/s3\.amazonaws\.com/)
stub_request(:any, %r{http://www.yahoo.com/}).
  to_return(:body => "<html><title>Yahoo!</title><body></body></html>")
stub_request(:any, %r{http://www.youtube.com/}).
  to_return(:body => "<html><title>YouTube - David Perron Goal vs Islanders - November 21 2009</title><body></body></html>")

After("@api") do |s|
  cleanup_shadow_accounts
end

$encrypted_passwords = Hash.new

Capybara.default_selector = :css

# If you set this to false, any error raised from within your app will bubble 
# up to your step definition and out to cucumber unless you catch it somewhere
# on the way. You can make Rails rescue errors and render error pages on a
# per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
#
# If you set this to true, Rails will rescue all errors and render error
# pages, more or less in the same way your application would behave in the
# default production environment. It's not recommended to do this for all
# of your scenarios, as this makes it hard to discover errors in your application.
ActionController::Base.allow_rescue = false

# If you set this to true, each scenario will run in a database transaction.
# You can still turn off transactions on a per-scenario basis, simply tagging 
# a feature or scenario with the @no-txn tag. If you are using Capybara,
# tagging with @culerity or @javascript will also turn transactions off.
#
# If you set this to false, transactions will be off for all scenarios,
# regardless of whether you use @no-txn or not.
#
# Beware that turning transactions off will leave data in your database 
# after each scenario, which can lead to hard-to-debug failures in 
# subsequent scenarios. If you do this, we recommend you create a Before
# block that will explicitly put your database in a known state.
Cucumber::Rails::World.use_transactional_fixtures = true

module Config

  def attachments_path
    File.expand_path(File.dirname(__FILE__) + '/attachments')
  end

end


World(Config)
World(WordsToNum)

# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16: 
# warning: regexp match /.../n against to UTF-8 string
$VERBOSE = nil

