require "application_system_test_case"

class TermsTest < ApplicationSystemTestCase
  setup do
    @glossary = glossaries(:glossary_0)
    @doc = documents(:document_0)
    @admin = users(:siriguejo)
    @owner = users(:reginald)
    @pj = users(:jarjar)
  end

  test 'new term as admin' do
    login_as @admin
    visit glossary_url(id: @glossary.id)

    click_on I18n.t('glossaries.show.new_term')
    assert_selector 'form#new_term .grid-row', count: 1
    find('form#new_term .grid-row button', text: I18n.t('terms.form_row.save')).click
    assert_selector 'form#new_term .grid-row .invalid-feedback', count: 1
    find('form#new_term .grid-row button', text: I18n.t('terms.form_row.cancel')).click
    assert_no_selector 'form#new_term', minimum: 1

    click_on I18n.t('glossaries.show.new_term')

    fill_in 'term_source', with: 'macarrão'
    fill_in 'term_target', with: 'pasta'
    assert_difference 'Term.count', 1, 'term instance was not created' do
      find('button', text: I18n.t('terms.form_row.save')).click
      sleep(0.5)
    end

    assert_selector '.grid-row span', text: 'macarrão', wait: 10
    assert_selector '.grid-row span', text: 'pasta'
  end

  test 'new term as authorized user' do
    login_as @owner
    visit glossary_url(id: @glossary.id)

    click_on I18n.t('glossaries.show.new_term')
    assert_selector 'form#new_term .grid-row', count: 1
    find('form#new_term .grid-row button', text: I18n.t('terms.form_row.save')).click
    assert_selector 'form#new_term .grid-row .invalid-feedback', count: 1
    find('form#new_term .grid-row button', text: I18n.t('terms.form_row.cancel')).click
    assert_no_selector 'form#new_term', minimum: 1

    click_on I18n.t('glossaries.show.new_term')

    fill_in 'term_source', with: 'macarrão'
    fill_in 'term_target', with: 'pasta'
    assert_difference 'Term.count', 1, 'term instance was not created' do
      find('button', text: I18n.t('terms.form_row.save')).click
      sleep(0.5)
    end

    assert_selector '.grid-row span', text: 'macarrão', wait: 10
    assert_selector '.grid-row span', text: 'pasta'
  end

  test 'new term as unauthorized user' do
    login_as @pj

    visit new_glossary_term_url(glossary_id: @glossary.id)

    assert_current_path root_path
  end

  test 'update term as admin' do
    term = terms(:term_1)
    login_as @admin
    visit glossary_url(id: @glossary.id)

    assert_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", count: 1

    find("#term_#{term.id} a", text: I18n.t('terms.row_content.edit')).click

    assert_no_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", minimum: 1, wait: 10
    assert_selector "turbo-frame#term-#{term.id} form#edit_term_#{term.id}", count: 1

    find("form#edit_term_#{term.id} .grid-row a", text: I18n.t('terms.form_row.cancel')).click

    assert_no_selector "turbo-frame#term-#{term.id} form#edit_term_#{term.id}", minimum: 1, wait: 10
    assert_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", count: 1

    find("#term_#{term.id} a", text: I18n.t('terms.row_content.edit')).click

    fill_in 'term_target', with: 'folha', wait: 10
    find('button', text: I18n.t('terms.form_row.save')).click

    assert_selector "#term_#{term.id} span", text: 'folha', wait: 10
  end

  test 'update term as authorized user' do
    term = terms(:term_1)
    login_as @owner
    visit glossary_url(id: @glossary.id)

    assert_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", count: 1

    find("#term_#{term.id} a", text: I18n.t('terms.row_content.edit')).click

    assert_no_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", minimum: 1, wait: 10
    assert_selector "turbo-frame#term-#{term.id} form#edit_term_#{term.id}", count: 1

    find("form#edit_term_#{term.id} .grid-row a", text: I18n.t('terms.form_row.cancel')).click

    assert_no_selector "turbo-frame#term-#{term.id} form#edit_term_#{term.id}", minimum: 1, wait: 10
    assert_selector "turbo-frame#term-#{term.id} #term_#{term.id}.grid-row", count: 1

    find("#term_#{term.id} a", text: I18n.t('terms.row_content.edit')).click

    fill_in 'term_target', with: 'folha', wait: 10
    find('button', text: I18n.t('terms.form_row.save')).click

    assert_selector "#term_#{term.id} span", text: 'folha', wait: 10
  end

  test 'update term as unauthorized person' do
    term = terms(:term_1)
    login_as @pj
    visit edit_term_url(id: term.id)

    assert_current_path root_path
  end

  test 'delete term as admin' do
    term = terms(:term_1)
    login_as @admin
    visit glossary_url(id: @glossary.id)

    assert_difference "Term.count", -1, 'term instance was not deleted' do
      accept_confirm(I18n.t('alert.are_you_sure')) do
        find("#term_#{term.id} a", text: I18n.t('terms.row_content.delete')).click
      end
      sleep(0.5)
    end

    assert_no_selector "#term_#{term.id} span", text: term.target, wait: 10
  end

  test 'delete term as authorized person' do
    term = terms(:term_1)
    login_as @owner
    visit glossary_url(id: @glossary.id)

    assert_difference "Term.count", -1, 'term instance was not deleted' do
      accept_confirm(I18n.t('alert.are_you_sure')) do
        find("#term_#{term.id} a", text: I18n.t('terms.row_content.delete')).click
      end
      sleep(0.5)
    end

    assert_no_selector "#term_#{term.id} span", text: term.target, wait: 10
  end

  test 'point out the matching terms in the editor' do
    terms = @doc.terms
    chunk_1 = text_chunks(:chunk_0_0)
    terms_1 = terms.where("? ~* source", chunk_1.original)
    chunk_2 = text_chunks(:chunk_0_1)
    terms_2 = terms.where("? ~* source", chunk_2.original)
    terms_3 = Term.where("? ~* source", chunk_2.original)

    login_as @owner
    visit document_url(id: @doc.id)
    find('.op2').click

    # there's no pre selected row when the page first load, so no terms should appear
    assert_no_selector '#glossaries_terms tr', wait: 10

    # checking highlight in text chunk row and terms in terms tab
    find("#chunk_#{chunk_1.id}").double_click
    terms_1.each do |term|
      assert_selector '#glossaries_terms tr td', text: term.source, wait: 10
      assert_selector "#chunk_#{chunk_1.id} .original-chunk .terms span", text: term.source
    end

    find("#chunk_#{chunk_2.id}").click
    # ensuring that the terms highlights disappear on blur
    assert_no_selector "#chunk_#{chunk_1.id} .original-chunk .terms span", minimum: 1, wait: 10
    # as well as the terms in terms tab
    (terms_1 - terms_2).each do |term|
      assert_no_selector '#glossaries_terms tr td', text: term.source
    end

    # ensuring no term from a not associate glossary to the doc appear
    assert (terms_3 - terms_2).length.positive?
    (terms_3 - terms_2).each do |term|
      assert_no_selector '#glossaries_terms tr td', text: term.source
    end

    terms_2.each do |term|
      assert_selector '#glossaries_terms tr td', text: term.source
      assert_selector "#chunk_#{chunk_2.id} .original-chunk .terms span", text: term.source
    end

    # if more than one txt chunk row is selected the highlight and terms should disappear
    find("#chunk_#{chunk_1.id} .original-chunk").click(:control)
    assert_no_selector '#glossaries_terms tr', wait: 10
    find("#chunk_#{chunk_1.id} .original-chunk").click(:control)
    terms_2.each do |term|
      assert_selector '#glossaries_terms tr td', text: term.source, wait: 10
      assert_selector "#chunk_#{chunk_2.id} .original-chunk .terms span", text: term.source
    end
  end

  test 'create new term at editor' do
    chunk = text_chunks(:chunk_0_0)

    login_as @owner
    visit document_url(id: @doc.id)
    find('.op2').click

    find("#chunk_#{chunk.id}", wait: 10).double_click
    assert_selector '#glossaries_terms tr', count: @doc.terms.where("? ~* source", chunk.original).count, wait: 10

    find('.fas.fa-plus').click

    assert_selector 'h3', text: I18n.t('documents.editor.new_term'), wait: 10

    find('select#term_glossary').find(:option, @glossary.name).select_option
    click_on I18n.t('terms.form.continue')

    click_on I18n.t('terms.form.go_back')

    assert_equal @glossary.id.to_s, find('select#term_glossary').value, wait: 10
    click_on I18n.t('terms.form.continue')

    click_on I18n.t('terms.form.save')

    assert_selector 'form#new_term .form-group.term_source .invalid-feedback', count: 1, wait: 10
    assert_selector 'form#new_term .form-group.term_target .invalid-feedback', count: 1

    fill_in 'term_source', with: 'dolor'
    fill_in 'term_target', with: 'dor'

    assert_difference 'Term.count', 1, 'term has not been created' do
      click_on I18n.t('terms.form.save')
      sleep(0.5)
    end
    assert_equal @glossary, Term.last.glossary, wait: 10

    assert_selector '#glossaries_terms td', text: 'dolor'
    assert_selector '#glossaries_terms td', text: 'dor'
  end

  test "select glossaries on editor" do
    chunk = text_chunks(:chunk_0_1)
    glossary2 = glossaries(:glossary_1)

    login_as @owner
    visit document_url(id: @doc.id)
    find('.op2').click

    find("#chunk_#{chunk.id}").double_click
    assert_selector '#glossaries_terms tr', count: @doc.terms.where("? ~* source", chunk.original).count, wait: 10

    click_on I18n.t('documents.editor.select_glossaries')
    assert_selector 'h3', text: I18n.t('glossaries.index.glossaries'), wait: 10

    find("#document_glossaries_glossary_#{glossary2.id}").click
    click_on I18n.t('documents.select_glossaries.save')

    assert_selector '#glossaries_terms td', text: terms(:term_5).source, wait: 10
    assert_selector '#glossaries_terms td', text: terms(:term_5).target
  end
end
