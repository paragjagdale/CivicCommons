require 'spec_helper'

describe ContentItem do

  before(:all) do
    @author = Factory.build(:admin_person)
  end

  before(:each) do
    @attr = Factory.attributes_for(:content_item)
    @attr[:author] = @author
  end

  context "validations" do

    it "creates a valid object" do
      ContentItem.new(@attr).should be_valid
    end

    it "validates the presence of title" do
      @attr.delete(:title)
      ContentItem.new(@attr).should_not be_valid
    end

    it "validates the presence of body" do
      @attr.delete(:body)
      ContentItem.new(@attr).should_not be_valid
    end

    it "validates the presence of published" do
      @attr.delete(:published)
      ContentItem.new(@attr).should_not be_valid
    end

    it "validates the presence of author" do
      @attr.delete(:author)
      ContentItem.new(@attr).should_not be_valid
    end

    it "validates the uniqueness of the title" do
      ContentItem.new(@attr).save
      ContentItem.new(@attr).should_not be_valid
    end

    it "validates the presence of an external link for a news item" do
      @attr[:content_type] = 'NewsItem'
      @attr.delete(:external_link)
      ContentItem.new(@attr).should_not be_valid
    end

  end

  context "custom finders" do

    context "recent_blog_posts" do

      before(:each) do
        @p1 = Factory.create(:admin_person)
        @p2 = Factory.create(:admin_person)
        @b1_1 = Factory.create(:blog_post, author: @p1, published: 1.day.ago, created_at: 1.day.ago)
        @b2_1 = Factory.create(:blog_post, author: @p2, published: 2.days.ago, created_at: 2.days.ago)
        @b2_2 = Factory.create(:blog_post, author: @p2, published: 2.days.ago, created_at: 3.days.ago)
        @b2_3 = Factory.create(:blog_post, author: @p2, published: 3.day.ago, created_at: 3.days.ago)
      end

      it "retrieves all blog posts sorted properly when no author is given" do
        blogs = ContentItem.recent_blog_posts
        blogs.first.id = @b1_1.id
        blogs.last.id = @b2_3.id
      end

      it "retrieves all blog posts by one author sorted properly when author id given" do
        blogs = ContentItem.recent_blog_posts(@p2.id)
        blogs.first.id = @b2_1.id
        blogs.last.id = @b2_3.id
      end

      it "retrieves all blog posts by one author sorted properly when author Person is given" do
        blogs = ContentItem.recent_blog_posts(@p2)
        blogs.first.id = @b2_1.id
        blogs.last.id = @b2_3.id
      end

    end

  end

end
