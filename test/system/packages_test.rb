require "application_system_test_case"

class PackagesTest < ApplicationSystemTestCase
  setup do
    @packages = Package.all
    @package = packages(:visible)
    @admin = users(:siriguejo)
    @manager = users(:reginald)
    @employee = users(:trooper)
    @no_company = users(:new_user)
    @pj = users(:jabba)
  end

  test "visiting the package index" do
    visit "/packages"

    assert_selector "h1", text: I18n.t('packages.index.choose_a_package')

    login_as @manager

    visit "/packages"

    assert_selector "h1", text: I18n.t('packages.index.choose_a_package')
  end

  test "only visible packages appear in public page" do
    login_as @manager
    visit "/packages"

    assert_selector ".card-package", count: @packages.where(status: "visible").count

    logout(:user)

    login_as @pj
    visit "/packages"

    assert_selector ".card-package", count: @packages.where(status: "visible").count
  end

  test "button to checkout should only appear to validated companies" do
    visit "/packages"

    assert_no_selector ".btn-orange", text: I18n.t('packages.index.buy_package')
  end

  test "admin can see packages by status" do
    login_as @admin
    visit "/admin/packages"

    find(:css, "#package_status_all").set(false)
    assert_no_selector ".card-square", wait: 10
    find(:css, "#status_0[value='invisible']").set(true)
    assert_selector ".card-square", count: Package.where(status: 'invisible').count, wait: 10
    assert_selector ".card-square h3", text: "Additional Package 1"

    find(:css, "#status_0[value='invisible']").set(false)
    find(:css, "#status_1[value='visible']").set(true)
    assert_selector ".card-square", count: Package.where(status: 'visible').count, wait: 10
    assert_selector ".card-square h3", text: "Additional Package 2"
  end

  test "admin can create a new package" do
    login_as @admin
    visit "/admin/packages/new"

    fill_in "package_name", with: "Pacote teste"
    fill_in "package_price", with: 1000
    fill_in "package_words", with: 10

    click_on 'Criar Pacote'

    assert_current_path admin_packages_path
    assert_selector ".card-square h3", text: "Pacote teste"
  end

  test "manager user visiting admin package pages" do
    login_as @manager

    visit "/admin/packages/new"
    assert_current_path root_path

    visit "/admin/packages"
    assert_current_path root_path
  end

  test "pj user visiting admin package pages" do
    login_as @pj

    visit "/admin/packages/new"
    assert_current_path root_path

    visit "/admin/packages"
    assert_current_path root_path
  end

  test "user without company visiting admin package pages" do
    login_as @no_company

    visit "/admin/packages/new"
    assert_current_path root_path

    visit "/admin/packages"
    assert_current_path root_path
  end

  test "buying a package as pj" do
    login_as @pj

    visit packages_url
    find("#checkout-#{@package.id}").click
    assert_current_path package_checkout_path(package_id: @package)
  end

  test "buying a package as manager" do
    login_as @manager

    visit packages_url
    find("#checkout-#{@package.id}").click
    assert_current_path package_checkout_path(package_id: @package)
  end
end
