require 'test_helper'

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @new_user = users(:new_user)
    @manager = users(:reginald)
  end

  test "authentication in company controller" do
    get company_url
    assert_redirected_to new_user_session_url, "not redirected after access company_url unauthenticated"

    get new_company_url
    assert_redirected_to new_user_session_url, "not redirected after access new_company_url unauthenticated"

    post companies_url, params: { company: { name: "test company" } }
    assert_redirected_to new_user_session_url, "not redirected after posting unauthenticated to companies_url"
  end

  test "access to company_path" do
    sign_in @new_user
    get company_url
    assert_redirected_to root_url, "user that doesn't have a company yet should be redirected to root"
    assert_equal "A página não pôde ser acessada.", flash[:alert]

    sign_out :user

    sign_in @manager
    get company_url
    assert_response :success, "user who has a company should be able to access company_path"
  end

  test "access to new_company" do
    sign_in @new_user
    get new_company_url
    assert_response :success, "user that doesn't have a company should be able to access"

    sign_out :user

    sign_in @manager
    get new_company_url
    assert_redirected_to root_url, "user that have a company should be redirected to root"
    assert_equal "A página não pôde ser acessada.", flash[:alert]
  end

  test "posting to companies_path with valid attributes" do
    sign_in @new_user

    assert_difference "Company.count", 1, "new company didn't persist in the database" do
      post companies_url, params: { company: { name: "Test Company", cnpj: "11111111111111", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", country: 'Brazil', city: "Townsville", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro" } }
    end

    assert_redirected_to root_url, "after create a new company, user should be redirected to root path"
  end

  test "posting to companies_path with invalid attributes" do
    sign_in @new_user
    assert_no_difference "Company.count", "new company shoudn't persist in the database" do
      post companies_url, params: { company: { name: "" } }
    end
    assert_template :new, "should render :new template if not save"
    assert_not_empty controller.instance_variable_get(:@company).errors.messages, "after posting an invalid company, the instance should have errors messages"
  end
end
