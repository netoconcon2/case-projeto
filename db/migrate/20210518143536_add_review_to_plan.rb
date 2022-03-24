class AddReviewToPlan < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :include_review, :boolean, default: false
  end
end
