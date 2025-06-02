class AddFieldsToArticles < ActiveRecord::Migration[8.0]
  def change
    add_reference :articles, :user, null: false, foreign_key: true
    add_column :articles, :status, :integer, default: 0, null: false
  end
end
