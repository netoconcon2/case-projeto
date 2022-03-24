require 'test_helper'
require 'pry'

class PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:siriguejo)
    @owner = users(:reginald)
    @employee = users(:donald)
    @invisible_package = packages(:invisible)
    @visible_package = packages(:visible)
  end

  test "Only Admin should have access" do
    sign_in @owner

    get admin_packages_url
    assert_response :redirect, "User not admin access admin_package_path"

    get new_admin_package_url
    assert_response :redirect, "User not admin access new_admin_package_path"

    sign_out :user
    sign_in @admin

    get admin_packages_url
    assert_response :success, "Admin didn't get access to admin_package_path"

    get new_admin_package_url
    assert_response :success, "Admin didn't get access to new_admin_package_path"

    get edit_admin_package_url(@invisible_package)
    assert_response :success, "Admin didn't get access to edit_admin_package_path"
  end

  test "Only Admin should create packages" do
    sign_in @owner

    assert_no_difference "Package.count", "package was persisted in db by a not admin user" do
      post admin_packages_url, params: { package: { price: 100, words: 100, name: "Test package" } }
    end

    sign_out :user
    sign_in @admin

    assert_difference "Package.count", 1, "admin didn't succeed in create a package" do
      post admin_packages_url, params: { package: { price: 100, words: 100, name: "Test package" } }
    end
  end

  test "Only Admin should be able to change status from packages" do
    sign_in @owner

    post admin_package_visualize_url(package_id: @invisible_package.id)
    assert_equal "invisible", Package.find(@invisible_package.id).status, "package was changed to visible by a not admin user"

    post admin_package_invisiblize_url(package_id: @visible_package.id)
    assert_equal "visible", Package.find(@visible_package.id).status, "package was changed to invisible by a not admin user"

    sign_out :user
    sign_in @admin

    post admin_package_visualize_url(package_id: @invisible_package.id)
    assert_equal "visible", Package.find(@invisible_package.id).status, "package wasn't changed to visible by an admin"

    post admin_package_invisiblize_url(package_id: @visible_package.id)
    assert_equal "invisible", Package.find(@visible_package.id).status, "package wasn't changed to invisible by an admin"
  end

  test "Only Admin should be able to update packages" do
    sign_in @owner

    patch admin_package_url(id: @invisible_package), params: { package: { name: 'Additional Package 1', price: 100, words: 1000 } }
    assert_equal 100, Package.find(@invisible_package.id).words, "package was updated by a user not admin"

    sign_out :user
    sign_in @admin

    patch admin_package_url(id: @invisible_package), params: { package: { name: 'Additional Package 1', price: 1000, words: 1000 } }
    assert_equal 1000, Package.find(@invisible_package.id).words, "package wasn't updated by an admin"
  end

  test "Only admin should be able to destroy" do
    sign_in @owner

    delete admin_package_url(id: @invisible_package)
    assert_response :redirect, "User not admin was able to destroy package"

    sign_out :user
    sign_in @admin

    assert_difference "Package.count", -1, "Admin wasn't able to destroy invisible package" do
      delete admin_package_url(@invisible_package)
    end

    assert_difference "Package.count", -1, "Admin wasn't able to destroy visible package" do
      delete admin_package_url(@visible_package)
    end
  end
end
