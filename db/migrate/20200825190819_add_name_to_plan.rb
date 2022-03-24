class AddNameToPlan < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :name, :string
  end
end
