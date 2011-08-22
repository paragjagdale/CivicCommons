class Admin::ContentItemsController < Admin::DashboardController

  #GET admin/content_items
  def index
    if params[:type]
      @filter = params[:type].classify
      @content_items = ContentItem.where(content_type: @filter).order('content_type ASC, published DESC, created_at DESC')
    else
      @filter = 'All'
      @content_items = ContentItem.all(order: 'content_type ASC, published DESC, created_at DESC')
    end
  end

  def new
    @content_item = ContentItem.new(params[:content_item])
    @authors = Person.find_all_by_admin(true, :order => 'first_name, last_name ASC')
    @content_item.author = current_person
    @content_item.published = Date.today
  end

  def create
    @content_item = ContentItem.new(params[:content_item])

    begin
      error = false
      @content_item.published = params[:content_item][:published] ? Date.strptime(params[:content_item][:published], "%m/%d/%Y") : Date.today 
    rescue
      error = true
      @content_item.errors.add :published, "invalid date"
    end

    @content_item.embed_code = get_embed_code_from_embedly(@content_item.external_link, @content_item.embed_code) unless error

    @authors = Person.find_all_by_admin(true, :order => 'first_name, last_name ASC')

    if !error && @content_item.save
      flash[:notice] = "Your #{@content_item.content_type} has been created!"
      redirect_to admin_content_item_path(@content_item)
    else
      render :new
    end
  end

  def show
    @content_item = ContentItem.find(params[:id])
    @person = Person.find(@content_item.person_id)
  end

  def edit
    @content_item = ContentItem.find(params[:id])
    @authors = Person.find_all_by_admin(true, :order => 'first_name, last_name ASC')
    @content_item.url_slug = @content_item.cached_slug
  end

  def destroy
    @content_item = ContentItem.find(params[:id])
    @content_item.destroy
    flash[:notice] = "Successfully deleted content item"
    redirect_to admin_content_items_path
  end

  def update
    @content_item = ContentItem.find(params[:id])
    @authors = Person.find_all_by_admin(true, :order => 'first_name, last_name ASC')

    begin
      params[:content_item][:published] = params[:content_item][:published] ? Date.strptime(params[:content_item][:published], "%m/%d/%Y") : Date.today 
      error = false
    rescue
      error = true
      @content_item.errors.add :published, "invalid date"
    end

    params[:content_item][:embed_code] = get_embed_code_from_embedly(params[:content_item][:external_link], params[:content_item][:embed_code]) unless error

    if !error && @content_item.update_attributes(params[:content_item])
      flash[:notice] = "Successfully edited your #{@content_item.content_type}"
      redirect_to admin_content_item_path(@content_item)
    else
      render :edit
    end
  end

  private

  def get_embed_code_from_embedly(external_link, embed_code = nil)
    if embed_code.blank? and not external_link.blank?
      embed_code = EmbedlyService.get_simple_embed(external_link)
    end
    return embed_code
  end

end
