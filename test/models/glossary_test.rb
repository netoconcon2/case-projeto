require 'test_helper'

class GlossaryTest < ActiveSupport::TestCase
  test "should not save without" do
    assert_not Glossary.new(language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.last, company: companies(:sparrow)).save, 'Glossary was saved without name'
    assert_not Glossary.new(name: 'Test', company: companies(:sparrow)).save, 'Glossary was saved without language 1'
    assert_raise ActiveRecord::NotNullViolation do
      Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.last).save
    end
    assert Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.last, company: companies(:sparrow)).save
  end

  test 'language pairs should be different' do
    assert_not Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.first, company: companies(:sparrow)).save
    assert Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.last, company: companies(:sparrow)).save
  end

  test 'language 1 and 2 should be included in glossary languages array' do
    assert_not Glossary.new(name: 'Test', language_1: 'español', language_2: 'japanese', company: companies(:sparrow)).save
    assert_not Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: 'japanese', company: companies(:sparrow)).save
    assert_not Glossary.new(name: 'Test', language_1: 'español', language_2: Glossary::LANGUAGES.first, company: companies(:sparrow)).save
    assert Glossary.new(name: 'Test', language_1: Glossary::LANGUAGES.first, language_2: Glossary::LANGUAGES.last, company: companies(:sparrow)).save
  end

  test 'has many documents' do
    glossary = glossaries(:glossary_0)
    assert_equal DocumentGlossary.where(glossary: glossary).map(&:document), glossary.documents.to_a
  end

  test 'should destroy dependent DocumentGlossaries' do
    glossary = glossaries(:glossary_to_destroy)
    doc_glossary = document_glossaries(:document_glossary_to_destroy_with_glossary)

    assert doc_glossary
    assert glossary.destroy
    assert_raise(ActiveRecord::RecordNotFound) { doc_glossary.reload }
  end
end
