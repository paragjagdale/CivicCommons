source 'http://rubygems.org'

gem 'rack', '1.2.1'

gem 'mysql2'

gem 'rails', "3.0.3"

gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'haml'
gem 'date_validator'
gem "will_paginate", "2.3.15"

gem 'httparty'

gem 'geokit'

gem "friendly_id", "~> 3.2.1"
gem 'acts_as_revisionable'
gem 'embedly'

gem 'gibbon'
gem 'hominid', "~>3.0.2"
gem 'delayed_job', ">= 2.1.2"

gem 'hoptoad_notifier'

gem 'remotipart'

gem 'whenever', :require => false

gem 'shoulda'
gem 'paperclip', "2.3.8"
gem 'delayed_paperclip'
gem 'aws-s3'
gem 'nokogiri'
gem 'sanitize'
gem 'highline'

gem 'sunspot_rails', '~> 1.2.1'

# for testing, but needed globally because it add rake tasks
gem 'single_test'

group :development do
  gem "rails3-generators"
  gem "hpricot"
  gem "ruby_parser"
  gem "engineyard"
  gem "ruby-debug19"
end

group :test do
  gem "rack-test", :git => 'git://github.com/econsultancy/rack-test.git', :branch => 'econsultancy-20110119'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
  gem 'cucumber', '~>0.10.0'
  gem "factory_girl_rails", '~>1.0.1'
  gem 'no_peeping_toms', :git => 'git://github.com/alindeman/no_peeping_toms.git'
  gem "ruby-debug19"
  gem 'webmock'
  # Required by WebMock but breaks everything at 2.2.5
  # Can use latest addressable when pull request is accepted: https://github.com/sporkmonger/addressable/pull/33
  gem 'addressable', :git => 'git://github.com/gkellogg/addressable.git', :branch => 'frozen-uri'
  gem 'linguistics'
  gem 'fuubar', '~>0.0.3'
  gem "cucumber-rails", "0.4.0.beta.1"
  gem "database_cleaner", "~> 0.6.0"
  gem 'email_spec'
  gem 'simplecov'
  gem 'timecop'
end

# On non-osx platforms, use: bundle install --without osx_test
# group :osx_test do
#   gem 'autotest-fsevent'
#   gem 'autotest-growl'
# end

group :development, :test do
  gem "rspec-rails", "~> 2.5.0"
  gem 'steak'
  gem "capybara", "~> 0.4.0"
  gem "launchy"
  gem 'webrat', "~> 0.7.3"
end

gem 'devise', :git => 'git://github.com/plataformatec/devise.git', :branch => 'v1.3'
gem "oa-oauth", :require => "omniauth/oauth"
gem 'omniauth', '~>0.2.0', :git => 'git://github.com/intridea/omniauth.git'

gem 'shoulda'
gem 'paperclip', "2.3.8"
gem 'delayed_paperclip'
gem 'aws-s3'
gem 'nokogiri'
