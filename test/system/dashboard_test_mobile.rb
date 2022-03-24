require "mobile_system_test_case"

class MobileDashboardTest < MobileSystemTestCase
  setup do
    @owner = users(:reginald)
    @manager = users(:pogo)
    @employee = users(:trooper)
    @pj = users(:jabba)
    @new_user = users(:new_user)
    @owner_review = users(:neto)
    @owner_validated = users(:walter)
    @manager_validated = users(:mickey)
    @employee_validated = users(:donald)
  end

  test "dashboard menu to managers from completed company" do
    login_as @manager
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text "Documentos registrados"
    assert_text "Documentos por funcionário"
    assert_text "Dados adicionais"
  end

  test "dashboard menu to owner from completed company" do
    login_as @owner
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text "Documentos registrados"
    assert_text "Documentos por funcionário"
    assert_text "Dados adicionais"
  end

  test "dashboard menu to pj" do
    login_as @pj
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 7

    assert_text "Documentos registrados"
    assert_text "Documentos por funcionário", count: 0
    assert_text "Dados adicionais"
  end

  test "dashboard menu to employees" do
    login_as @employee
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 5
  end

  test "dashboard menu to user without company" do
    login_as @new_user
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.register_company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.see_plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.see_packages')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 6
    assert_selector "#content-wrap p", text: I18n.t('pages.dashboard.to_complete', register_link: I18n.t('pages.dashboard.register_link'))
  end

  test "dashboard to owner with company in review" do
    login_as @owner_review
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 6
    assert_selector "#content-wrap p", text: I18n.t('companies.company_dashboard.review')
  end

  test "dashboard to manager from validated company" do
    login_as @manager_validated
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_selector "#content-wrap p", text: I18n.t('companies.company_dashboard.validated', href: I18n.t('companies.company_dashboard.click_here'))
  end

  test "dashboard to owner from validated company" do
    login_as @owner_validated
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_selector "#content-wrap p", text: I18n.t('companies.company_dashboard.validated', href: I18n.t('companies.company_dashboard.click_here'))
  end

  test "dashboard to employee from validated company" do
    login_as @employee_validated
    visit root_url
    sleep(1)
    find('#ham-3-menu').click

    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.dashboard')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('.shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 5
    assert_selector "#content-wrap p", text: I18n.t('companies.company_dashboard.validated', href: I18n.t('companies.company_dashboard.click_here'))
  end
end
