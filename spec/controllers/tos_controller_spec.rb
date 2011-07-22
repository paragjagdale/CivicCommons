require 'spec_helper'
include ControllerMacros

describe TosController do

  before(:each) do
    @contribution = Factory.create(:comment)
  end

  context "new" do
    it "redirects user to login page if not logged in" do
      get :new, {:contribution_id => 2}
      response.should redirect_to "http://test.host/people/login"
    end

    it "sets the source type, source id and conversation for the new form page" do
      login_user
      get :new, {:contribution_id => 2}

      assigns(:contribution).should == 2
    end

    context "XHR" do
      it "renders a parital for XHR request" do
        login_user
        xhr :get, :new, :contribution_id => 2
        response.should render_template(:partial => 'tos/_tos_contribution_form')
      end
    end

    context "not XHR" do
      it "renders regular layout" do
        login_user
        get :new, contribution_id: @contribution.id
        response.should render_template(:partial => 'tos/_tos_contribution_form')
      end
    end
  end

  context "create" do
    it "will send a tos email out" do
      login_user
      post :create, {:contribution_id => @contribution.id, :tos => {:reason => "This is a test reason"}}

      assigns(:contribution).should == @contribution
      assigns(:notice).should be_true
    end

    it "will error out if no reason is given" do
      login_user
      post :create, {:contribution_id => @contribution.id, :tos => {:reason => ""}}

      assigns(:contribution).should == @contribution
      assigns(:error).should be_true
    end

  end
end
