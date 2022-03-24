require "mobile_system_test_case"

class MobileUsersTest < MobileSystemTestCase
  include ActionMailer::TestHelper

  setup do
    @owner = users(:reginald)
    @pj = users(:jabba)
  end

  test "inviting a user" do
    login_as @owner

    visit company_url

    click_on I18n.t('companies.show.invite_user')

    fill_in 'user_first_name', with: 'Friend'
    fill_in 'user_lat_name', with: 'Example'
    fill_in 'user_email', with: 'friend@example.com'
    find('#user_which_role').find(:xpath, 'option[2]').select_option

    assert_emails 1 do
      click_on I18n.t('devise.invitations.new.submit_button')
      assert_no_selector('#invitation-modal', wait: 10)
    end

    assert_equal User.last.email, 'friend@example.com'
    assert_equal User.last.company, @owner.company
  end

  ## User flow
  test "visiting home not signed in" do
    visit root_url

    assert_selector "nav.nav"
    assert_selector "#content-wrap.home"
  end

  test "user signing up as manager" do
    visit root_url
    click_on I18n.t('shared.navbar.get_started').upcase

    fill_in 'user_first_name', with: 'Papyrus'
    fill_in 'user_last_name', with: 'Cool Bones'
    fill_in 'user_email', with: "papyrus@coolskeleton.com"
    fill_in 'user_password', with: 'puzzles'
    fill_in 'user_password_confirmation', with: 'puzzles'

    click_on I18n.t('devise.registrations.new.next')

    find('#user_which_role').find(:xpath, 'option[3]').select_option

    assert_difference "User.count", 1, "user didn't succeed in create an account" do
      click_on I18n.t('devise.registrations.new.submit')
    end
    assert_current_path new_company_path
  end

  test "user signing up as pj" do
    visit root_url
    click_on I18n.t('shared.navbar.get_started').upcase

    fill_in 'user_first_name', with: 'Sans'
    fill_in 'user_last_name', with: 'Cool Bones'
    fill_in 'user_email', with: "sans@lazybones.pun"
    fill_in 'user_password', with: 'getdunkedon'
    fill_in 'user_password_confirmation', with: 'getdunkedon'

    click_on I18n.t('devise.registrations.new.next')

    find('#user_which_role').find(:xpath, 'option[2]').select_option

    assert_difference "User.count", 1, "user didn't succeed in create an account" do
      click_on I18n.t('devise.registrations.new.submit')
    end
    assert_current_path root_path
  end

  test "user signing in" do
    visit root_url
    click_on I18n.t('shared.navbar.sign_in')

    fill_in 'user_email', with: @owner.email
    fill_in 'user_password', with: 'umbrella'

    click_on I18n.t('devise.sessions.new.sign_in')
    assert_current_path root_path
  end

  # Admin users index
  test "only admin must have access" do
    current_user = @owner

    login_as current_user
    visit admin_users_url

    assert_current_path root_path
  end

  test "users index mobile version" do
    current_user = @admin

    login_as current_user
    visit admin_companies_url

    assert_selector '.btn-arrows', count: 1
    assert_selector '#query_name', count: 1
    assert_no_selector '#dropdownSelectBtn', minimum: 1
    assert_no_selector '#query_date_start', minimum: 1
    assert_no_selector '#query_date_end', minimum: 1
    find('.btn-arrows').click()
    assert_selector '#dropdownSelectBtn', count: 1
    assert_selector '#query_date_start', count: 1
    assert_selector '#query_date_end', count: 1
  end

  test "users list mobile version" do
    current_user = @admin

    login_as current_user
    visit admin_companies_url

    assert_no_text I18n.t('admin.users.index.created_at').upcase, count: 1
    assert_no_text I18n.t('admin.users.index.company').upcase, count: 1
    assert_no_text I18n.t('admin.users.index.role').upcase, count: 1
  end

  test "admin flow into users index" do
    current_user = @admin
    users = User.all
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
end
