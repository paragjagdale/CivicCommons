class Admin::ManagedIssuePagesController < Admin::DashboardController

  # GET /admin/issues/1/pages
  def all
    @managed_issue_pages = ManagedIssuePage.order('issue_id ASC, name ASC')
    render :index
  end

  # GET /admin/issues/1/pages
  def index
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_pages = ManagedIssuePage.where(issue_id: @issue.id).order('name ASC')
  end

  # GET /admin/issues/1/pages/1
  def show
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.find(params[:id])
  end

  # GET /admin/issues/1/pages/new
  def new
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.new(issue: @issue)
  end

  # GET /admin/issues/1/pages/1/edit
  def edit
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.find(params[:id])
  end

  # POST /admin/issues/1/pages
  def create
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.new(params[:managed_issue_page])
    @managed_issue_page.issue = @issue
    @managed_issue_page.author = current_person

    if @managed_issue_page.save
      redirect_to(admin_issue_page_path(@issue, @managed_issue_page), :notice => 'Content template was successfully created.')
    else
      render :new
    end
  end

  # PUT /admin/issues/1/pages/1
  def update
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.find(params[:id])
    @managed_issue_page.attributes = params[:managed_issue_page]
    @managed_issue_page.author = current_person

    if @managed_issue_page.save
      redirect_to(admin_issue_page_path(@issue, @managed_issue_page), :notice => 'Content template was successfully updated.')
    else
      render :edit
    end
  end

  # DELETE /admin/issues/1/pages/1
  def destroy
    @issue = ManagedIssue.find(params[:issue_id])
    @managed_issue_page = ManagedIssuePage.find(params[:id])
    @managed_issue_page.destroy
    redirect_to(admin_issue_pages_path(@issue))
  end
end
