class RemovePaymentMethodsFromPackages < ActiveRecord::Migration[6.0]
  def change
    remove_column :packages, :payment_methods, :string
  end
end
