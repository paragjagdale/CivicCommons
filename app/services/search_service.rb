class SearchService

  def initialize(search = nil)
    if search.nil?
      # called by search controller since nothing was passed in
      @search = Sunspot
    else
      # called by search spec since a mock was passed in
      @search = search
    end
  end

  def fetch_results(params = nil)
    @results = @search.search(Conversation, Issue) do
      keywords(params[:q])
    end
  end

end
