class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :pagarme_id
      t.string :status
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
