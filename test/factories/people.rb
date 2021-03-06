FactoryGirl.define do |f|
  factory :invalid_person, :class=>Person do |u|
    u.first_name ''
    u.last_name ''
    u.zip_code '44313'
    u.password 'password'
    u.email ''
    u.skip_email_marketing true
  end

  factory :normal_person, :class=>Person do |u|
    u.first_name 'John'
    u.last_name 'Doe'
    u.zip_code '44313'
    u.password 'password'
    u.sequence(:email) {|n| "test.account#{n}@mysite.com" }
    f.sequence(:cached_slug) {|n| "john-doe--#{n}" }
    u.skip_email_marketing true
    u.daily_digest false
    u.avatar_url '/images/avatar_70.gif'
  end
  factory :registered_user, :parent => :normal_person do |u|
    u.confirmed_at { Time.now }
    u.skip_email_marketing true
  end

  factory :sequence_user, :parent => :registered_user do |u|
    u.sequence(:id)
  end

  factory :person_without_zip_code, :parent => :registered_user do |u|
    u.zip_code nil
    to_create do |instance|
      instance.save :validate=>false
    end
  end
  factory :registered_user_with_avatar, :parent => :registered_user do |u|
    u.avatar File.new(Rails.root + 'test/fixtures/images/test_image.jpg')
  end
  factory :person, :parent => :registered_user do | u |
    u
  end
  factory :admin_person, :parent => :registered_user do |u|
    u.password 'password'
    u.sequence(:email) {|n| "test.admin.account#{n}@mysite.com" }
    u.sequence(:last_name) {|n| "Doe #{n}" }
    u.admin true
    u.skip_email_marketing true
    u.confirmed_at '2011-03-04 15:33:33'
  end
  factory :admin, :parent => :admin_person do |u|
    u
  end

  factory :marketable_person, :parent => :registered_user do |u|
    u.password 'password'
    u.sequence(:email) {|n| "test.account#{n}@mysite.com" }
    u.skip_email_marketing false
    u.marketable ""
  end

end
