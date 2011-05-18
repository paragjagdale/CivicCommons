require 'spec_helper'

describe ActivityObserver do

  before :all do
    ActiveRecord::Observer.enable_observers
  end

  after :all do
    ActiveRecord::Observer.disable_observers
  end

  context "On create" do
    it 'creates a new activity record when a conversation is created' do
      conversation = Factory.create(:conversation)
      a = Activity.last
      a.item_id.should == conversation.id
      a.item_type.should == 'Conversation'
    end

    it 'creates a new activity record when a issue is created' do
      issue = Factory.create(:issue)
      a = Activity.last
      a.item_id.should == issue.id
      a.item_type.should == 'Issue'
    end

    it 'creates a new activity record when a rating group is created' do
      rating_group = Factory.create(:rating_group)
      a = Activity.last
      a.item_id.should == rating_group.id
      a.item_type.should == 'RatingGroup'
    end

  end

  context "On update" do
    it 'creates a new activity record when a contribution is confirmed'
    it 'creates a new activity record when a rating group is updated'
  end

  context "On destroy" do
    it 'removes activity records when a conversation is deleted/destroyed'
    it 'removes activity records when a issue is deleted/destroyed'
    it 'removes activity records when a contribution is deleted/destroyed'
    it 'removes activity records when a rating group is deleted/destroyed'
  end

end
