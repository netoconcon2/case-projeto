require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  setup do
    @user = users(:reginald)
  end

  test "should not save without" do
    doc_no_title = Document.new(original_text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                user: @user,
                                company: @user.company,
                                target: Document::LANGUAGES.first,
                                source: Document::LANGUAGES.last)
    assert_not doc_no_title.save, "Document was saved without title"

    doc_no_text = Document.new(title: 'Document for test',
                               user: @user,
                               company: @user.company,
                               target: Document::LANGUAGES.first,
                               source: Document::LANGUAGES.last)
    assert_not doc_no_text.save, "Document was saved without original text"

    doc_no_source = Document.new(original_text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                 title: 'Document for test',
                                 user: @user,
                                 company: @user.company,
                                 target: Document::LANGUAGES.first)
    assert_not doc_no_source.save, "Document was saved without source language"

    doc_no_target = Document.new(original_text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                 title: 'Document for test',
                                 user: @user,
                                 company: @user.company,
                                 source: Document::LANGUAGES.last)
    assert_not doc_no_target.save, "Document was saved without target language"
  end

  test "company should not have two documents with same title" do
    document_test = Document.new(title: "Test Title", original_text: "Lorem ipsum", user: @user, company: @user.company)
    assert_not document_test.save, "Saved document having doc with same title"
    assert_equal I18n.t('errors.messages.taken'), document_test.errors.messages[:title].first, "Error message is different"
  end

  test 'should return every user responsible by a doc chunk' do
    assert_equal 1, documents(:document_0).responsibles.length
    assert_equal users(:reginald), documents(:document_0).responsibles.first
  end

  test 'should not have same source and target languages' do
    document_same_language = Document.new(original_text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                          title: 'Document for test',
                                          user: @user,
                                          company: @user.company,
                                          target: Document::LANGUAGES.first,
                                          source: Document::LANGUAGES.first)
    assert_not document_same_language.save, "Document was saved with same source and target language"
  end

  test 'has many glossaries and terms' do
    document = documents(:document_0)
    assert_equal DocumentGlossary.where(document: document).map(&:glossary), document.glossaries.to_a
    assert_equal Term.where(glossary: document.glossaries), document.terms
  end

  test 'should destroy dependent DocumentGlossaries' do
    document = documents(:document_to_destroy)
    doc_glossary = document_glossaries(:document_glossary_to_destroy_with_document)

    assert doc_glossary
    assert document.destroy
    assert_raise(ActiveRecord::RecordNotFound) { doc_glossary.reload }
  end

  test "new document should be created with default status" do
    document_test = Document.new(title: "Document to check default status", original_text: "Lorem ipsum", user: @user, company: @user.company)
    assert_not document_test.status.nil?, "Document was created with no status"
    assert document_test.status = "original", "Document default status isn't 0 ('original')"
  end
end
