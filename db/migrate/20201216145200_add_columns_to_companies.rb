class AddColumnsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :street, :string
    add_column :companies, :street_line_2, :string
    add_column :companies, :street_number, :integer
    add_column :companies, :zip_code, :string
    add_column :companies, :neighborhood, :string
    add_column :companies, :city, :string
    add_column :companies, :state, :string
    add_column :companies, :phone, :string
  end
end
