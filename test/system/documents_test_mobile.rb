require "mobile_system_test_case"

class MobileDocumentsTest < MobileSystemTestCase
  setup do
    @owner = users(:vader)
    @employee = users(:trooper)
    @pj = users(:jarjar)
    @empire = companies(:empire)
  end

  test "docs form mobile version" do
    current_user = @owner

    login_as current_user
    visit documents_url

    assert_selector '#query_title', count: 1
    assert_no_selector '#dropdownSelectBtn', minimum: 1
    assert_no_selector '#query_date_start', minimum: 1
    assert_no_selector '#query_date_end', minimum: 1
    find('.btn-arrows').click()
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "docs list mobile version" do
    current_user = @owner

    login_as current_user
    visit documents_url

    assert_no_text I18n.t('documents.index.added_at'), count: 1
    assert_no_text I18n.t('documents.index.status'), count: 1
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
      assert_selector '.grid-table .grid-row .fa-times', count: docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-language', count: docs.page(i).count

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
      assert_selector '.grid-table .grid-row .fa-times', count: user_docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: user_docs.page(i).count
      assert_selector '.grid-table .grid-row .fa-language', count: user_docs.page(i).count
      n_docs += all('.grid-table .grid-row .fa-times').count

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

    document = current_user.documents.first

    visit document_url(document)

    assert_selector 'h2', text: document.title
    assert_selector '#document_original_text', text: document.original_text
    assert_selector '#translate'
  end

  test "not owner's show document" do
    current_user = @employee
    login_as current_user

    document = current_user.company.documents.first

    visit document_url(document)

    assert_selector 'h2', text: document.title
    assert_selector '#document_original_text', text: document.original_text
    assert_selector '#translate[disabled="disabled"]'
  end

  test "not authorized show document" do
    current_user = @pj
    login_as current_user

    document = @empire.documents.first

    visit document_url(document)

    assert_current_path root_path
  end

  test "new document on validated company" do
    total_docs = @empire.documents.count
    login_as @owner

    visit documents_url

    click_on I18n.t('documents.index.add_new_document')

    fill_in "document_title", with: 'Death Star Weakness'
    fill_in "document_original_text", with: 'Guys, I really think we need to remove that one specific spot in our Death Star that makes everything goes boom!'

    click_on I18n.t('documents.form.save')

    assert_current_path documents_path

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

  test "new document on unvalidated company" do
    login_as @pj

    visit new_document_url

    assert_current_path root_path
  end

  test "edit document as authorized person" do
    current_user = @employee
    document = current_user.documents.first
    text = 'Can you guys recommend any shooting bootcamps? I really need to train that. Boss is getting mad at me.'

    login_as current_user

    visit edit_document_url(document)

    fill_in 'document_original_text', with: text

    click_on I18n.t('documents.form.save')

    visit document_url(document)

    assert_selector '#document_original_text', text: text
  end

  test "edit document as unauthorized person" do
    current_user = @pj
    document = @employee.documents.first

    login_as current_user

    visit edit_document_url(document)

    assert_current_path root_path
  end

  test "authorized person deleting a document" do
    current_user = @owner
    total_docs = @empire.documents.count

    login_as current_user
    visit documents_url

    accept_confirm(I18n.t('alert.are_you_sure')) do
      first(".grid-table .grid-row .fa-times").click
    end
    assert_current_path documents_path
    page.driver.browser.navigate.refresh # reloads the page


    total_pages = @empire.documents.page.total_pages
    n_docs = 0

    for i in 1..total_pages do
      n_docs += all(".grid-table .grid-row").count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i+1
      end
    end
    assert_equal total_docs - 1, n_docs
  end
end
