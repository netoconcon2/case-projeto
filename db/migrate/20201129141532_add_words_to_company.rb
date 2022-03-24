class AddWordsToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :words, :integer
    add_column :companies, :last_words_updated, :date
  end
end
