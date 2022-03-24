class CreateDocumentGlossaries < ActiveRecord::Migration[6.0]
  def change
    create_table :document_glossaries do |t|
      t.references :document, null: false, foreign_key: true
      t.references :glossary, null: false, foreign_key: true

      t.timestamps
    end
  end
end
