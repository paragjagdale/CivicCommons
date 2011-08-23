require 'parent_validator'

class Contribution < ActiveRecord::Base
  include Visitable

  searchable :ignore_attribute_changes_of => [ :total_visits, :recent_visits, :last_visit_date, :updated_at, :recent_rating ] do
    text :title, :default_boost => 1
    text :description, :stored => true
    text :content, :stored => true
  end

  attr_accessor :top_level

  # nested contributions are destroyed via callbacks
  acts_as_nested_set :exclude_unless => {:confirmed => true}, :dependent => :destroy
  acts_as_revisionable
  profanity_filter :content, :method => 'hollow'
  attr_accessor :moderation_reason

  belongs_to :person, :foreign_key => "owner"
  belongs_to :conversation
  belongs_to :issue
  has_many   :rating_groups, :dependent => :destroy

  #############################################################################
  # Validations

  validates :item, :presence => true

  # In a perfect world a contribution would require an owner. Unfortunately,
  # there is some complexity to the way we create the first contribution when
  # creating a new community-generated conversation. This prevents proper
  # validation of the owner during contribution creation.
  # -Jerry
  #validates :person, :presence => true
  validate :requires_an_owner

  validate :requires_content_or_link

  def requires_an_owner
    self.errors[:person] << "Must have an owner" if self.person.nil? and self.item.is_a?(Issue)
  end

  def requires_content_or_link
    self.errors[:content] << "Comment cannot be blank" if self.content.blank? and self.url.blank?
  end

  def self.valid_attributes?(attributes)
    mock = self.new(attributes)
    unless mock.valid?
      return mock.errors.select{|k,v| attributes.keys.collect(&:to_sym).include?(k)}.size == 0
    end
    true
  end

  #############################################################################
  # Embedly

  validates_format_of :url, :with => URI::regexp(%w(http https)), :allow_blank => true

  validates_presence_of :embedly_code, :unless => 'url.blank?'
  validates_presence_of :embedly_type, :unless => 'url.blank?'

  def base_url
    match = /^(?<base_url>http[s]?:\/\/(\w|[^\?\/:])+(:\d+)?).*$/i.match(url)
    return match.nil? ? nil : match[:base_url]
  end

  def has_media?
    not self.embedly_code.blank?
  end

  #############################################################################
  # Paperclip

  # supported files:
  # xls, ppt, pdf, doc, txt, xlsx, docx, pptx, rtf, jpg, png

  has_attached_file :attachment,
    :storage => :s3,
    :s3_credentials => S3Config.credential_file,
    :path => IMAGE_ATTACHMENT_PATH,
    :styles => {:thumb => "75x75>", :medium => "300x300>", :large => "800x800>"}

  before_attachment_post_process :is_image?

  # Return true if attachment is an image
  # Returns false if it is not an image
  # Does not return nil since before_attachment_post_process relies requires
  # true or false
  def is_image?
    !(attachment_content_type =~ /^image.*/).nil?
  end

  def has_attachment?
    not self.attachment_file_name.blank?
  end

  #############################################################################
  # Scopes

  scope :most_recent, {:order => 'created_at DESC'}
  scope :not_top_level, where("top_level_contribution = 0")
  scope :without_parent, where(:parent_id => nil)
  scope :confirmed, where(:confirmed => true)
  scope :unconfirmed, where(:confirmed => false)

  # Scope for contributions that are still editable, i.e. no descendants and less than 30 minutes old
  scope :editable, where(["created_at >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 MINUTE)"])
  scope :for_conversation, lambda { |convo|
    confirmed.
      where(:conversation_id => convo.id).
      includes([:person]).
      order('contributions.created_at ASC')
  }

  #############################################################################
  # Confirmation

  after_initialize :set_confirmed, :if => :new_record? # sets confirmed to false by default when object created
  before_validation :set_person_from_item, :if => :person_blank?

  attr_reader :override_confirmed

  #############################################################################
  # Construction/Destruction

  def self.update_or_create_node(params,person)
    if contribution = Contribution.unconfirmed.where(:parent_id => params[:parent_id], :owner => person.id).first
      contribution.update_attributes(params)
    else 
      contribution = Contribution.create_node(params,person)
    end
    return contribution
  end

  def self.new_node(params, person, confirmed = false)
    params.merge!( { :person => person, :override_confirmed => confirmed } )
    Contribution.new(params)
  end

  def self.create_node(params, person, confirmed = false)
    params.merge!( { :person => person, :override_confirmed => confirmed } )
    Contribution.create(params)
  end

  def self.delete_old_and_unconfirmed(age = 30.minutes)
    count = self.unconfirmed.where(["created_at < ?", (Time.now - age)]).count
    self.unconfirmed.destroy_all(["created_at < ?", (Time.now - age)])
    return count
  end

  def destroy_by_user(user)
    if self.editable_by?(user)
      self.destroy
    else
      self.errors[:base] << "Contributions cannot be deleted if they are older than 30 minutes or have any responses."
      return false
    end
  end

  #############################################################################
  # Finders

  def self.find_or_new_unconfirmed(params,person)
    attrs = {
      :conversation_id => params[:id],
      :parent_id => params[:contribution_id],
      :owner => person.id
    }
    return Contribution.unconfirmed.editable.where(attrs).first || Contribution.new(attrs)
  end

  #############################################################################
  # Item

  def item=(item)
    conversation = nil
    issue = nil
    if item.is_a?(Conversation)
      self.conversation = item
    elsif item.is_a?(Issue)
      self.issue = item
    end
  end

  def item
    self.conversation || self.issue
  end

  #############################################################################
  # Special Attributes

  def comment_only?
    self.url.blank? and self.attachment_file_name.blank?
  end

  # The redundancy here is legacy, refactor when you have time - Jerry
  def top_level=(value)
    self.top_level_contribution = (true & value)
  end

  def top_level
    self.top_level_contribution
  end

  def top_level_contribution?
    self.top_level_contribution
  end

  def unconfirmed?
    !self.confirmed
  end

  def confirm!
    self.update_attribute(:confirmed, true)
  end

  def override_confirmed=(value)
    self.confirmed = @override_confirmed = (true & value)
  end

  #############################################################################
  # Edit/Moderate/Delete

  def update_attributes_by_user(params, user)
    if self.editable_by?(user)
      if params.has_key?(:contributions)
        self.update_attributes(params[:contributions])
      else
        self.update_attributes(params[:contribution])
      end
    else
      self.errors[:base] << "Contributions cannot be edited if they are older than 30 minutes or have any responses."
      return false
    end
  end

  def editable_by?(user = nil)
    if user && (user.admin? || owner_editable?(user))
      true
    else
      false
    end
  end

  def moderate_content(params, moderated_by)
   reason = params[:contribution][:moderation_reason]
   self.content = "<b><i>Contribution removed by #{moderated_by.name} on #{Time.now.strftime('%B %d, %Y')}, for the following reason: #{reason}</i></b>"
   self.clear_attributes
   self.save(validate: false)
  end

  def clear_attributes
    if respond_to?(:attachment)
      destroy_attached_files
    end
    [:url=, :embedly_type=, :embedly_code=, :title=, :description=].each do |attribute|
      self.send(attribute, nil)
    end
  end

  def attachment_url
    if self.attachment_file_name
      if self.is_image?
        attachment.url(:thumb).gsub(/\?\d+$/, '')
      else
        attachment.url.gsub(/\?\d+$/, '')
      end
    else
      ''
    end
  end

  def owner_editable?(user)
    if self.owner == user.id && self.created_at > 30.minutes.ago && self.descendants_count == 0 && self.rating_groups.empty?
      true
    else
      false
    end
  end

  #############################################################################

  protected

  def set_confirmed
    self.confirmed = self.override_confirmed || self.top_level_contribution? ? true : 0
    # RAILS BUG - ActiveRecord::RecordNotSaved if set to false, but works for true, 1, and 0
  end

  def url_title
    if self.url
      self.title
    else
      ''
    end
  end

  def person_blank?
    self.person.blank?
  end

  def set_person_from_item
    self.person = item.person unless item.nil?
  end

end
