require 'spec_helper'

module Admin
  describe IssuesController do

    before(:each) do
      sign_in Factory.create(:admin_person)
    end

    describe "GET index" do

      before(:each) do
        @issues = {}
        (1..5).each do 
          issue = Factory.create(:issue)
          @issues[issue.id] = issue
        end
      end

      it "assigns all issues as @issues" do
        get :index
        assigns[:issues].size.should == @issues.size
      end

    end

    describe "GET show" do

      let(:issue) do
        Factory.create(:issue)
      end

      it "assigns the requested issue as @issue" do
        get :show, :id => issue.id.to_s
        assigns[:issue].should eq issue
      end

    end

    describe "GET new" do

      it "assigns a new issue as @issue" do
        get :new
        assigns[:issue].should_not be_nil
      end

    end

    describe "GET edit" do

      let(:issue) do
        Factory.create(:issue)
      end

      it "assigns the requested issue as @issue" do
        get :edit, :id => issue.id.to_s
        assigns[:issue].should eq issue
      end

    end

    describe "POST create" do

      describe "with valid params" do

        let(:params) do
          Factory.attributes_for(:issue)
        end

        before(:each) do
          post :create, :issue => params
        end

        it "assigns a newly created issue as @issue" do
          assigns[:issue].name.should eq params[:name]
          assigns[:issue].cached_slug.should eq params[:cached_slug]
          assigns[:issue].summary.should eq params[:summary]
        end

        it "redirects to the issues index" do
          response.should redirect_to admin_issues_path
        end

      end

      describe "with invalid params" do

        let(:params) do
          Factory.attributes_for(:issue)
        end

        before(:each) do
          params.delete(:name)
          post :create, :issue => params
        end

        it "assigns a newly created but unsaved issue as @issue" do
          assigns[:issue].summary.should eq params[:summary]
        end

        it "re-renders the 'new' issue" do
          response.should render_template('new')
        end

      end

      describe "with subclasses" do

        it "creates issues" do
          params = Factory.attributes_for(:issue)
          params[:type] = 'Issue'
          post :create, :issue => params
          assigns[:issue].should be_kind_of Issue
          assigns[:issue].type.should == 'Issue'
        end

        it "creates managed issues" do
          params = Factory.attributes_for(:managed_issue)
          params[:type] = 'ManagedIssue'
          post :create, :issue => params
          assigns[:issue].should be_kind_of Issue
          assigns[:issue].type.should == 'ManagedIssue'
        end

      end

    end

    describe "PUT update" do

      let(:issue) do
        Factory.create(:issue)
      end

      let(:new_name) do
        "Some completely different but valid name"
      end

      let(:new_slug) do
        "some-completely-different-but-valid-name"
      end

      let(:params) do
        issue.attributes
      end

      describe "with valid params" do

        before(:each) do
          params['name'] = new_name
          put :update, :id => params['id'], :issue => params
        end

        it "updates the requested issue" do
          Issue.find_by_id(params['id']).name.should eq new_name
        end

        it "assigns the requested issue as @issue" do
          assigns[:issue].id.should eq params['id']
          assigns[:issue].name.should eq new_name
          assigns[:issue].summary.should eq params['summary']
          assigns[:issue].cached_slug.should eq new_slug
        end

        it "redirects to the issues index" do
          response.should redirect_to admin_issues_path
        end

      end

      describe "with invalid params" do

        before(:each) do
          params['name'] = ''
          put :update, :id => params['id'], :issue => params
        end

        it "assigns the issue as @issue" do
          assigns[:issue].id.should eq params['id']
          assigns[:issue].name.should eq params['name']
          assigns[:issue].summary.should eq params['summary']
          assigns[:issue].cached_slug.should eq params['cached_slug']
        end

        it "re-renders the 'edit' issue" do
          response.should render_template('edit')
        end

      end

      describe "with subclasses" do

        it "converts an issue to a managed issue" do
          issue = Factory.create(:issue)
          params = issue.attributes
          params[:type] = 'ManagedIssue'
          put :update, :id => params['id'], :issue => params
          assigns[:issue].should be_kind_of Issue
          assigns[:issue].type.should == 'ManagedIssue'
        end

        it "converts a managed issue to an issue" do
          issue = Factory.create(:managed_issue)
          params = issue.attributes
          params[:type] = 'Issue'
          put :update, :id => params['id'], :managed_issue => params
          assigns[:issue].should be_kind_of Issue
          assigns[:issue].type.should == 'Issue'
        end

      end

    end

    describe "PUT update_order" do
      it "returns an error response if current_position is blank" do
        put :update_order, :current => ''
        response.should_not be_success
      end

      it "returns an error response if current_position is not blank, but next and previous are" do
        Factory.create(:issue, :position => 0)
        put :update_order, :current => '0', :next => '', :prev => ''
        response.should_not be_success
      end

      it "returns a success response if current_position is not blank, and next_position or prev_position or both" do
        Factory.create(:issue, :position => 0)
        Factory.create(:issue, :position => 1)
        Factory.create(:issue, :position => 2)
        put :update_order, :current => '0', :next => '1'
        response.should be_success
        put :update_order, :current => '0', :prev => '1'
        response.should be_success
        put :update_order, :current => '0', :next => '1', :prev => '2'
        response.should be_success
      end

      it "returns an error response if current_position does not exist for an issue" do
        put :update_order, :current => '0'
        response.should_not be_success
      end

      it "returns an error response if next_position does not exist for an issue and previous is not set" do
        Factory.create(:issue, :position => 0)
        put :update_order, :current => '0', :next => '1'
        response.should_not be_success
      end

      it "returns an error response if previous_position does not exist for an issue and next is not set" do
        Factory.create(:issue, :position => 0)
        put :update_order, :current => '0', :prev => '1'
        response.should_not be_success
      end
    end

    describe "DELETE destroy" do

      let(:issue) do
        Factory.create(:issue)
      end

      before(:each) do
        delete :destroy, :id => issue.id
      end

      it "destroys the requested issue" do
        Issue.find_by_id(issue.id).should be_nil
      end

      it "redirects to the issues list" do
        response.should redirect_to(admin_issues_url)
      end

    end

  end
end
