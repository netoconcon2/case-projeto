class AddWasTranslatedToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :was_translated, :boolean, default: false
  end
end
