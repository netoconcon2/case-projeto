class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :cnpj
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
