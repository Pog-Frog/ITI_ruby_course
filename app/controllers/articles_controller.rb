class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource except: [:new, :create]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @articles = user_signed_in? ? current_user.articles.not_deleted.order(created_at: :desc) : Article.published_articles.order(created_at: :desc)
  end

  def show
    # Authorization handled by CanCanCan
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      redirect_to @article, notice: 'Article created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Authorization handled by CanCanCan
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: 'Article updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @article.reports_count >= 6
      @article.destroy
      redirect_to articles_path, notice: 'Article removed due to excessive reports.'
    else
      @article.update(status: :deleted)
      redirect_to articles_path, notice: 'Article deleted successfully.'
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :image)
  end

  def check_owner
    redirect_to articles_path, alert: 'Unauthorized action.' unless @article.user == current_user
  end
end
