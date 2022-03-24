class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.text :original_text
      t.text :translated_text
      t.integer :status
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
