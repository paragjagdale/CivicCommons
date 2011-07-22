class ContributionsController < ApplicationController
  include ContributionsHelper

  before_filter :load_conversation, only: [:edit, :update, :moderate, :moderated]
  before_filter :verify_admin, only: [:moderate, :moderated]

  def destroy
    @contribution = Contribution.find(params[:id])
    respond_to do |format|
      if @contribution.destroy_by_user(current_person)
        format.js   { render :nothing => true, :status => :ok }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def moderate
    @contribution = Contribution.find(params[:id])
  end

  def moderated
    @contribution = Contribution.find(params[:id])
    @contribution.moderate_content(params, current_person)
    redirect_to conversation_path(@conversation)
  end

  def create_confirmed_contribution
    @contribution = Contribution.create_confirmed_node_level_contribution(params[:contribution], current_person)
    redirect_to("#{contribution_parent_page(@contribution)}#contribution#{@contribution.id}",
                    :notice => 'Contribution was successfully created.')
  end

  def edit
    @contribution = Contribution.find(params[:id])
    respond_to do |format|
      format.js{ render(:partial => 'conversations/new_contribution_form', :locals => {:div_id => "show-contribution-#{@contribution.id}", :type => @contribution.type.underscore.to_sym, :subtype => nil}, :layout => false) }
    end
  end

  def update
    @contribution = Contribution.find(params[:id])
    respond_to do |format|
      if @contribution.update_attributes_by_user(params[:contribution], current_person)
        ratings = RatingGroup.ratings_for_conversation_by_contribution_with_count(@contribution.conversation, current_person)
        format.js{ render(:partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution, :ratings => ratings, :div_id => params[:div_id]}, :layout => false, :status => :ok) }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

private

  def load_conversation
    if params.has_key?(:conversation_id)
      @conversation = Conversation.find(params[:conversation_id])
    elsif params.has_key?(:issue_id)
      @issue = Issue.find(params[:issue_id])
    end
  end

end
