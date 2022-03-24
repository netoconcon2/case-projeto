class RemoveDeactivatedFromPlans < ActiveRecord::Migration[6.0]
  def change
    remove_column :plans, :deactivated, :boolean
  end
end
