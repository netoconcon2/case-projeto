class AddRoleToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :role, :integer
    add_reference :users, :company, foreign_key: true
  end
end
