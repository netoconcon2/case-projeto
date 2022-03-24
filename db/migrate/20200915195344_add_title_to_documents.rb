class AddTitleToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :title, :string
  end
end
