class AddSourceAndTargetToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :source, :string
    add_column :documents, :target, :string

    Document.all.each do |document|
      languages = document.from_to_language.split('_')
      document.source = languages[0]
      document.target = languages[1]
      document.save
    end

    remove_column :documents, :from_to_language
  end
end
