require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @owner = users(:vader)
    @employee = users(:trooper)
    @pj = users(:jarjar)
    @empire = companies(:empire)
  end

  test "docs from desktop version" do
    current_user = @owner

    login_as current_user
    visit documents_url

    assert_no_selector '.btn-arrows', minimum: 1
    assert_selector '#query_title', count: 1
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "docs list desktop version" do
    current_user = @owner

    login_as current_user
    visit documents_url

    assert_text I18n.t('documents.index.added_at').upcase, count: 1
    assert_text I18n.t('documents.index.status').upcase, count: 1
  end

  test "manager's index document" do
    # should be only accessible by the people of the company
    # should only have documents from the company

    current_user = @owner
    docs = current_user.company.documents
    total_pages = docs.page.total_pages

    login_as current_user

    visit documents_url

    n_docs = 0
    for i in 1..total_pages do
      n_docs += all('.grid-table .grid-row').count
      assert_selector '.grid-table .grid-row', count: docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-trash', count: docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-eye', count: docs.page(i).count

      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal docs.count, n_docs
  end

  test "employee index document" do
    # should be only accessible by the people of the company
    # should only have documents from the employee
    current_user = @employee
    docs = current_user.company.documents
    user_docs = current_user.documents
    total_pages = user_docs.page.total_pages

    login_as current_user

    visit documents_url

    n_docs = 0
    for i in 1..total_pages do
      assert_selector '.grid-table .grid-row', count: user_docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-trash', count: user_docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: user_docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-eye', count: user_docs.page(i).count
      n_docs += all('.grid-table .grid-row .fa-trash').count

      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal current_user.documents.size, n_docs
    assert_not_equal docs.size, n_docs
  end

  test "owner's show document" do
    current_user = @owner
    login_as current_user

    document = current_user.documents.original.first

    visit document_url(id: document.id)

    assert_selector 'strong', text: "#{I18n.t('documents.show.document')}: #{document.title}"
    assert_selector '#document_original_text', text: document.original_text
    assert_selector '#translate'
  end

  test "not owner's show document" do
    current_user = @employee
    login_as current_user

    document = current_user.company.documents.first

    visit document_url(id: document.id)

    assert_current_path root_path
  end

  test "not authorized show document" do
    current_user = @pj
    login_as current_user

    document = @empire.documents.first

    visit document_url(id: document.id)

    assert_current_path root_path
  end

  test "owner's document show page (without being sent)" do
    current_user = @owner
    login_as current_user

    document = current_user.documents.original.first

    visit document_url(id: document.id)

    assert_selector "p", text: I18n.t('documents.show.original_description')
    assert_selector "input[type=submit][value='#{I18n.t('documents.translate_form.translate')}']"
  end

  test "not owner's document show page (without being sent)" do
    current_user = @employee
    login_as current_user

    document = current_user.company.documents.original.first

    visit document_url(id: document.id)

    assert_current_path root_path # employee should not have access to the translate form
  end

  test "owner's document show page (under translation)" do
    current_user = @owner
    login_as current_user

    document = current_user.documents.being_translated.first

    visit document_url(id: document.id)

    assert_selector "p", text: I18n.t('documents.show.being_translated_description')
    assert_selector "#document_original_text[disabled='disabled']", text: document.original_text
  end

  test "not owner's document show page (under translation)" do
    current_user = @employee
    login_as current_user

    document = current_user.documents.being_translated.first

    visit document_url(id: document.id)

    assert_current_path document_path(id: document.id)
  end

  test "owner's document show page (under revision)" do
    current_user = @owner
    login_as current_user

    document = current_user.documents.being_reviewed.first

    visit document_url(id: document.id)

    assert_selector "p", text: I18n.t('documents.show.being_reviewed_description')
    assert_selector "#document_original_text[disabled='disabled']", text: document.original_text
  end

  test "not owner's document show page (under revision)" do
    current_user = @employee
    login_as current_user

    document = current_user.documents.being_reviewed.first

    visit document_url(id: document.id)

    assert_current_path document_path(id: document.id)
  end

  test "owner's document show page (translated)" do
    current_user = @owner
    login_as current_user

    document = documents(:document_01)

    visit document_url(id: document.id)

    assert_selector 'strong', text: document.title
    assert_selector '#document_original_text[disabled="disabled"]', text: document.original_text
    assert_selector '.chunk-row', count: document.text_chunks.count
    document.text_chunks.each do |chunk|
      assert_selector '.text_chunk_translated_content', text: chunk.translated
    end
  end

  test "not owner's document translation page (translated)" do
    current_user = @employee
    login_as current_user

    document = documents(:document_01)
    visit document_url(id: document.id)

    assert_current_path root_path # employee should not have access to someone else's document
  end

  test "new document on completed company" do
    total_docs = @empire.documents.count
    login_as @owner

    visit documents_url

    click_on I18n.t('documents.index.add_new_document')

    fill_in "document_title", with: 'Death Star Weakness'
    select(I18n.t('languages.en'), from: 'document_source')
    select(I18n.t('languages.pt-BR'), from: 'document_target')
    fill_in "document_original_text", with: 'Guys, I really think we need to remove that one specific spot in our Death Star that makes everything goes boom!'

    click_on I18n.t('documents.form.save')

    assert_current_path document_path(id: Document.last.id)
    visit documents_url

    total_pages = @empire.documents.page.total_pages
    n_docs = 0

    for i in 1..total_pages do
      n_docs += all(".grid-table .grid-row").count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i+1
      end
    end
    assert_equal total_docs + 1, n_docs
  end

  test "new document on validated but not completed company" do
    login_as @pj

    visit documents_url
    assert_no_text I18n.t('documents.index.add_new_document')

    visit new_document_url

    assert_current_path root_path
  end

  test "edit document title as authorized person" do
    current_user = @employee
    document = current_user.documents.order(updated_at: :desc).first

    login_as current_user

    visit documents_url
    assert_selector "#document-row-#{document.id} .fa-pen", count: 1

    find("#document-row-#{document.id} .fa-pen").click

    assert_selector('#document_title', wait: 10)
    fill_in 'document_title', with: 'New title!'
    click_on I18n.t('documents.form.save')
    assert_current_path documents_path
    assert_text 'New title!'

    visit document_url(id: document.id)

    find('.document-show-title .fa-pen').click

    assert_selector('#document_title', wait: 10)
    fill_in 'document_title', with: 'New title yet again!'
    click_on I18n.t('documents.form.save')
    assert_current_path document_path(id: document.id), wait: 10
    assert_selector 'strong', text: 'New title yet again!'
  end

  test "edit document as unauthorized person" do
    current_user = @pj
    document = @employee.documents.first

    login_as current_user

    visit documents_url
    assert_no_selector "#document_#{document.id} .fa-pen", minimum: 1

    visit edit_document_url(id: document.id)

    assert_current_path root_path
  end

  test "authorized person deleting a document" do
    current_user = @owner
    total_docs = @empire.documents.count
    document = documents(:document_last)

    login_as current_user
    visit documents_url

    accept_confirm(I18n.t('alert.are_you_sure')) do
      find("#document-row-#{document.id} .fa-trash").click
    end
    assert_current_path documents_path

    assert_no_selector("#document-row-#{document.id}", wait: 10) # Checks if the element was removed by Turbo

    page.driver.browser.navigate.refresh # reloads the page - needed to ensure the correct count when paginating
    sleep(0.5)

    total_pages = @empire.documents.page.total_pages
    n_docs = 0

    for i in 1..total_pages do
      n_docs += all(".grid-table .grid-row").count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal total_docs - 1, n_docs
  end

  test "delete document as unauthorized person" do
    current_user = @pj
    document = @employee.documents.first

    login_as current_user

    visit documents_url
    assert_no_selector "#document-row-#{document.id} .fa-trash", minimum: 1
  end

  test "searching documents by title" do
    login_as @owner
    visit documents_url

    fill_in 'query_title', with: 'two'
    click_on I18n.t('documents.index_filter_form.search').upcase

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'Two baccas'
  end

  test "searching documents by user" do
    documents = Document.search_by_text('strm')
    total_pages = documents.page.total_pages
    n_doc = 0

    login_as @owner
    visit documents_url

    fill_in 'query_title', with: 'strm'
    click_on I18n.t('documents.index_filter_form.search').upcase

    for i in 1..total_pages do
      n_doc += all(".grid-table .grid-row").count
      documents.page(i).each { |doc| assert_selector '.grid-row span', text: doc.title }

      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end

    assert_equal documents.size, n_doc
  end

  test "searching documents by status" do
    # skip "Document status not defined"
    documents = @empire.documents.where(status: 1)
    total_pages = documents.page.total_pages
    n_doc = 0
    login_as @owner
    visit documents_url

    find('#dropdownSelectBtn').click
    find(:css, '#status_1[value="1"]').set(true)
    click_on I18n.t('documents.index_filter_form.search').upcase

    for i in 1..total_pages do
      n_doc += all(".grid-table .grid-row").count
      documents.page(i).each do |doc|
        assert_selector '.grid-table .grid-row span', text: doc.title
      end
      find("a#next").click unless i == total_pages
    end

    assert_equal documents.size, n_doc
  end

  test "searching documents by date range" do
    ## the documents variable have to be this big in order to be exactly like the search behavior
    eleven_days = 11.days.ago.strftime('%d/%m/%Y')
    four_days = 4.days.ago.strftime('%d/%m/%Y')
    documents = Document.where(company: @owner.company).order(updated_at: :desc).where(created_at: DateTime.parse(eleven_days)...DateTime.parse(four_days).end_of_day)
    total_pages = documents.page.total_pages
    n_doc = 0
    login_as @owner
    visit documents_url

    fill_in 'query_date_start', with: eleven_days
    fill_in 'query_date_end', with: four_days + "\n"
    click_on I18n.t('documents.index_filter_form.search').upcase

    for i in 1..total_pages do
      n_doc += all(".grid-table .grid-row").count
      documents.page(i).each { |doc| assert_selector "#document-#{doc.id}-title", text: doc.title, wait: 10 }
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal documents.size, n_doc
  end

  test "searching documents using all inputs" do
    twentyone_days = 21.days.ago.strftime('%d/%m/%Y')
    fifteen_days = 15.days.ago.strftime('%d/%m/%Y')
    documents = Document.search_by_text('strm').where(created_at: DateTime.parse(twentyone_days)...DateTime.parse(fifteen_days).end_of_day)
    total_pages = documents.page.total_pages
    n_doc = 0
    login_as @owner
    visit documents_url

    fill_in 'query_title', with: 'strm'
    # find('#dropdownSelectBtn').click
    # find(:css, '#status_1[value="1"]').set(true)
    fill_in 'query_date_start', with: twentyone_days
    fill_in 'query_date_end', with: fifteen_days + "\n"
    click_on I18n.t('documents.index_filter_form.search').upcase

    if total_pages == 1
      documents.each { |doc| assert_selector '.grid-row span', text: doc.title }
    else
      for i in 1..total_pages do
        n_doc += all(".grid-table .grid-row").count
        documents.page(i).each { |doc| assert_selector '.grid-row span', text: doc.title }
        unless i == total_pages
          find("a#next").click
          assert_selector '.page.current', text: i + 1
        end
      end
    end
    assert_equal documents.size, all(".grid-table .grid-row").count
  end

  test "download original file as docx" do
    current_user = @owner
    login_as current_user

    document = documents(:document_01)

    visit document_url(id: document.id)

    click_on I18n.t('documents.export_docx.export_document')
    click_on I18n.t('documents.export_docx.original_file')
    file_path = "#{Rails.root}/tmp/downloads/#{document.title} - Original.docx"
    sleep 0.5 # gives the tests more time for downloading the file
    assert File.exist?(file_path), wait: 10
  end

  test "download translation file (pure text) as docx" do
    current_user = @owner
    login_as current_user

    document = documents(:document_01)

    visit document_url(id: document.id)

    click_on I18n.t('documents.export_docx.export_document')
    click_on I18n.t('documents.export_docx.translated_file')
    file_path = "#{Rails.root}/tmp/downloads/#{document.title} - Translated.docx"
    sleep 0.5 # gives the tests more time for downloading the file
    assert File.exist?(file_path), wait: 10
  end

  test "download translation file (rich text) as docx" do
    current_user = @owner
    login_as current_user

    document = documents(:document_01)

    visit document_url(id: document.id)

    click_on I18n.t('documents.export_docx.export_document')
    click_on I18n.t('documents.export_docx.rich_text_file')
    file_path = "#{Rails.root}/tmp/downloads/#{document.title} - Rich Text.docx"
    sleep 0.5 # gives the tests more time for downloading the file
    assert File.exist?(file_path), wait: 10
  end

  test "download bicolumn file as docx" do
    current_user = @owner
    login_as current_user

    document = documents(:document_01)

    visit document_url(id: document.id)

    click_on I18n.t('documents.export_docx.export_document')
    click_on I18n.t('documents.export_docx.bicolumn_file')
    file_path = "#{Rails.root}/tmp/downloads/#{document.title} - Bicolumn.docx"
    sleep 0.5 # gives the tests more time for downloading the file
    assert File.exist?(file_path), wait: 10
  end
end
