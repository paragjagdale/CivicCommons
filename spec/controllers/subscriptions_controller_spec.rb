require 'spec_helper'
include ControllerMacros

describe SubscriptionsController do

  before(:each) do
    @conversation = Factory.create(:conversation)
  end

  context "subscribe" do
    it "redirects user to login page if not logged in" do
      get :subscribe, type: 'conversation', id: 1
      response.should redirect_to "http://test.host/people/login"
    end

    it "subscribes a user to a conversation" do
      login_user
      Subscription.should_receive(:subscribe)
      get :subscribe, type: 'conversation', id: 1

      response.should render_template(:partial => 'subscriptions/_subscribed')
    end
  end

  context "unsubscribe" do
    it "redirects user to login page if not logged in" do
      get :unsubscribe, type: 'conversation', id: 1
      response.should redirect_to "http://test.host/people/login"
    end

    it "unsubscribes a user to a conversation" do
      login_user
      Subscription.should_receive(:unsubscribe)
      get :unsubscribe, type: 'conversation', id: 1

      response.should render_template(:partial => 'subscriptions/_notsubscribed')
    end
  end

end
