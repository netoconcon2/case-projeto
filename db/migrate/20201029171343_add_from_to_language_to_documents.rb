class AddFromToLanguageToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :from_to_language, :string
  end
end
