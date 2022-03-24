class AddRichTranslatedToTextChunk < ActiveRecord::Migration[6.0]
  def up
    add_column :text_chunks, :rich_translated, :text
    TextChunk.all.each { |chunk| chunk.update(rich_translated: "<div>#{chunk.translated}</div>") }
  end

  def down
    remove_column :text_chunks, :rich_translated
  end
end
