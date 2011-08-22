class Admin::CuratedFeedsController < Admin::DashboardController

  # GET /admin/curated_feeds
  def index 
    @feeds = CuratedFeed.order(title: 'ASC')
  end

  # GET /admin/curated_feeds/1
  def show
    @feed = CuratedFeed.find(params[:id])
  end

  # GET /admin/curated_feeds/new
  def new
    @feed = CuratedFeed.new
  end

  # GET /admin/curated_feeds/1/edit
  def edit
    @feed = CuratedFeed.find(params[:id])
  end

  # POST /admin/curated_feeds
  def create
    @feed = CuratedFeed.new(params[:curated_feed])

    if @feed.save
      redirect_to(admin_curated_feed_path(@feed), :notice => 'Feed successfully created.')
    else
      render :new
    end
  end

  # PUT /admin/curated_feeds/1
  def update
    @feed = CuratedFeed.find(params[:id])

    if @feed.update_attributes(params[:curated_feed])
      redirect_to(admin_curated_feed_path(@feed), :notice => 'Curated feed was successfully updated.')
    else
      render :edit
    end
  end

  # DELETE /admin/curated_feeds/1
  def destroy
    @feed = CuratedFeed.find(params[:id])
    @feed.destroy
    redirect_to(admin_curated_feeds_url)
  end
end
