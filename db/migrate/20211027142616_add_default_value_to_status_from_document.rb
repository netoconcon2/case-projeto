class AddDefaultValueToStatusFromDocument < ActiveRecord::Migration[6.0]
  def change
    change_column :documents, :status, :integer, default: 0
  end
end
