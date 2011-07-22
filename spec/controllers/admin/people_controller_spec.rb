require 'spec_helper'

describe Admin::PeopleController, "locking/unlocking" do

  before(:each) do
    @admin = Factory.create(:admin_person)
    controller.stub!(:current_person).and_return(@admin)
    @person = Factory.create(:normal_person)
  end

  it "should allow locking of a person" do
    put 'lock_access', {:id => @person.id}

    response.should be_redirect

    @person.reload
    @person.locked_at.should_not be_nil
  end

  it "should allow unlocking of a person" do
    @person.lock_access!

    put 'unlock_access', {:id => @person.id}

    response.should be_redirect

    @person.reload
    @person.locked_at.should be_nil
  end

  describe "PUT: confirm" do

    it "Confirms user" do
      person = mock_model(Person)
      Person.stub(:find).with('1').and_return(person)
      person.should_receive(:confirm!)

      put :confirm, id: '1'
    end

    it "redirects to the admin people page" do
      person = mock_model(Person)
      Person.stub(:find).with('1').and_return(person)
      person.should_receive(:confirm!)

      put :confirm, id: '1'
      controller.should redirect_to(admin_people_path)
    end

  end

  describe "changing a person's Admin role" do
    it "should be successful when the current person is an admin" do
      put :update, id: @person.id, :person =>{:admin=>true}
      @person.reload
      @person.admin.should be_true
    end
    
    it "should not be successful when the current person is not an admin" do
      @admin.admin = false
      @admin.save
      put :update, id: @person.id
      @person.reload
      @person.admin.should be_false
    end
    
    it "should not be successful if there is no admin parameter" do
      put :update, id: @person.id
      @person.reload
      @person.admin.should be_false
      
    end
  end
end
