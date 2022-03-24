require 'test_helper'

class DocumentGlossaryTest < ActiveSupport::TestCase
  test "should has uniq document and glossary pair" do
    doc_glossary_1 = document_glossaries(:document_glossary_0_0)
    assert_not DocumentGlossary.new(document: doc_glossary_1.document, glossary: doc_glossary_1.glossary).save
    assert DocumentGlossary.new(document: documents(:document_2), glossary: doc_glossary_1.glossary).save
  end
end
