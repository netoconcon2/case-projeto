require 'test_helper'

class TextChunkTest < ActiveSupport::TestCase
  setup do
    @doc = documents(:document_0)
    @txt_chunk = text_chunks(:chunk_0_0)
  end

  test "should not save without" do
    assert_not TextChunk.new(original: 'Lorem', translated: 'Dorime', order: 3).save, 'Text was saved without document id'
    assert_not TextChunk.new(document: @doc, translated: 'Dorime', order: 3).save, 'Text was saved without original text'
    assert_not TextChunk.new(document: @doc, original: 'Lorem', order: 3).save, 'Text was saved without translated text'
    assert_not TextChunk.new(document: @doc, original: 'Lorem').save, 'Text was saved without order'
    assert TextChunk.new(original: 'Lorem', translated: 'Dorime', document: @doc, order: @doc.text_chunks.order(order: :desc).first.order + 1).save
  end

  test "should set rich translated before create" do
    chunk =  TextChunk.create(original: 'Lorem', translated: 'Dorime', document: @doc, order: @doc.text_chunks.order(order: :desc).first.order + 1)
    assert_equal "<div>#{chunk.translated}</div>", chunk.rich_translated
  end

  test "rich translated right format" do
    chunk = text_chunks(:chunk_0_0)

    assert chunk.valid?
    chunk.rich_translated = chunk.translated
    assert_not chunk.valid?
    chunk.rich_translated = "<h1>#{chunk.translated}</h1>"
    assert chunk.valid?
    chunk.rich_translated = "<h2>#{chunk.translated}</h2>"
    assert chunk.valid?
    chunk.rich_translated = "<h3>#{chunk.translated}</h3>"
    assert chunk.valid?
    chunk.rich_translated = "<h4>#{chunk.translated}</h4>"
    assert_not chunk.valid?
    chunk.rich_translated = "<strong>#{chunk.translated}</strong>"
    assert_not chunk.valid?
    chunk.rich_translated = "<div>#{chunk.translated}</div>"
    assert chunk.valid?
  end

  test 'respective numbers should return right text chunk statuses' do
    assert_equal 'approved', TextChunk.new(status: 0).status
    assert_equal 'reviewed', TextChunk.new(status: 1).status
    assert_equal 'translated', TextChunk.new(status: 2).status
    assert_equal 'edited', TextChunk.new(status: 3).status
  end

  test 'order number should be unique and positive' do
    assert_not TextChunk.new(original: 'Lorem', translated: 'Dorime', document: @doc, order: 1).save, 'text chunk containing this order number already exists'
    assert TextChunk.new(original: 'Lorem', translated: 'Dorime', document: @doc, order: @doc.text_chunks.order(order: :desc).first.order + 1).save

    assert_not TextChunk.new(original: 'noises noises', translated: 'ruídos ruídos', document: documents(:document_01), order: 1).save, 'text chunk containing this order number already exists'
    assert TextChunk.new(original: 'noises noises', translated: 'ruídos ruídos', document: documents(:document_01), order: 2).save

    assert_not TextChunk.new(original: 'Lorem', translated: 'Dorime', document: @doc, order: -1).save, 'order has been saved as a negative number'
    assert_not TextChunk.new(original: 'Lorem', translated: 'Dorime', document: @doc, order: 0).save, 'order has been saved as zero'
  end

  test 'responsible foreign key' do
    assert_equal users(:reginald), @txt_chunk.responsible
    assert_nil text_chunks(:chunk_0_1).responsible
    assert_raises(NoMethodError) { @txt_chunk.user }
  end

  test 'responsible should be the document owner, their manager, or admin' do
    assert_not @txt_chunk.update(responsible: users(:wesley)) # manager from another company
    assert @txt_chunk.update(responsible: users(:reginald)) # document owner
    assert @txt_chunk.update(responsible: users(:pogo)) # document company manager
    assert @txt_chunk.update(responsible: users(:siriguejo)) # admin
  end

  test 'papertrail new version' do
    test_chunk = TextChunk.create(order: 2, original: 'noises', translated: 'ruídos', document: documents(:document_01), status: 3)
    # Checking if a version has been created after instance is created
    assert_equal 1, test_chunk.versions.length
    # Checking if changing the status to translated creates a new version
    test_chunk.update(status: 1)
    assert_equal 1, test_chunk.versions.length
    # Checking if updating the translated rich text creates a new version
    test_chunk.update(rich_translated: '<div>barulhos</div>')
    assert_equal 'edited', test_chunk.status
    assert_equal 1, test_chunk.versions.length
    # Checking if updating back the translated text creates a new version
    test_chunk.update(status: 1)
    assert test_chunk.update(rich_translated: '<div>ruídos</div>')
    assert_equal 2, test_chunk.versions.length
    assert_equal 'ruídos', test_chunk.translated, 'translated column did not updated according rich translated column'
  end
end
