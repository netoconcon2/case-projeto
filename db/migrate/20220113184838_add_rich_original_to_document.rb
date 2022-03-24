class AddRichOriginalToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :rich_original, :string
  end
end
