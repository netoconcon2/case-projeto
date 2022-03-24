class FixAviableWordsName < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :avaiable_words, :available_words
  end
end
