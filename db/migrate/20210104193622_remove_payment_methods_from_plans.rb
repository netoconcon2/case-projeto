class RemovePaymentMethodsFromPlans < ActiveRecord::Migration[6.0]
  def change
    remove_column :plans, :payment_methods, :string
  end
end
