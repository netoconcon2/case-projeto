require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  setup do
    @owner = users(:reginald)
    @pj = users(:jabba)
    @admin = users(:siriguejo)
    @company = companies(:northern)
    @company_validated = companies(:disney)
  end

  test "inviting a user as manager" do
    login_as @owner

    visit company_url

    click_on I18n.t('companies.show.invite_user')

    fill_in 'user_first_name', with: 'Bob'
    fill_in 'user_last_name', with: 'Constructor'
    fill_in 'user_email', with: 'friend@example.com'
    find('#user_which_role').find(:xpath, 'option[1]').select_option

    assert_emails 1 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_no_selector('#invitation-modal', wait: 10)
    end

    assert_selector ".pending_invite", text: "friend@example.com", wait: 10

    assert_equal "friend@example.com", User.last.email
    assert_equal @owner.company, User.last.company
  end

  test "inviting a manager user as admin" do
    login_as @admin

    visit admin_company_url(id: @company_validated.id)

    click_on I18n.t('admin.companies.show.invite_user')

    fill_in 'user_first_name', with: 'Bob'
    fill_in 'user_last_name', with: 'Constructor'
    fill_in 'user_email', with: 'friend@example.com'
    assert_emails 1 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_no_selector('#invitation-modal', wait: 10)
    end

    assert_selector ".grid-table .grid-row span", text: "friend@example.com", wait: 10

    assert_equal "friend@example.com", User.last.email
    assert_equal @company_validated, User.last.company
  end

  test "inviting a employee user to a company as admin" do
    login_as @admin

    visit admin_company_url(id: @company_validated.id)

    click_on I18n.t('admin.companies.show.invite_user')

    fill_in 'user_first_name', with: 'Bob'
    fill_in 'user_last_name', with: 'Constructor'
    fill_in 'user_email', with: 'friend@example.com'

    assert_emails 1 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_no_selector('#invitation-modal', wait: 10)
    end

    assert_selector ".grid-table .grid-row span", text: "friend@example.com", wait: 10

    assert_equal "friend@example.com", User.last.email
    assert_equal @company_validated, User.last.company
  end

  ## User flow
  test "visiting home not signed in" do
    visit root_url

    assert_selector "nav.nav"
    assert_selector "#content-wrap.home"
  end

  test "user signing up as manager" do
    visit root_url
    find('#navbar-links .link-orange').click

    fill_in 'user_first_name', with: "Papyrus"
    fill_in 'user_last_name', with: "Cool Bones"
    fill_in 'user_email', with: "papyrus@coolskeleton.com"
    fill_in 'user_password', with: 'puzzles'
    fill_in 'user_password_confirmation', with: 'puzzles'

    click_on I18n.t('javascript.multistep.next')

    find('#user_which_role').find(:option, I18n.t('devise.registrations.new.company')).select_option

    assert_difference "User.count", 1, "user didn't succeed in create an account" do
      click_on I18n.t('javascript.multistep.submit')
    end
    assert_current_path new_company_path
  end

  test "user signing up as pj" do
    visit root_url
    find('#navbar-links .link-orange').click

    fill_in 'user_first_name', with: "Sans"
    fill_in 'user_last_name', with: "Cool Bones"
    fill_in 'user_email', with: "sans@lazybones.pun"
    fill_in 'user_password', with: 'getdunkedon'
    fill_in 'user_password_confirmation', with: 'getdunkedon'

    click_on I18n.t('javascript.multistep.next')

    find('#user_which_role').find(:option, I18n.t('activerecord.attributes.user.role_list.pj')).select_option

    assert_difference "User.count", 1, "user didn't succeed in create an account" do
      click_on I18n.t('javascript.multistep.submit')
    end
    assert_current_path root_path
  end

  test "user signing in" do
    visit root_url
    find('#navbar-links .link-orange').click
    assert_current_path new_user_registration_path
    click_on I18n.t('devise.registrations.new.sign_in')
    assert_current_path new_user_session_path

    fill_in 'user_email', with: @owner.email, wait: 10
    fill_in 'user_password', with: 'umbrella'

    click_on I18n.t('devise.sessions.new.sign_in')
    assert_current_path root_path
  end

  # Admin user index
  test "only admin must have access" do
    current_user = @owner

    login_as current_user
    visit admin_users_url

    assert_current_path root_path
  end

  test "users index desktop version" do
    current_user = @admin

    login_as current_user
    visit admin_users_url

    assert_no_selector '.btn-arrows', minimum: 1
    assert_selector '#query_name', count: 1
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "users list desktop version" do
    current_user = @admin

    login_as current_user
    visit admin_users_url

    assert_text I18n.t('admin.users.index.created_at').upcase, count: 1
    assert_text I18n.t('admin.users.index.company').upcase, count: 1
    assert_text I18n.t('admin.users.index.role').upcase, count: 1
  end

  test "admin flow into users index" do
    current_user = @admin
    users = User.where.not(admin: true)
    total_pages = users.page.total_pages

    login_as current_user
    visit admin_users_url

    n_user = 0
    for i in 1..total_pages do
      n_user += all('.grid-table .grid-row').count
      assert_selector '.grid-table .grid-row', count: users.page(i).count

      unless i == total_pages
        find("a#next").click
        assert_selector '.page.current', text: i + 1
      end
    end
    assert_equal users.size, n_user
  end

  test "searching users by email" do
    login_as @admin
    visit admin_users_url

    fill_in 'query_name', with: 'mickey'
    click_on I18n.t('admin.users.index.search')

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'mickey@mouse.squeak'
  end

  test "searching users by company name" do
    login_as @admin
    visit admin_users_url

    fill_in 'query_name', with: 'disney'
    click_on I18n.t('admin.users.index.search')

    assert_selector '.grid-table .grid-row', count: companies(:disney).users.size
    assert_selector '.grid-table .grid-row span', text: companies(:disney).name
  end

  test "searching users by role" do
    users = User.where(role: 2)
    login_as @admin
    visit admin_users_url

    find('#dropdownSelectBtn').click
    find(:css, '#role_2[value="2"]').set(true)
    click_on I18n.t('admin.users.index.search')

    assert_selector '.grid-table .grid-row', count: users.size
    users.each do |user|
      assert_selector '.grid-table .grid-row span', text: user.email
    end
  end

  test "searching users by date range" do
    users = User.where(created_at: 11.days.ago...4.days.ago)
    login_as @admin
    visit admin_users_url

    fill_in 'query_date_start', with: 11.days.ago.strftime('%d/%m/%Y')
    fill_in 'query_date_end', with: 4.days.ago.strftime('%d/%m/%Y') + "\n"
    click_on I18n.t('admin.users.index.search')

    assert_selector '.grid-table .grid-row', count: users.size
    users.each do |user|
      assert_selector '.grid-table .grid-row span', text: user.email
    end
  end

  test "searching users using all inputs" do
    login_as @admin
    visit admin_users_url

    fill_in 'query_name', with: 'jar'
    find('#dropdownSelectBtn').click
    find(:css, '#role_2[value="2"]').set(true)
    fill_in 'query_date_start', with: 21.days.ago.strftime('%d/%m/%Y')
    fill_in 'query_date_end', with: 15.days.ago.strftime('%d/%m/%Y') + "\n"
    click_on I18n.t('admin.users.index.search')

    assert_selector '.grid-table .grid-row', count: 1
    assert_selector '.grid-table .grid-row span', text: 'Jar Jar'
  end
end
