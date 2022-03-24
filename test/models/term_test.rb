require 'test_helper'

class TermTest < ActiveSupport::TestCase
  test "should not save without" do
    assert_not Term.new(target: 'lawyer', glossary: glossaries(:glossary_0)).save
    assert_not Term.new(source: 'advogado', glossary: glossaries(:glossary_0)).save
    assert_not Term.new(source: 'advogado', target: 'lawyer').save
    assert Term.new(source: 'advogado', target: 'lawyer', glossary: glossaries(:glossary_0)).save
  end
end
