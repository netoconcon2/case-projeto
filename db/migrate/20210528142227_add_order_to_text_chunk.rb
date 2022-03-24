class AddOrderToTextChunk < ActiveRecord::Migration[6.0]
  def change
    add_column :text_chunks, :order, :integer
  end
end
