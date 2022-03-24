class CreateTerms < ActiveRecord::Migration[6.0]
  def change
    create_table :terms do |t|
      t.references :glossary, null: false, foreign_key: true
      t.string :source
      t.string :target

      t.timestamps
    end
  end
end
