class ContentItem < ActiveRecord::Base
  attr_accessor :url_slug

  CONTENT_TYPES = ["BlogPost", "NewsItem", "RadioShow"]

  belongs_to :author, :class_name => "Person", :foreign_key => "person_id"
  belongs_to :conversation

  validates_presence_of :title, :body, :author
  validates_uniqueness_of :title

  validates_format_of :external_link, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, :allow_blank => true
  validates_presence_of :external_link, :if => :content_type_is_news_item?

  validates :published, :date => {:after => Proc.new {Time.now - 1.year} }

  has_friendly_id :title, :use_slug => true, :strip_non_ascii => true

  def self.recent_blog_posts(author = nil)
    if author.nil?
      ContentItem.where("content_type = 'BlogPost' AND (published <= curdate() OR DAY(published) = DAY(curdate())) ").order("published desc, created_at desc")
    else
      author = author.id if author.is_a? Person
      ContentItem.where(person_id: author).where("content_type = 'BlogPost' AND (published <= curdate() OR DAY(published) = DAY(curdate())) ").order("published desc, created_at desc")
    end
  end

private

  def content_type_is_blog_post?
    content_type == "BlogPost"
  end

  def content_type_is_news_item?
    content_type == "NewsItem"
  end

  def content_type_is_radio_show?
    content_type == "RadioShow"
  end
end
