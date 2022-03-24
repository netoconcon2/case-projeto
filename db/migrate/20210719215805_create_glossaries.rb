class CreateGlossaries < ActiveRecord::Migration[6.0]
  def change
    create_table :glossaries do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :language_1
      t.string :language_2

      t.timestamps
    end
  end
end
