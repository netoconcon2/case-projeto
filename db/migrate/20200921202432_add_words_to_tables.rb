class AddWordsToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :avaiable_words, :integer, default: 0
    add_column :plans, :words, :integer
  end
end
