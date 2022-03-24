require "application_system_test_case"

class DashboardTest < ApplicationSystemTestCase
  setup do
  end

  test "dashboard menu to managers from completed company" do
    login_as users(:pogo)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.docs_per_user')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard menu to owner from completed company" do
    login_as users(:reginald)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.docs_per_user')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard menu to pj" do
    login_as users(:jabba)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 7

    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.company_details')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard menu to employees" do
    login_as users(:trooper)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 5
  end

  test "dashboard menu to user without company" do
    login_as users(:new_user)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.register_company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.see_plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.see_packages')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 6
    assert_selector "#content-wrap p", text: I18n.t('pages.dashboard.to_complete', register_link: I18n.t('pages.dashboard.register_link'))
  end

  test "dashboard to owner with company in review" do
    login_as users(:neto)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 6
    assert_selector "#content-wrap p", text: I18n.t('companies.company_dashboard.review')
  end

  test "dashboard to manager from validated company" do
    login_as users(:mickey)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.docs_per_user')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard to owner from validated company" do
    login_as users(:walter)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.company')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.additional_package')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 8
    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.docs_per_user')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard to employee from validated company" do
    login_as users(:donald)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 5
    assert_text I18n.t('companies.company_dashboard.docs')
    assert_text I18n.t('companies.company_dashboard.docs_per_user')
    assert_text I18n.t('companies.company_dashboard.additional_data')
  end

  test "dashboard to admin" do
    login_as users(:siriguejo)
    visit root_url

    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.dashboard'), wait: 10
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.documents')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.glossaries')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.manage_plans')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.manage_packages')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.manage_companies')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.applies')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.manage_users')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.profile')
    assert_selector "a.dash-nav-item p", text: I18n.t('shared.dashboard_navbar.sign_out')
    assert_selector "a.dash-nav-item p", count: 10
  end
end
