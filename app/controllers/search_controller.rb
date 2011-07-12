class SearchController < ApplicationController
  def results

    @conversations = Array.new
    @issues = Array.new
    @community = Array.new

    search_service = SearchService.new
    search = search_service.fetch_results params[:q], Conversation, Issue

#    search = Sunspot.search(Conversation, Issue) do
#      keywords(params[:q])
#    end

    # divide the search results into their respective types
    search.each_hit_with_result do |hit, result|
      case result
      when Issue
        @issues << result
      when Conversation
        @conversations << result
      when Person
        @community << result
      else
      end
    end 
  end
end
