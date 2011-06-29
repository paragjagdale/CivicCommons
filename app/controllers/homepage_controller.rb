class HomepageController < ApplicationController
  def show
    @most_visited_conversations = Conversation.get_top_visited(3)

    @conversations = Conversation.latest_created.paginate(:page => params[:page], :per_page => 6)

    @main_article = Article.homepage_main_article.first
    @sub_articles = Article.homepage_sub_articles.limit(3)
    @blog_posts = ContentItem.recent_blog_posts.limit(3)
    @regions = Region.all

    @recent_items = Activity.most_recent_activity(3)
  end
end
