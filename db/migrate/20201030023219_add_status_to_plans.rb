class AddStatusToPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :status, :integer, default: 0, null: false
    remove_column :plans, :active
    remove_column :plans, :visible
  end
end
