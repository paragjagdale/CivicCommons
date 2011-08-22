class Admin::CuratedFeedItemsController < Admin::DashboardController

  # GET /admin/feeds/1/items/1
  def show
    @feed = CuratedFeed.find(params[:curated_feed_id])
    @item = CuratedFeedItem.find(params[:id])
  end

  # GET /admin/feeds/1/items/1/edit
  def edit
    @feed = CuratedFeed.find(params[:curated_feed_id])
    @item = CuratedFeedItem.find(params[:id])
  end

  # POST /admin/feeds/1/items
  def create
    @feed = CuratedFeed.find(params[:curated_feed_id])
    @item = CuratedFeedItem.new(params[:curated_feed_item])
    @item.feed = @feed
    @item.save
    redirect_to(admin_curated_feed_path(@feed))
  end

  # PUT /admin/feeds/1/items/1
  def update
    @feed = CuratedFeed.find(params[:curated_feed_id])
    @item = CuratedFeedItem.find(params[:id])
    @item.feed = @feed
    @item.attributes = params[:curated_feed_item]

    if @item.save
      redirect_to(admin_curated_feed_path(@feed), :notice => 'Feed item was successfully updated.')
    else
      render :edit
    end
  end

  # DELETE /admin/feeds/1/items/1
  def destroy
    @feed = CuratedFeed.find(params[:curated_feed_id])
    @item = CuratedFeedItem.find(params[:id])
    @item.destroy
    redirect_to(admin_curated_feed_path(@feed))
  end
end
