class CreateTextChunks < ActiveRecord::Migration[6.0]
  def change
    create_table :text_chunks do |t|
      t.string :original
      t.string :translated
      t.integer :status, default: 2
      t.references :document, null: false, foreign_key: true
      t.references :responsible, index: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
