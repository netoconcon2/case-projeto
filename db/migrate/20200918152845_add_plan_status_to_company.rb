class AddPlanStatusToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :plan_status, :string, default: "off"
    add_column :companies, :pagarme_subscription_id, :string
  end
end
