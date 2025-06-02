# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  article_id :integer          not null
#  reason     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_reports_on_article_id  (article_id)
#  index_reports_on_user_id     (user_id)
#

class Report < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :reason, presence: true
  validates :user_id, uniqueness: { scope: :article_id, message: 'You have already reported this article.' }

  after_create :increment_article_reports_count
  after_destroy :decrement_article_reports_count

  private

  def increment_article_reports_count
    article.increment!(:reports_count)
  end

  def decrement_article_reports_count
    article.decrement!(:reports_count)
  end
end
