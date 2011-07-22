class SearchController < ApplicationController
  def results

    @conversations = Array.new
    @issues = Array.new
    @community = Array.new

    search_service = SearchService.new
    @results = search_service.fetch_results params[:q], Conversation, Issue, Person

  end
end
