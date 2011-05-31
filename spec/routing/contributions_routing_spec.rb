require "spec_helper"

describe ContributionsController do
  describe "routing" do

    it "recognizes and generates #destroy" do
      { delete: "conversations/1/contributions/1" }.should route_to(controller: "contributions", action: "destroy", conversation_id: "1", id: "1")
    end

    it "recognizes and generates #moderate" do
      { delete: "/conversations/1/contributions/1/moderate" }.should route_to(controller: "contributions", action: "moderate", conversation_id: "1", id: "1")
    end

    it "recognizes and generates #created_confirmed_contribution" do
      { post: "/contributions/create_confirmed_contribution"}.should route_to(controller: "contributions", action: "create_confirmed_contribution")
    end

    it "recognizes and generates #edit" do
      { get: "/conversations/1/contributions/1/edit" }.should route_to(controller: "contributions", action: "edit", conversation_id: "1", id: "1")
    end

    it "recognizes and generates #update" do
      { put: "/conversations/1/contributions/1" }.should route_to(controller: "contributions", action: "update", conversation_id: "1", id: "1")
    end

  end
end
