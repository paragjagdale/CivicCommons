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

  def fetch_results(query = nil, *models)
    results = @search.search(models) do
      keywords(query) do
        highlight :summary, :bio, :description
      end
    end

    fetched_results = []
    results.each_hit_with_result do |hit, result| 
      fetched_results << hit
    end
    return fetched_results
  end
end
