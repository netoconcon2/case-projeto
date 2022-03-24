class CreatePackages < ActiveRecord::Migration[6.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.string :payment_methods
      t.monetize :price
      t.integer :words
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
