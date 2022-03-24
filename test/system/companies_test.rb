require "application_system_test_case"

class CompaniesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    @owner = users(:vader)
    @admin = users(:siriguejo)
    @employee = users(:trooper)
    @pj = users(:jabba)
    @manager = users(:mickey)
    @company_review = companies(:northern)
    @company_validated = companies(:disney)
  end

  test "invited users in company show" do
    login_as @owner

    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.company'), exact_text: true).click

    assert_selector "#pending_invitations td", count: @owner.company.users.where.not(invitation_token: nil).size
  end

  test "owner visiting denied company show" do
    login_as users(:wesley)
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.company'), exact_text: true).click

    assert_selector "p", text: I18n.t('companies.show.denied')
  end

  test "owner visiting review company show" do
    login_as users(:howell)
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.company'), exact_text: true).click

    assert_selector "p", text: I18n.t('companies.show.waiting_review')
  end

  test "company users in completed company show" do
    login_as @owner
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.company'), exact_text: true).click

    assert_selector "#grid-list div[role='row']", count: @owner.company.users.where(invitation_token: nil).where.not(id: @owner.id).count + 1, wait: 10
  end

  test "employee visiting show company" do
    login_as @employee
    visit company_url

    assert_current_path root_path
  end

  test "pj visiting show company" do
    login_as @pj
    visit company_url

    assert_current_path root_path
  end

  ## Admin view
  test "only admin must have access" do
    current_user = @owner

    login_as current_user
    visit admin_companies_url

    assert_current_path root_path
  end

  test "companies from desktop version" do
    current_user = @admin

    login_as current_user
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.manage_companies'), exact_text: true).click

    assert_no_selector '.btn-arrows', minimum: 1
    assert_selector '#query_name', count: 1
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "companies list desktop version" do
    current_user = @admin

    login_as current_user
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.manage_companies'), exact_text: true).click
    assert_text I18n.t('admin.companies.index.created_at').upcase, count: 1
    assert_text I18n.t('admin.companies.index.responsible').upcase, count: 1
    assert_text I18n.t('admin.companies.index.status').upcase, count: 1
  end

  test "admin flow into companies index" do
    current_user = @admin
    companies = Company.where.not(status: 0)
    total_pages = companies.page.total_pages

    login_as current_user
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.manage_companies'), exact_text: true).click

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

  test "admin apply index" do
    login_as @owner
    visit admin_applies_url

    assert_current_path root_path

    sign_out :user

    login_as @admin
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.applies'), exact_text: true).click

    assert_current_path admin_applies_path
    assert_selector '.grid-table .grid-row', count: Company.where(status: [0,3]).count
    assert_selector '.grid-row span', text: @company_review.name
  end

  test "admin validating company" do
    login_as @admin
    visit root_url
    find('#hamburger-3').click

    click_on I18n.t('shared.dashboard_navbar.applies')
    assert_current_path admin_applies_path

    first('.grid-table .grid-row .fa-eye').click
    assert_current_path admin_company_path(id: @company_review.id)

    accept_confirm(I18n.t('admin.companies.show.are_you_sure')) do
      click_on I18n.t('admin.companies.show.validate')
    end

    assert_current_path admin_company_path(id: @company_review.id)
    assert_selector '.show-info p', text: I18n.t('activerecord.attributes.company.status_list.validated')
    assert_selector '.show-message p', text: I18n.t('admin.companies.show.no_plan')
  end

  test "admin denying company" do
    login_as @admin
    visit root_url
    find('#hamburger-3').click

    click_on I18n.t('shared.dashboard_navbar.applies')
    assert_current_path admin_applies_path

    first('.grid-table .grid-row .fa-eye').click
    assert_current_path admin_company_path(id: @company_review.id)

    accept_confirm(I18n.t('admin.companies.show.are_you_sure')) do
      click_on I18n.t('admin.companies.show.deny')
    end

    assert_current_path admin_company_path(id: @company_review.id)
    assert_selector '.show-info p', text: I18n.t('activerecord.attributes.company.status_list.denied')
    assert_selector '.show-message p', text: I18n.t('admin.companies.show.denied')
  end

  test "admin inviting user from company show" do
    login_as @admin
    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.manage_companies'), exact_text: true).click
    find('.grid-table div[role="row"]', text: @company_validated.name).find('.fa-eye').click
    assert_current_path admin_company_path(id: @company_validated.id)

    click_on I18n.t('admin.companies.show.invite_user')

    fill_in 'user_first_name', with: 'Mike'
    fill_in 'user_last_name', with: 'Wazowski'
    fill_in 'user_email', with: 'mikewazowski@disney.com'
    find('#user_which_role').find(:option, I18n.t('activerecord.attributes.user.role_list.manager')).select_option

    assert_emails 1 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_no_selector('#invitation-modal', wait: 10)
    end

    assert_selector ".grid-table .grid-row span", text: "mikewazowski@disney.com", wait: 10

    assert_equal "mikewazowski@disney.com", User.last.email
    assert_equal @company_validated, User.last.company
  end

  test "admin inviting invalid user from company show" do
    login_as @admin
    visit admin_company_url(id: @company_validated.id)

    click_on I18n.t('admin.companies.show.invite_user')

    fill_in 'user_first_name', with: 'Mike'
    fill_in 'user_last_name', with: 'Wazowski'

    assert_emails 0 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_selector('#invitation-modal', wait: 10)
    end

    assert_selector ".invalid-feedback", text: "#{I18n.t('activerecord.attributes.user.email')} #{I18n.t('errors.messages.blank')}", wait: 10

    assert_not_equal "mikewazowski@disney.com", User.last.email
  end

  test "invite button in admin company show from pj owner" do
    login_as @admin
    visit admin_company_url(id: @pj.company.id)

    assert_no_selector 'a', text: I18n.t('admin.companies.show.invite_user')
  end

  test "new user creating a company" do
    visit root_url

    find('#navbar-links .link-orange').click

    fill_in 'user_first_name', with: "Papyrus"
    fill_in 'user_last_name', with: "Cool Bones"
    fill_in 'user_email', with: "papyrus@coolskeleton.com"
    fill_in 'user_password', with: 'puzzles'
    fill_in 'user_password_confirmation', with: 'puzzles'

    click_on I18n.t('javascript.multistep.next')

    find('#user_which_role').find(:option, I18n.t('activerecord.attributes.user.company')).select_option

    click_on I18n.t('javascript.multistep.submit')

    assert_current_path new_company_path

    fill_in 'company_name', with: "Puzzles Company"
    fill_in 'company_phone', with: "11888888888"
    fill_in 'company_cnpj', with: "12312312312312"
    fill_in 'company_zip_code', with: "01111111"
    fill_in 'company_country', with: "Country"
    fill_in 'company_state', with: "State"
    fill_in 'company_city', with: "City"
    fill_in 'company_neighborhood', with: "Snowdin"
    fill_in 'company_street', with: "Bones street"
    fill_in 'company_street_number', with: "888"

    click_on I18n.t('companies.new.submit')

    assert_current_path root_path

    assert_equal "Puzzles Company", Company.last.name
  end

  test "changing the owner by a user of another company" do
    login_as @admin
    visit admin_company_url(id: @company_review.id)

    click_on I18n.t('admin.companies.show.edit')

    find('#company_user_id').find(:option, "Minnie Mouse").select_option

    click_on I18n.t('admin.companies.edit.submit')

    assert_selector "div.invalid-feedback", text: "#{I18n.t('activerecord.attributes.company.owner')} #{I18n.t('activerecord.errors.models.company.attributes.owner.must_belong_to_the_same_company')}"
    assert_equal users(:neto), @company_review.owner
  end

  test "changing the owner by a not manager user" do
    login_as @admin
    visit admin_company_url(id: @company_validated.id)

    click_on I18n.t('admin.companies.show.edit')

    find('#company_user_id').find(:option, "Duck Donald").select_option

    click_on I18n.t('admin.companies.edit.submit')

    assert_selector "div.invalid-feedback", text: "#{I18n.t('activerecord.attributes.company.owner')} #{I18n.t('activerecord.errors.models.company.attributes.owner.not_right_role')}"
    assert_equal users(:walter), @company_validated.owner
  end

  test "searching companies by name" do
    login_as @admin
    visit admin_companies_url

    fill_in 'query_name', with: 'Walt Dis'
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'The Walt Disney Company'
  end

  test "searching companies by owner" do
    login_as @admin
    visit admin_companies_url

    fill_in 'query_name', with: 'reginald'
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'Sparrow Academy'
  end

  test "searching companies by employee" do
    login_as @admin
    visit admin_companies_url

    fill_in 'query_name', with: 'strm'
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'Death Star'
  end

  test "searching companies by status" do
    companies = Company.where(status: 2)
    login_as @admin
    visit admin_companies_url

    find('#dropdownSelectBtn').click
    find(:css, '#status_2[value="2"]').set(true)
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: companies.size
    companies.each do |company|
      assert_selector '.grid-table .grid-row span', text: company.name
    end
  end

  test "searching companies by date range" do
    companies = Company.where(created_at: 11.days.ago...4.days.ago)
    login_as @admin
    visit admin_companies_url

    fill_in 'query_date_start', with: 11.days.ago.strftime('%d/%m/%Y')
    fill_in 'query_date_end', with: 4.days.ago.strftime('%d/%m/%Y') + "\n"
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: companies.size
    companies.each do |company|
      assert_selector '.grid-table .grid-row span', text: company.name
    end
  end

  test "searching companies using all inputs" do
    login_as @admin
    visit admin_companies_url

    fill_in 'query_name', with: 'ja'
    find('#dropdownSelectBtn').click
    find(:css, '#status_1[value="1"]').set(true)
    fill_in 'query_date_start', with: 21.days.ago.strftime('%d/%m/%Y')
    fill_in 'query_date_end', with: 15.days.ago.strftime('%d/%m/%Y') + "\n"
    click_on I18n.t('admin.companies.index.search').upcase

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'Jar Jar'
  end
end
