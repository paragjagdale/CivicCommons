require 'spec_helper'

describe InvitesController do

  before(:each) do
    @admin = Factory.create(:admin_person)
    @conversation = Factory.create(:conversation)
    controller.stub!(:current_person).and_return(@admin)
    @person = Factory.create(:normal_person)
  end

  context "new" do
    it "sets the source type, source id and conversation for the new form page" do
      get :new, source_type: 'conversations', source_id: @conversation.id

      assigns(:source_type).should == 'conversations'
      assigns(:source_id).should == @conversation.id
      assigns(:conversation).should == @conversation
    end

    context "XHR" do
      it "renders a parital for XHR request" do
        xhr :get, :new, source_type: 'conversations', source_id: @conversation.id
        response.should render_template(:partial => 'invites/_form')
      end
    end

    context "not XHR" do
      it "renders regular layout" do
        get :new, source_type: 'conversations', source_id: @conversation.id
        response.should render_template('layouts/application')
      end
    end
  end

  context "create" do
    it "sets the source type, source id and conversation for the create page and then send off email for a valid email." do
      put :create, source_type: 'conversations', source_id: @conversation.id, :invites => {emails: 'someemail@example.com'}

      assigns(:source_type).should == 'conversations'
      assigns(:source_id).should == @conversation.id
      assigns(:conversation).should == @conversation
      assigns(:notice).should == "Thank you! You're helping to make Northeast Ohio stronger!"
    end

    it "sets an error message when email is too short" do
      put :create, source_type: 'conversations', source_id: @conversation.id, :invites => {emails: 's@e.c'}
      assigns(:error).should == "There was a problem with the entered emails."
    end
  end

end
