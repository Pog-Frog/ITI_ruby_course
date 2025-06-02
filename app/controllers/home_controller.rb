class HomeController < ApplicationController
  def index
    @articles = Article.published_articles.includes(:user).order(created_at: :desc)
  end
end
