require 'spec_helper'

describe Contribution do

  describe "when creating a TopLevelContribution for a conversation" do

    before(:each) do
      @top_level_contribution = Factory.build(:top_level_contribution)
      @top_level_contribution.run_callbacks(:save)
    end

    it "sets confirmed = true by default" do
      @top_level_contribution.confirmed.should be_true
    end

  end

  describe "when confirming contributions" do

    before(:each) do
      @contribution = Factory.create(:contribution, {:override_confirmed => false})
    end

    it "omits unconfirmed contributions (those only previewed but never confirmed) in confirmed scope" do
      contributions = Contribution.confirmed.all
      contributions.should_not include @contribution
    end

    it "returns only unconfirmed contributions for unconfirmed scope" do
      contributions = Contribution.unconfirmed.all
      contributions.should include @contribution
    end

    it "successfully sets :confirmed to true with .confirm! method and saves to database" do
      @contribution.confirm!
      @contribution.confirmed.should be_true
      contribution = Contribution.confirmed.find(@contribution.id)
      contribution.confirmed.should be_true
    end

  end

  describe "when editing and deleting confirmed contributions" do

    before(:each) do
      @person = Factory.create(:registered_user)
      @old_contribution = Factory.create(:contribution, {:created_at => Time.now - 35.minutes, :person => @person})
      @new_contribution = Factory.create(:contribution, {:created_at => Time.now - 25.minutes, :person => @person})
      @new_params = { 'content' => "Some new comment", 'url' => "http://www.example.com/some-other-link" }
    end

    context "as the contributing user" do

      it "allows deletion by the user within 30 minutes of creation" do
        @new_contribution.should_receive(:destroy)
        @new_contribution.destroy_by_user(@person)
      end

      it "disallows deletion by the user if older than 30 minutes" do
        @old_contribution.should_not_receive(:destroy)
        @old_contribution.destroy_by_user(@person)
        @old_contribution.should have_generic_error(:base, /Contributions cannot be deleted if they are older than 30 minutes or have any responses./)
      end

      it "disallows deletion by the user if anyone has rated or replied to the contribution" do
        rating_group = Factory.create(:rating_group, contribution: @new_contribution)
        @new_contribution.should_not_receive(:destroy)
        @new_contribution.destroy_by_user(@person)
        @new_contribution.should have_generic_error(:base, /Contributions cannot be deleted if they are older than 30 minutes or have any responses./)
      end

      it "allows editing by the user within 30 minutes of creation" do
        @new_contribution.should_receive(:update)
        @new_contribution.update_attributes_by_user(@new_params, @person)
      end

      it "disallows editing by the user if older than 30 minutes" do
        @old_contribution.should_not_receive(:update)
        @old_contribution.update_attributes_by_user(@new_params, @person)
        @old_contribution.should have_generic_error(:base, /Contributions cannot be edited if they are older than 30 minutes or have any responses./)
      end

      it "disallows editing by the user if anyone has rated or replied to the contribution" do
        rating_group = Factory.create(:rating_group, contribution: @new_contribution)
        @new_contribution.should_not_receive(:update)
        @new_contribution.update_attributes_by_user(@new_params, @person)
        @new_contribution.should have_generic_error(:base, /Contributions cannot be edited if they are older than 30 minutes or have any responses./)
      end

      it "only updates updateable parameters" do
        @non_updateable_params = {:parent_id => @new_contribution.id + 1}
        @new_contribution.update_attributes_by_user(@new_params.merge(@non_updateable_params), @person)
        @new_params.each do |key, value|
          @new_contribution[key].should == value
        end
        @non_updateable_params.each do |key, value|
          @new_contribution[key].should_not == value
        end
      end
    end

    context "as an admin user" do

      before(:each) do
        @admin_person = Factory.create(:admin_person)
      end

      it "allows deletion by an admin at any time" do
        @old_contribution.should_receive(:destroy)
        @old_contribution.destroy_by_user(@admin_person)
      end

      it "allows editing by an admin at any time" do
        @old_contribution.should_receive(:update)
        @old_contribution.update_attributes_by_user(@new_params, @admin_person)
      end

    end

    context "as another user" do

      before(:each) do
        @other_person = Factory.create(:registered_user)
      end

      it "disallows deletion by another user" do
        @new_contribution.should_not_receive(:destroy)
        @new_contribution.destroy_by_user(@other_person)
        @new_contribution.should have_generic_error(:base, /Contributions cannot be deleted if they are older than 30 minutes or have any responses./)
      end

      it "disallows deletion by another user" do
        @new_contribution.should_not_receive(:destroy)
        @new_contribution.destroy_by_user(@other_person)
        @new_contribution.should have_generic_error(:base, /Contributions cannot be deleted if they are older than 30 minutes or have any responses./)
      end

      it "disallows editing by another user" do
        @new_contribution.should_not_receive(:update)
        @new_contribution.update_attributes_by_user(@new_params, @other_person)
        @new_contribution.should have_generic_error(:base, /Contributions cannot be edited if they are older than 30 minutes or have any responses./)
      end

    end

    it "#editable_by?(user) returns false for a logged-out user" do
      @new_contribution.editable_by?(nil).should be_false
    end

  end

  describe "when updating AttachedFile" do

    before(:each) do
      @person = Factory.create(:normal_person)
      @attached_file = Factory.create(:attached_file, {:person => @person, :override_confirmed => true})
    end

    it "does nothing to the file attachment if left blank" do
      #@attached_file.should_not_receive(:save_attached_files) # apparently #save_attached_files gets called on every save whether the attachment is updated or not
      old_attachment_name = @attached_file.attachment_file_name
      @attached_file.update_attributes_by_user({:attachment => ''}, @person)
      @attached_file.attachment_file_name.should == old_attachment_name
    end

    it "updates the attached file if file is specified" do
      @attached_file.should_receive(:save_attached_files)
      @attached_file.update_attributes_by_user({:attachment => File.new(Rails.root + 'test/fixtures/images/test_image2.jpg')}, @person)
      @attached_file.attachment_file_name.should == "test_image2.jpg"
    end

  end

  describe "when updating a Link" do

    before(:each) do
      @person = Factory.create(:normal_person)
      @link = Factory.create(:link, {:person => @person, :override_confirmed => true})
    end

    it "does nothing to the URL if left blank" do
      old_url = @link.url
      @link.update_attributes_by_user({:url => ''}, @person)
      @link.url.should == old_url
    end

    it "updates the URL if new URL is specified" do
      new_url = 'http://www.example.com/some-other-link'
      @link.update_attributes_by_user({:url => new_url}, @person)
      @link.url.should == new_url
    end

  end

  describe "when deleting old unconfirmed contributions" do

    before(:each) do
      @old_unconfirmed_contribution = Factory.create(:comment, {:created_at => Time.now - 3.days, :confirmed => false})
      @new_unconfirmed_contribution = Factory.create(:comment, {:created_at => Time.now, :confirmed => false})
      @old_confirmed_contribution = Factory.create(:comment, {:created_at => Time.now - 3.days, :override_confirmed => true})
      @new_confirmed_contribution = Factory.create(:comment, {:created_at => Time.now, :override_confirmed => true})
      @count = Contribution.delete_old_unconfirmed_contributions
      @remaining_contributions = Contribution.all
    end

    it "returns correct number of deleted contributions" do
      @count.should == 1
    end

    it "deletes old unconfirmed contributions" do
      @remaining_contributions.should_not include @old_unconfirmed_contribution
    end

    it "does not delete unconfirmed contributions newer than 1 day" do
      @remaining_contributions.should include @new_unconfirmed_contribution
    end

    it "does not delete confirmed contributions" do
      @remaining_contributions.should include @old_confirmed_contribution
      @remaining_contributions.should include @new_confirmed_contribution
    end

  end

  Contribution::ALL_TYPES.each do |contribution_type|
    describe contribution_type, "when creating for a conversation" do

      before(:each) do
        @conversation = Factory.create(:conversation)
        @person = Factory.create(:normal_person)
        @top_level_contribution = Factory.create(:top_level_contribution,{:conversation=>@conversation})
        @contribution = Factory.build(contribution_type.underscore.to_sym, {
          :person=>@person,
          :conversation=>@conversation,
          :parent=>@top_level_contribution
        } )
      end

      context "and there is a validation error" do

        it "should return a contribution with an error" do
          @contribution.content = nil
          @contribution.url = nil
          if ["Link","EmbeddedSnippet"].include?(@contribution.type)
            @contribution.should have_validation_error(:url)
          else
            @contribution.should have_validation_error(:content)
          end
        end

      end

      describe "when it is saved for preview" do

        before(:each) do
          # @contribution.run_callbacks(:save) # this does not work with awesome_nested_set apparently
          @contribution.save!
        end

        it "saves with :confirmed set to false" do
          @contribution.confirmed.should be_false
        end

        it "should set the passed in user as the owner" do
          @contribution.person.should == @person
        end

        it "should set the item to the conversation" do
          @contribution.item.should == @conversation
        end

      end

      describe "and using node level contribution methods" do

        before(:each) do
          @attributes = Factory.attributes_for(contribution_type.underscore,
                                               :conversation => @contribution.conversation,
                                               :parent_id => @contribution.parent_id)
                               .merge({:type => contribution_type}
                        )
        end

        context "when using Contribution.new_node_level_contribution" do

          it "sets up a valid #{contribution_type} but doesn't save it to the db" do
            contribution = Contribution.new_node_level_contribution(@attributes, @person)
            contribution.class.to_s.should == contribution_type.to_s
            contribution.valid?.should be_true
            contribution.new_record?.should be_true
          end

        end

        context "when using Contribution.create_node_level_contribution" do

          it "sets up and creates a valid #{contribution_type} saved to the db" do
            contribution = Contribution.create_node_level_contribution(@attributes, @person)
            contribution.class.to_s.should == contribution_type.to_s
            contribution.valid?.should be_true
            contribution.confirmed.should be_false
            contribution.new_record?.should be_false
          end

        end

        context "when using Contribution.create_confirmed_node_level_contribution" do

          it "sets up and creates a valid confirmed #{contribution_type} saved to the db" do
            contribution = Contribution.create_confirmed_node_level_contribution(@attributes, @person)
            contribution.class.to_s.should == contribution_type.to_s
            contribution.valid?.should be_true
            contribution.confirmed.should be_true
            contribution.new_record?.should be_false
          end

        end

        describe "dealing with preview functionality" do

          before(:each) do
            @contribution.save!
          end

          context "when using Contribution.find_or_create_node_level_contribution" do

            it "finds and returns unconfirmed contribution for user/parent combination, if it exists, but with new content" do
              new_comment = "This is a different comment"
              attributes = @attributes.merge(:content => new_comment)
              new_contribution = Contribution.update_or_create_node_level_contribution(attributes, @person)
              new_contribution.id.should == @contribution.id
              new_contribution.content.should == new_comment
            end

            it "creates and returns a new contribution if no unconfirmed contribution exists for user/parent combination" do
              attributes = @attributes.merge(:parent_id => (@contribution.parent_id + 1))
              new_contribution = Contribution.update_or_create_node_level_contribution(attributes, @person)
              new_contribution.id.should_not == @contribution.id
            end

          end

        end

      end

      describe "and it is saved successfully" do

        before(:each) do
          @contribution.override_confirmed = true
          @contribution.save!
        end

        it "should add the #{contribution_type} to a conversation" do
          @conversation.contributions.count.should == 2
          @conversation.contributions.should include @contribution
        end

      end

    end

  end

  describe "when creating a contribution for an issue" do

    before(:each) do
      @issue = Factory.create(:issue)
      @mock_person = Factory.create(:normal_person)
    end

    it "should set the item to the issue" do
      contribution = Contribution.create({:issue=>@issue, :person=>@mock_person, :content=>"Hello World"})
      contribution.item.should == @issue
    end

  end

  describe "validating a contribution" do

    it "should require an issue or a contributiion" do
      person = Factory.create(:normal_person)
      contribution = Contribution.
        create_node_level_contribution({:content => "Foo Bar",
                                        :type => "Comment"},
                                       person)
      contribution.errors.count.should == 1
    end

  end

  describe "validating a contribution for an issue" do

    before(:each) do
      @issue = Factory.create(:issue)
      @person = Factory.create(:normal_person)
    end

    it "should be valid when creating a Comment" do
      contribution = Contribution.
        create_node_level_contribution({:issue_id => @issue.id,
                                         :content => "Foo Bar",
                                         :type => "Comment"},
                                       @person)
      contribution.valid?.should be_true
    end

    it "should not be valid without a person" do
      pending "Validation has not been written yet..."
      contribution = Contribution.
        create_node_level_contribution({:issue_id => @issue.id,
                                         :content => "Foo Bar",
                                         :type => "Comment"}, nil)
      contribution.valid?.should be_false
    end

  end

  describe "Contribution#moderate_contribution" do

    it "Deletes the contribution and all nested contributions returning true" do
      contribution = Contribution.new(content: "Hello There", type: "Comment", owner: 1)
      first_nested_contribution = Contribution.new(content: "You are wrong", type: "Comment", owner: 2, parent: contribution)
      second_nested_contribution = Contribution.new(content: "Both are wrong", type: "Comment", owner: 3, parent: contribution)

      contribution.moderate_contribution.should == true
      contribution.descendants.length.should == 0
    end

  end

  describe "when deleting contributions of" do

    def given_a_contribution(type)
      @person = Factory.create(:normal_person)
      @other_person = Factory.create(:normal_person)
      @admin_person = Factory.create(:admin_person)
      @contribution = Factory.create(type, {:person => @person})
    end

    describe "suggested action" do

      it "should be able to be deleted by admin" do
        given_a_contribution(:suggested_action)
        @contribution.destroy_by_user(@admin_person).should be_true
      end

      it "should be able to be deleted by the creator" do
        given_a_contribution(:suggested_action)
        @contribution.destroy_by_user(@person).should be_true
      end

      it "should not be able to be deleted by other person" do
        given_a_contribution(:suggested_action)
        @contribution.destroy_by_user(@other_person).should be_false
      end

    end

    describe "EmbeddedSnippet" do

      it "should be able to be deleted by admin" do
        given_a_contribution(:embedded_snippet)
        @contribution.destroy_by_user(@admin_person).should be_true
      end

      it "should be able to be deleted by the creator" do
        given_a_contribution(:embedded_snippet)
        @contribution.destroy_by_user(@person).should be_true
      end

      it "should not be able to be deleted by other person" do
        given_a_contribution(:embedded_snippet)
        @contribution.destroy_by_user(@other_person).should be_false
      end

    end

    describe "AttachedFile" do

      it "should be able to be deleted by admin" do
        given_a_contribution(:attached_file)
        @contribution.destroy_by_user(@admin_person).should be_true
      end

      it "should be able to be deleted by the creator" do
        given_a_contribution(:attached_file)
        @contribution.destroy_by_user(@person).should be_true
      end

      it "should not be able to be deleted by other person" do
        given_a_contribution(:attached_file)
        @contribution.destroy_by_user(@other_person).should be_false
      end

    end

    describe "Link" do

      it "should be able to be deleted by admin" do
        given_a_contribution(:link)
        @contribution.destroy_by_user(@admin_person).should be_true
      end

      it "should be able to be deleted by the creator" do
        given_a_contribution(:link)
        @contribution.destroy_by_user(@person).should be_true
      end

      it "should not be able to be deleted by other person" do
        given_a_contribution(:link)
        @contribution.destroy_by_user(@other_person).should be_false
      end

    end

  end

  context "Existing contribution, conversation, and issue" do

     let(:contribution) {Contribution.new(content: "This is a contribution")}
     let(:conversation) {Factory.create(:conversation, title: "I'm a conversation")}
     let(:issue)        {Issue.create(name: "I'm an Issue")}

     describe "Contribution#item_id" do

       it "Retuns the id of the issue" do
         issue.contributions << contribution
         contribution.item_id.should == issue.id
       end

       it "Returns the id of the conversation" do
         conversation.contributions << contribution
         contribution.item_id.should == conversation.id
       end

     end

     describe "Contribution#item_class" do

       it "Returns 'Issue' if the item was contributed to an Issue" do
         issue.contributions << contribution
         contribution.item_class.should == issue.class.to_s
       end

       it "Returns 'Conversation' if the item was contributed to a conversation" do
         conversation.contributions << contribution
         contribution.item_class.should == conversation.class.to_s
       end

     end

  end

end
