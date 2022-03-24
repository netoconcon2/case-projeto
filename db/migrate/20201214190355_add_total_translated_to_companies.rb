class AddTotalTranslatedToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :total_translated, :integer, default: 0
  end
end
