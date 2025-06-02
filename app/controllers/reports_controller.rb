class ReportsController < ApplicationController
  before_action :authenticate_user!

  def create
    @article = Article.find(params[:article_id])
    @report = @article.reports.new(report_params.merge(user: current_user))

    if @report.save
      @article.increment!(:reports_count)
      archive_article_if_needed(@article)
      redirect_to @article, notice: 'Article reported successfully.'
    else
      redirect_to @article, alert: @report.errors.full_messages.join(', ')
    end
  end

  private

  def archive_article_if_needed(article)
    article.update(status: 'archived') if article.reports_count >= 3
  end

  def report_params
    params.require(:report).permit(:reason)
  end
end
