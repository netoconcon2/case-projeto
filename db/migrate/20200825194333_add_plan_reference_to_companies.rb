class AddPlanReferenceToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_reference :companies, :plan, foreign_key: true
  end
end
