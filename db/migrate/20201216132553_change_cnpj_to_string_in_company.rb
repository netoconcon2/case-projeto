class ChangeCnpjToStringInCompany < ActiveRecord::Migration[6.0]
  def change
    change_column :companies, :cnpj, :string, :limit => 18
  end
end
