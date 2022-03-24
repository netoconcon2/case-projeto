require "application_system_test_case"

class GlossariesTest < ApplicationSystemTestCase
  setup do
    @admin = users(:siriguejo)
    @owner = users(:reginald)
    @employee = users(:trooper)
    @pj = users(:jarjar)
    @no_company = users(:new_user)
    @in_review = users(:neto)
  end

  test 'glossary index for admin' do
    current_user = @admin
    glossaries = Glossary.all
    total_pages = glossaries.page.total_pages

    login_as current_user

    visit glossaries_url

    n_gloss = 0
    for i in 1..total_pages do
      assert_selector '.grid-table .grid-row', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-trash', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: glossaries.page(i).count
      n_gloss += all('.grid-table .grid-row').count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal glossaries.size, n_gloss
  end

  test 'glossary index for user with glossaries' do
    current_user = @owner
    glossaries = Glossary.where(company: @company)
    total_pages = glossaries.page.total_pages

    login_as current_user

    visit glossaries_url

    n_gloss = 0
    for i in 1..total_pages do
      assert_selector '.grid-table .grid-row', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-trash', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: glossaries.page(i).count
      n_gloss += all('.grid-table .grid-row').count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal glossaries.size, n_gloss
  end

  test 'glossary index for user without glossaries' do
    current_user = @pj
    glossaries = Glossary.where(company: @pj.company)
    total_pages = glossaries.page.total_pages

    login_as current_user

    visit glossaries_url

    n_gloss = 0
    for i in 1..total_pages do
      assert_selector '.grid-table .grid-row', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-trash', count: glossaries.page(i).count
      assert_selector '.grid-table .grid-row .fa-pen', count: glossaries.page(i).count
      n_gloss += all('.grid-table .grid-row').count
      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal 0, n_gloss
  end

  test 'glossary index for company in review' do
    current_user = @in_review
    login_as current_user

    visit glossaries_url

    assert_current_path root_path
  end

  test 'glossary index for user without company' do
    current_user = @no_company
    login_as current_user

    visit glossaries_url

    assert_current_path root_path
  end

  test 'glossary show for admin' do
    glossary = glossaries(:glossary_0)
    login_as @admin
    visit glossaries_url

    find("#glossary_#{glossary.id} i.fa-eye").click
    assert_selector 'h1', text: glossary.name

    glossary.terms.each do |term|
      assert_selector '.grid-row span', text: term.source
      assert_selector '.grid-row span', text: term.target
    end
  end

  test 'glossary show for authorized user' do
    glossary = glossaries(:glossary_0)
    login_as @owner
    visit glossaries_url

    find("#glossary_#{glossary.id} i.fa-eye").click
    assert_selector 'h1', text: glossary.name

    glossary.terms.each do |term|
      assert_selector '.grid-row span', text: term.source
      assert_selector '.grid-row span', text: term.target
    end
  end

  test 'glossary show for unauthorized user' do
    glossary = glossaries(:glossary_0)
    login_as @pj
    visit glossary_url(id: glossary.id)

    assert_current_path root_path
  end

  test 'new glossary as admin' do
    login_as @admin

    visit glossaries_url

    click_on I18n.t('glossaries.index.add_new_glossary')

    fill_in 'glossary_name', with: 'Test', wait: 10
    find('#glossary_language_1').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.first}")).select_option
    find('#glossary_language_2').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.last}")).select_option

    assert_difference "Glossary.count", 1, 'glossary instance was not created' do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    assert_current_path glossaries_path
    assert_selector "#glossary_#{Glossary.last.id} span", text: 'Test'
  end

  test 'new glossary as owner' do
    login_as @owner

    visit glossaries_url

    click_on I18n.t('glossaries.index.add_new_glossary')

    fill_in 'glossary_name', with: 'Test', wait: 10
    find('#glossary_language_1').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.first}")).select_option
    find('#glossary_language_2').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.last}")).select_option

    assert_difference "Glossary.count", 1, 'glossary instance was not created' do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    assert_current_path glossaries_path
    assert_selector "#glossary_#{Glossary.last.id} span", text: 'Test'
  end

  test 'new glossary as pj' do
    login_as @pj

    visit glossaries_url

    click_on I18n.t('glossaries.index.add_new_glossary')

    fill_in 'glossary_name', with: 'Test', wait: 10
    find('#glossary_language_1').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.first}")).select_option
    find('#glossary_language_2').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.last}")).select_option

    assert_difference "Glossary.count", 1, 'glossary instance was not created' do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    assert_current_path glossaries_path
    assert_selector "#glossary_#{Glossary.last.id} span", text: 'Test'
  end

  test 'new glossary as company in review' do
    login_as @in_review

    visit new_glossary_url

    assert_current_path root_path
  end

  test 'new glossary as user without company' do
    login_as @no_company

    visit new_glossary_url

    assert_current_path root_path
  end

  test 'edit glossary as admin' do
    glossary = glossaries(:glossary_0)
    login_as @admin

    visit glossaries_path

    assert_selector "#glossary_#{glossary.id}", count: 1
    find("#glossary_#{glossary.id} .fa-pen").click
    fill_in 'glossary_name', with: 'New name'
    click_on I18n.t('glossaries.form.submit')

    assert_current_path glossaries_path
    assert_selector "#glossary_#{glossary.id} span", text: 'New name'
  end

  test 'edit glossary as authorized user' do
    glossary = glossaries(:glossary_0)
    login_as @owner

    visit glossaries_path

    assert_selector "#glossary_#{glossary.id}", count: 1
    find("#glossary_#{glossary.id} .fa-pen").click
    fill_in 'glossary_name', with: 'New name now'
    click_on I18n.t('glossaries.form.submit')

    assert_current_path glossaries_path
    assert_selector "#glossary_#{glossary.id} span", text: 'New name now'
  end

  test 'edit glossary as unauthorized user' do
    glossary = glossaries(:glossary_0)
    login_as @pj

    visit edit_glossary_path(id: glossary.id)

    assert_current_path root_path
  end

  test 'destroy glossary as admin' do
    glossary = glossaries(:glossary_0)
    login_as @admin

    visit glossaries_url

    assert_selector "#glossary_#{glossary.id}", count: 1
    assert_difference "Glossary.count", -1, 'glossary instance was not deleted' do
      accept_confirm(I18n.t('alert.are_you_sure'), wait: 10) do
        find("#glossary_#{glossary.id} .fa-trash").click
      end
      sleep(0.5)
    end
    assert_no_selector "#glossary_#{glossary.id}", minimum: 1
  end

  test 'destroy glossary as authorized user' do
    glossary = glossaries(:glossary_0)
    login_as @owner

    visit glossaries_url

    assert_selector "#glossary_#{glossary.id}", count: 1
    assert_difference "Glossary.count", -1, 'glossary instance was not deleted' do
      accept_confirm(I18n.t('alert.are_you_sure'), wait: 10) do
        find("#glossary_#{glossary.id} .fa-trash").click
      end
      sleep(0.5)
    end
    assert_no_selector "#glossary_#{glossary.id}", minimum: 1
  end

  test "searching glossaries by name" do
    login_as @owner
    visit glossaries_url

    fill_in 'query_name', with: 'test'
    click_on I18n.t('glossaries.index.search')

    assert_selector '.grid-table .grid-row', count: 1, wait: 10
    assert_selector '.grid-table .grid-row span', text: 'Glossary test'
  end

  test 'new glossary with valid file import' do
    login_as @owner

    visit glossaries_url

    click_on I18n.t('glossaries.index.add_new_glossary')

    fill_in 'glossary_name', with: 'Test', wait: 10
    find('#glossary_language_1').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.first}")).select_option
    find('#glossary_language_2').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.last}")).select_option
    find('.btn-switch').click
    attach_file('glossary_xlsx', Rails.root.join("test/fixtures/files/glossary_valid.xlsx"), visible: false)
    check('glossary_has_header')

    assert_difference ->{ Glossary.count } => 1, ->{ Term.count } => 72 do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    assert_current_path glossaries_path
    assert_selector "#glossary_#{Glossary.last.id} span", text: 'Test'
  end

  test 'new glossary with invalid file import' do
    login_as @owner

    visit glossaries_url

    click_on I18n.t('glossaries.index.add_new_glossary')

    fill_in 'glossary_name', with: 'Test', wait: 10
    find('#glossary_language_1').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.first}")).select_option
    find('#glossary_language_2').find(:option, I18n.t("languages.#{Glossary::LANGUAGES.last}")).select_option
    find('.btn-switch').click
    attach_file('glossary_xlsx', Rails.root.join("test/fixtures/files/glossary_invalid.xlsx"), visible: false)
    check('glossary_has_header')

    assert_difference ->{ Glossary.count } => 1, ->{ Term.count } => 0 do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    assert_current_path glossaries_path
    assert_selector "#glossary_#{Glossary.last.id} span", text: 'Test'
  end

  test 'import terms from valid file in show' do
    glossary = glossaries(:glossary_0)
    login_as @owner
    visit glossary_url(id: glossary.id)

    click_on I18n.t('glossaries.show.import_terms')

    attach_file('glossary_xlsx', Rails.root.join("test/fixtures/files/glossary_valid.xlsx"), visible: false, wait: 10)
    check('glossary_has_header')

    assert_difference 'Term.count', 72 do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    glossary.terms.each do |term|
      assert_selector '.grid-row span', text: term.source
      assert_selector '.grid-row span', text: term.target
    end
  end

  test 'import terms from invalid file in show' do
    glossary = glossaries(:glossary_0)
    login_as @owner
    visit glossary_url(id: glossary.id)

    click_on I18n.t('glossaries.show.import_terms')

    attach_file('glossary_xlsx', Rails.root.join("test/fixtures/files/glossary_invalid.xlsx"), visible: false, wait: 10)
    check('glossary_has_header')

    assert_difference 'Term.count', 0 do
      click_on I18n.t('glossaries.form.submit')
      sleep(0.5)
    end

    glossary.terms.each do |term|
      assert_selector '.grid-row span', text: term.source
      assert_selector '.grid-row span', text: term.target
    end
  end
end
