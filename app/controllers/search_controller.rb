class SearchController < ApplicationController
  def results
    @search = Conversation.search do
      keywords(params[:q])
    end
  end
end
