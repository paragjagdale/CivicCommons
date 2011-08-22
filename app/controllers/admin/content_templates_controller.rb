class Admin::ContentTemplatesController < Admin::DashboardController

  # GET /admin/content_templates
  def index
    @content_templates = ContentTemplate.all
  end

  # GET /admin/content_templates/1
  def show
    @content_template = ContentTemplate.find(params[:id])
  end

  # GET /admin/content_templates/new
  def new
    @content_template = ContentTemplate.new
  end

  # GET /admin/content_templates/1/edit
  def edit
    @content_template = ContentTemplate.find(params[:id])
  end

  # POST /admin/content_templates
  def create
    @content_template = ContentTemplate.new(params[:content_template])
    @content_template.author = current_person

    if @content_template.save
      redirect_to(admin_content_template_path(@content_template), :notice => 'Content template was successfully created.')
    else
      render :new
    end
  end

  # PUT /admin/content_templates/1
  def update
    @content_template = ContentTemplate.find(params[:id])
    @content_template.attributes = params[:content_template]
    @content_template.author = current_person

    if @content_template.save
      redirect_to(admin_content_template_path(@content_template), :notice => 'Content template was successfully updated.')
    else
      render :edit
    end
  end

  # DELETE /admin/content_templates/1
  def destroy
    @content_template = ContentTemplate.find(params[:id])
    @content_template.destroy
    redirect_to(admin_content_templates_url)
  end
end
