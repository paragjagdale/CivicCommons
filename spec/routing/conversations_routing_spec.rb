require "spec_helper"

describe ConversationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { get: "/conversations" }.should route_to(controller: "conversations", action: "index")
    end

    it "recognizes and generates #rss" do
      { get: "/conversations/rss" }.should route_to(controller: "conversations", action: "rss")
    end

    it "recognizes and generates #show" do
      pending "BUG IN RAILS PREVENTS THIS FROM PASSING, BUG ONLY AFFECTS TESTS, NOT ACTUAL APP...
      Should be re-enabled when bug is fixed. Bug described:
      https://github.com/rspec/rspec-rails/issues/issue/239
      https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5805"
      { :get => "/conversations/1" }.should route_to(:controller => "conversations", :action => "show", :id => "1")
    end

    it "recognizes and generates #node_conversation" do
      { get: "/conversations/node_conversation" }.should route_to(controller: "conversations", action: "node_conversation")
    end

    it "recognizes and generates #node_permalink" do
      { get: "/conversations/node_permalink/1" }.should route_to(controller: "conversations", action: "node_permalink", id: "1")
    end

    it "recognizes and generates #new_node_contribution" do
      { get: "/conversations/new_node_contribution" }.should route_to(controller: "conversations", action: "new_node_contribution")
    end

    it "recognizes and generates #preview_node_contribution" do
      { get: "/conversations/preview_node_contribution" }.should route_to(controller: "conversations", action: "preview_node_contribution")
    end

    it "recognizes and generates #confirm_node_contribution" do
      { put: "/conversations/confirm_node_contribution" }.should route_to(controller: "conversations", action: "confirm_node_contribution")
    end

    it "recognizes and generates #new" do
      pending "BUG IN RAILS PREVENTS THIS FROM PASSING, BUG ONLY AFFECTS TESTS, NOT ACTUAL APP..."
      { :get => "/conversations/new" }.should route_to(:controller => "conversations", :action => "new")
    end

    it "recognizes and generates #create" do
      { :post => "/conversations" }.should route_to(:controller => "conversations", :action => "create")
    end

    it "recognizes and generates #create_from_blog_post" do
      { :post => "/conversations/blog/1" }.should route_to(:controller => "conversations", :action => "create_from_blog_post", id: "1")
    end

    it "recognizes and generates #create_from_radioshow" do
      { :post => "/conversations/radio/1" }.should route_to(:controller => "conversations", :action => "create_from_radioshow", id: "1")
    end

    Conversation.available_filter_names.each do |filter_name|
      it "recognizes and generates #filter route for :#{filter_name} filter" do
        { :get => "/conversations/#{filter_name}" }.should route_to(:controller => "conversations", :action => "filter", :filter => filter_name)
      end
    end

  end
end
