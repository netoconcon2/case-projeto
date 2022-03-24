class AddFieldsToPlan < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :pagarme_id, :string
    add_column :plans, :price, :integer
    add_column :plans, :days, :integer
    add_column :plans, :trial_days, :integer
    add_column :plans, :payment_methods, :string
    add_column :plans, :charges, :integer
    add_column :plans, :installments, :integer
    add_column :plans, :invoice_reminder, :integer
    add_column :plans, :active, :boolean, default: false
    add_column :plans, :visible, :boolean, default: false
    add_column :plans, :deactivated, :boolean, default: false
  end
end
