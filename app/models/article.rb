class Article < ApplicationRecord
  belongs_to :user
  has_many :reports, dependent: :destroy
  has_one_attached :image

  enum status: { draft: 0, published: 1, deleted: 2, archived: 3 }

  validates :title, :body, presence: true

  scope :published_articles, -> { where(status: :published) }
  scope :not_deleted, -> { where.not(status: :deleted) }

  after_update :check_reports_count

  private

  def check_reports_count
    update_column(:status, :archived) if reports_count >= 3 && !archived?
  end
end
