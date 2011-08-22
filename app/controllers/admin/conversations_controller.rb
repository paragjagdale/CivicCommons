class Admin::ConversationsController < Admin::DashboardController

  #GET admin/conversations
  def index
    @conversations = Conversation.all
  end

  #GET admin/conversations/new
  def new
    @conversation = Conversation.new(params[:conversation])
    @presenter = IngestPresenter.new(@conversation)
  end

  #POST admin/conversations/
  def create
    ActiveRecord::Base.transaction do
      params[:conversation].merge!({
        :person => current_person,
        :from_community => false
      })
      @conversation = Conversation.new(params[:conversation])
      @presenter = IngestPresenter.new(@conversation, params[:transcript_file])

      @conversation.save!
      @presenter.save!
      respond_to do |format|
        format.html { redirect_to(admin_conversation_path(@conversation), :notice => 'Your conversation has been created!') }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :new }
      format.xml  { render :xml => @conversation.errors + @presenter.errors, :status => :unprocessable_entity }
    end
  end


  #GET admin/conversations/:id/edit
  def edit
    @conversation = Conversation.find(params[:id])
    @presenter = IngestPresenter.new(@conversation)
  end

  #PUT admin/conversations/:id
  def update
    @conversation = Conversation.find(params[:id])
    if @conversation.update_attributes(params[:conversation])
      flash[:notice] = "Successfully updated conversation"
      redirect_to admin_conversations_path
    else
      @presenter = IngestPresenter.new(@conversation)
      render :edit
    end
  end

  #PUT admin/conversations/update_order
  def update_order
    # validate parameters
    current_position = format_param(params[:current])
    next_position = format_param(params[:next])
    previous_position = format_param(params[:prev])
    
    raise "Current position cannot be nil" if current_position.nil?

    if previous_position.nil?
      set_position(current_position, 0, next_position)
    elsif next_position.nil?
      set_position(current_position, 0, previous_position)
    elsif next_position > previous_position
      set_position(current_position, previous_position + 1, next_position)
    elsif next_position < previous_position
      set_position(current_position, next_position + 1, previous_position)
    end

    Conversation.sort
    render :nothing => true
  end

  #GET admin/conversations/:id
  def show
    @conversation = Conversation.find(params[:id])
  end 

  #DELETE admin/conversations/:id
  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to admin_conversations_path
  end

  #POST admin/conversations/:id/toggle_staff_pick
  def toggle_staff_pick
    @conversation = Conversation.find(params[:id])
    @conversation.toggle(:staff_pick)

    if @conversation.save
      status = @conversation.staff_pick? ? 'on' : 'off'
      flash[:notice] = "Staff Pick is turned #{status} for \"#{@conversation.title}\""
      @conversation.sort
    else
      flash[:error] = "Error saving conversation: \"#{@conversation.title}\""
    end

    if params[:redirect_to]
      redirect_to :action => params[:redirect_to]
    else
      redirect_to admin_conversation_path
    end
  end

private

  def format_param(param)
    if param.match(/^\d+$/)
      param.to_i
    else
      nil
    end
  end

  def set_position(current, new_index, comparison)
    current_conversation = Conversation.find_by_position(current)
    Conversation.where('position >= ?', comparison).each do |conversation|
      conversation.position += 1
      conversation.save
    end
    current_conversation.position = new_index
    current_conversation.save
  end

end
