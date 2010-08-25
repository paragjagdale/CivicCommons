class Person < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :first_name, :last_name, :email, :password, :password_confirmation, :zip_code

  has_many :comments
  has_many :ratings
  has_many :questions
  has_many :answers
  has_and_belongs_to_many :conversations, :join_table => 'conversations_guides', :foreign_key => :guide_id
  has_and_belongs_to_many :events, :join_table => 'events_guides', :foreign_key => :guide_id

  validate :zip_code, :length => 10

  # FIXME: name parsing code is simplistic--won't handle "van Buren" and the like. Drops middle names.
  def name=(value)
    @name = value
    names = value.split(' ')
    self.first_name, self.last_name = names.first, names.last
  end


  def name
    @name ||= "%s %s" % [self.first_name, self.last_name]
  end


end
