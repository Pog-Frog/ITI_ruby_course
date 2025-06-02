class AddImageAndReportsToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :image, :string
    add_column :articles, :reports_count, :integer, default: 0, null: false
  end
end
