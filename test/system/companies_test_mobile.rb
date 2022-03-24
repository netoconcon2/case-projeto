require "mobile_system_test_case"

class MobileCompaniesTest < MobileSystemTestCase
  setup do
    @owner = users(:reginald)
    @admin = users(:siriguejo)
  end

  ## Admin view
  test "only admin must have access" do
    current_user = @owner

    login_as current_user
    visit admin_companies_url

    assert_current_path root_path
  end

  test "companies from mobile version" do
    current_user = @admin

    login_as current_user
    visit admin_companies_url

    assert_selector '.btn-arrows', count: 1
    assert_selector '#query_title', count: 1
    assert_no_selector '#dropdownSelectBtn', minimum: 1
    assert_no_selector '#query_date_start', minimum: 1
    assert_no_selector '#query_date_end', minimum: 1
    find('.btn-arrows').click()
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "companies list mobile version" do
    current_user = @admin

    login_as current_user
    visit admin_companies_url

    assert_no_text I18n.t('admin.companies.index.created_at').upcase, count: 1
    assert_no_text I18n.t('admin.companies.index.responsible').upcase, count: 1
    assert_no_text I18n.t('admin.companies.index.status').upcase, count: 1
  end

  test "admin flow into companies index" do
    current_user = @admin
    companies = Company.all
    total_pages = companies.page.total_pages

    login_as current_user
    visit admin_companies_url

    n_company = 0
    for i in 1..total_pages do
      n_company += all('.grid-table .grid-row').count
      assert_selector '.grid-table .grid-row', count: companies.page(i).count

      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal companies.size, n_company
  end
end
