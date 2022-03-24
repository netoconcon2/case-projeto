require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @admin = users(:siriguejo)
    @owner = users(:reginald)
    @pj = users(:jarjar)
    @doc = documents(:document_0)
  end

  test 'editor view as admin' do
    login_as @admin
    visit root_url

    find('a.dash-nav-item', text: I18n.t('shared.dashboard_navbar.documents')).click
    assert_current_path documents_path

    fill_in 'query_title', with: 'Test'
    click_on I18n.t('documents.index_filter_form.search').upcase
    assert_selector '.grid-table .grid-row span', text: 'Test Title', wait: 10

    find('.grid-row', text: @doc.title).find('.fa-eye').click
    assert_current_path document_path(id: @doc.id)

    find('.op2').click

    assert_selector '.chunk-row', count: @doc.text_chunks.count, wait: 10
    @doc.text_chunks.each do |chunk|
      assert_selector '.text_chunk_translated_content', text: chunk.translated
    end
  end

  test 'editor view as owner' do
    login_as @owner
    visit root_url

    find('a.dash-nav-item', text: I18n.t('shared.dashboard_navbar.documents')).click
    find('.grid-row', text: @doc.title).find('.fa-eye').click

    assert_current_path document_path(id: @doc.id)

    find('.op2').click

    assert_selector '.chunk-row', count: @doc.text_chunks.count, wait: 10
    @doc.text_chunks.each do |chunk|
      assert_selector '.text_chunk_translated_content', text: chunk.translated
    end
  end

  test 'editor view as unauthorized person' do
    login_as @pj
    visit root_url

    visit document_url(id: @doc.id)

    assert_current_path root_path
  end

  test 'changing text chunk status as admin' do
    chunk = text_chunks(:chunk_0_1)
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.translated'), wait: 10
    find("#chunk_#{chunk.id} a.btn-arrow").click
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.approved'), wait: 10

    find("#chunk_#{chunk.id} .text_chunk_translated_content").set("Lorem")
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.edited'), wait: 10
  end

  test 'changing text chunk status as owner' do
    chunk = text_chunks(:chunk_0_1)
    login_as @owner
    visit document_url(id: @doc.id)
    find('.op2').click

    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.translated'), wait: 10
    find("#chunk_#{chunk.id} a.btn-arrow").click
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.approved'), wait: 10

    find("#chunk_#{chunk.id} .text_chunk_translated_content").set("Lorem")
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.edited'), wait: 10
  end

  test 'after the last chunk be approved the doc should update' do
    doc_in_review = documents(:document_1)
    login_as @admin
    visit document_url(id: doc_in_review.id)
    find('.op2').click

    assert_equal 'being_reviewed', doc_in_review.status, wait: 10
    doc_in_review.text_chunks.each do |chunk|
      find("#chunk_#{chunk.id} a.btn-arrow").click
      unless chunk == doc_in_review.text_chunks.last
        assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.approved'), wait: 10
      end
    end

    sleep(0.5)
    assert_equal 'translated', Document.find(doc_in_review.id).status
  end

  test 'confirm selected rows in editor' do
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    chunk = text_chunks(:chunk_0_1)

    assert_no_selector "#chunk_#{chunk.id}.selected", minimum: 1, wait: 10
    find("#chunk_#{chunk.id}").click
    assert_selector "#chunk_#{chunk.id}.selected", count: 1, wait: 10
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.translated')

    find('button', text: I18n.t('documents.editor.confirm_paragraph')).click
    assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.approved'), wait: 10
  end

  test 'confirm all rows in editor' do
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    @doc.text_chunks.each do |chunk|
      assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.translated'), wait: 10
    end

    find('button', text: I18n.t('documents.editor.confirm_all_paragraphs')).click
    @doc.text_chunks.each do |chunk|
      assert_selector "#chunk_#{chunk.id} .actions", text: I18n.t('activerecord.attributes.text_chunk.status_list.approved'), wait: 10
    end
  end

  test "focus next unconfirmed chunk by button in editor" do
    first_unconfirmed_chunk = @doc.text_chunks.where(status: ["edited", "translated", "reviewed"]).order(order: :asc).first
    second_unconfirmed_chunk = @doc.text_chunks.where(status: ["edited", "translated", "reviewed"]).order(order: :asc).second
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    assert_no_selector "tbody.selected", minimum: 1, wait: 10
    find('button', text: I18n.t('documents.editor.next_unconfirmed')).click

    assert_selector "tbody.selected", count: 1, wait: 10
    assert_selector "#chunk_#{first_unconfirmed_chunk.id}.selected", count: 1
    find('button', text: I18n.t('documents.editor.next_unconfirmed')).click

    assert_selector "tbody.selected", count: 1, wait: 10
    assert_selector "#chunk_#{second_unconfirmed_chunk.id}.selected", count: 1

    first_unconfirmed_chunk.approved!
    visit current_path
    find('.op2').click

    find('button', text: I18n.t('documents.editor.next_unconfirmed')).click
    assert_selector "tbody.selected", count: 1, wait: 10
    assert_selector "#chunk_#{second_unconfirmed_chunk.id}.selected", count: 1
  end

  test "editor select rows" do
    text_chunks = @doc.text_chunks.order(order: :asc)
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    find("#chunk_#{text_chunks.first.id}").click
    assert_selector "tbody.selected", count: 1, wait: 10
    assert_selector "#chunk_#{text_chunks.first.id}.selected", count: 1

    find("#chunk_#{text_chunks.third.id} .original-chunk").click(:control)
    assert_selector "tbody.selected", count: 2, wait: 10
    assert_selector "#chunk_#{text_chunks.third.id}.selected", count: 1

    find("#chunk_#{text_chunks.first.id}").click
    assert_selector "tbody.selected", count: 1, wait: 10
    assert_selector "#chunk_#{text_chunks.first.id}.selected", count: 1

    find("#chunk_#{text_chunks.third.id} .original-chunk").click(:shift)
    assert_selector "tbody.selected", count: 3, wait: 10
    assert_selector "#chunk_#{text_chunks.second.id}.selected", count: 1
    assert_selector "#chunk_#{text_chunks.third.id}.selected", count: 1
  end

  test 'chunk versions modal' do
    chunk_1 = text_chunks(:chunk_0_1)
    chunk_2 = text_chunks(:chunk_0_3)
    chunk_1.approved!
    chunk_1.update(rich_translated: '<div>Aquele que ama ou exerce ou deseja a dor, pode às vezes adquirir algum prazer na labuta.</div>')
    chunk_2.approved!
    chunk_2.update(rich_translated: '<div>Está tão cego pelo desejo que não pode prever quem não cumprirá seu dever por vontade fraca.</div>')
    versions_1 = PaperTrail::Version.where(item_type: 'TextChunk', item_id: chunk_1.id)
    versions_2 = PaperTrail::Version.where(item_type: 'TextChunk', item_id: chunk_2.id)

    login_as @admin

    visit document_url(id: @doc.id)
    find('.op2').click

    # The Versions button should be disabled on the toolbar when there's no chunk selected
    assert_selector 'button#versions:disabled', wait: 10

    # Select one chunk
    # When one chunk is selected, the Versions button should be enabled on the toolbar
    find("#chunk_#{chunk_1.id}").click
    assert_selector 'button#versions:enabled', wait: 10
    find("button#versions:enabled").click

    # The versions history will open in a modal
    versions_1.each do |version|
      assert_selector '#chunk_versions_info tr td', text: version.reify.translated, wait: 10
    end

    find('.modal-close-button', visible: false).click

    # Select another chunk
    find("#chunk_#{chunk_2.id}", wait: 10).click
    find("button#versions:enabled", wait: 10).click

    # Checks if the versions from the previous chuk don't exist anymore
    assert_no_selector "#chunk_#{chunk_1.id} .original-chunk .versions span", minimum: 1, wait: 10
    (versions_1 - versions_2).each do |version|
      assert_no_selector '#chunk_versions_info tr td', text: version.reify.translated
    end

    versions_2.each do |version|
      assert_selector '#chunk_versions_info tr td', text: version.reify.translated
    end

    find('.modal-close-button', visible: false).click

    # Select two chunks at the same time
    # The Versions button should be disabled
    find("#chunk_#{chunk_1.id} .original-chunk").click(:control)
    assert_selector 'button#versions:disabled', wait: 10

    # Unselect one of the chunks
    find("#chunk_#{chunk_1.id} .original-chunk").click(:control)
    assert_selector 'button#versions:enabled', wait: 10
    find("button#versions:enabled").click

    versions_2.each do |version|
      assert_selector '#chunk_versions_info tr td', text: version.reify.translated
    end
  end

  test "go to editor chunk line by button" do
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    find('a', text: I18n.t('documents.editor.go_to_row_number'), wait: 10).click
    fill_in 'row_number_order', with: 3, wait: 10
    click_on I18n.t('documents.row_number.jump')

    assert_selector "tbody.selected", count: 1
    assert_selector "#chunk_#{@doc.text_chunks.order(order: :asc).third.id}.selected", count: 1

    find('a', text: I18n.t('documents.editor.go_to_row_number')).click
    fill_in 'row_number_order', with: 10
    assert_selector '.invalid-feedback', text: I18n.t('javascript.modal.editor.error_maximum', max_value: @doc.text_chunks.order(order: :desc).first.order)

    fill_in 'row_number_order', with: -1
    assert_selector '.invalid-feedback', text: I18n.t('javascript.modal.editor.error_negative')
  end

  test "editor search chunks" do
    login_as @admin
    visit document_url(id: @doc.id)
    find('.op2').click

    assert_selector '.chunk-row', count: @doc.text_chunks.count, wait: 10
    fill_in 'search_original', with: 'dolor'
    search_original_matches = @doc.text_chunks.where("original ~* ?", Regexp.escape('dolor'))
    assert_selector '.chunk-row', count: search_original_matches.count, wait: 10
    search_original_matches.each do |chunk|
      assert_selector "#chunk_#{chunk.id} .original-chunk .search-results span", text: 'dolor'
    end

    find('button', text: I18n.t('documents.editor.clean_filters')).click
    assert_selector '.chunk-row', count: @doc.text_chunks.count, wait: 10

    fill_in 'search_translated', with: 'des'
    search_translated_matches = @doc.text_chunks.where("translated ~* ?", Regexp.escape('des'))
    assert_selector '.chunk-row', count: search_translated_matches.count, wait: 10
    search_translated_matches.each do |chunk|
      assert_selector "#chunk_#{chunk.id} .translated-chunk .chunk-highlight span", minimum: 1
    end

    find('#search_sensitive_case').set(true)
    search_translated_matches_sensitive = @doc.text_chunks.where("translated ~ ?", Regexp.escape('des'))
    assert_selector '.chunk-row', count: search_translated_matches_sensitive.count, wait: 10
    search_translated_matches_sensitive.each do |chunk|
      assert_selector "#chunk_#{chunk.id} .translated-chunk .chunk-highlight span", text: 'es'
    end
  end

  test "editor text attributes buttons" do
    chunk = text_chunks(:chunk_1_1)
    word_range_1 = [chunk.translated.index('perguntaria'), chunk.translated.index('perguntaria') + 'perguntaria'.length]
    word_range_2 = [chunk.translated.index('o que'), chunk.translated.index('o que') + 'o que'.length]
    word_range_3 = [chunk.translated.index('você'), chunk.translated.index('você') + 'você'.length]
    word_range_4 = [chunk.translated.index('está'), chunk.translated.index('está') + 'está'.length]
    login_as @admin
    visit document_url(id: documents(:document_1))
    find('.op2').click

    assert_selector('.chunks', wait: 10)
    page.execute_script("document.querySelector('#chunk_#{chunk.id} trix-editor').editor.setSelectedRange(#{word_range_1})")
    find('button', text: I18n.t('documents.rich_text_toolbar.bold'), wait: 10).click
    assert_selector "#chunk_#{chunk.id} trix-editor strong", text: 'perguntaria'

    page.execute_script("document.querySelector('#chunk_#{chunk.id} trix-editor').editor.setSelectedRange(#{word_range_2})")
    find('button', text: I18n.t('documents.rich_text_toolbar.italic'), wait: 10).click
    assert_selector "#chunk_#{chunk.id} trix-editor em", text: 'o que'

    page.execute_script("document.querySelector('#chunk_#{chunk.id} trix-editor').editor.setSelectedRange(#{word_range_3})")
    find('button', text: I18n.t('documents.rich_text_toolbar.strike'), wait: 10).click
    assert_selector "#chunk_#{chunk.id} trix-editor del", text: 'você'

    page.execute_script("document.querySelector('#chunk_#{chunk.id} trix-editor').editor.setSelectedRange(#{word_range_4})")
    find('button', text: I18n.t('documents.rich_text_toolbar.underline'), wait: 10).click
    assert_selector "#chunk_#{chunk.id} trix-editor u", text: 'está'
  end

  test "editor block attributes button" do
    chunk = text_chunks(:chunk_1_1)
    login_as @admin
    visit document_url(id: documents(:document_1))
    find('.op2').click

    find("#chunk_#{chunk.id} trix-editor", wait: 10).click
    find('button', text: I18n.t('documents.rich_text_toolbar.heading')).click
    assert_selector "#chunk_#{chunk.id} trix-editor h1", text: chunk.translated
    find('button', text: I18n.t('documents.rich_text_toolbar.heading')).click
    assert_selector "#chunk_#{chunk.id} trix-editor h2", text: chunk.translated
    find('button', text: I18n.t('documents.rich_text_toolbar.heading')).click
    assert_selector "#chunk_#{chunk.id} trix-editor h3", text: chunk.translated
    find('button', text: I18n.t('documents.rich_text_toolbar.heading')).click
    assert_selector "#chunk_#{chunk.id} trix-editor div", text: chunk.translated
  end
end
