require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save without a role" do
    user = User.new(first_name: "Teste", last_name: "Silva", email: "teste@gmail.com", password: "senha123")
    assert_not user.save
  end

  test "should not save without names" do
    user = User.new(first_name: "Teste", role: 1, email: "teste@gmail.com", password: "senha123")
    assert_not user.save

    user.first_name = ""
    user.last_name = "Lispector"
    assert_not user.save
  end

  test "user should save" do
    assert User.new(first_name: "Teste", last_name: "Johnson", email: "teste@gmail.com", password: "senha123", role: 1).save
  end

  test "respective numbers should return right user roles" do
    assert_equal "manager", User.new(role: 1).role, "role 1 didn't return user role as manager"
    assert_equal "pj", User.new(role: 2).role, "role 2 didn't return user role as pj"
    assert_equal "employee", User.new(role: 3).role, "role 3 didn't return user role as employee"
  end

  test 'user will be admin regardless of the role' do
    manager = User.new(role: 1, admin: true)
    pj = User.new(role: 2, admin: true)
    employee = User.new(role: 3, admin: true)

    assert_not manager.manager?
    assert manager.admin?

    assert_not pj.pj?
    assert pj.admin?

    assert_not employee.employee?
    assert employee.admin?
  end

  test "sign up as pj role must create a company" do
    user = User.new(first_name: "Teste", last_name: "Testeson", email: "teste@teste.com", password: "123456", role: 2)
    user.save!
    assert_equal "teste@teste.com Company", Company.last.name
  end

  test 'should return docs that user is responsible by its text chunk' do
    assert_equal users(:reginald).text_chunks.map(&:document).uniq, users(:reginald).docs_for_review.to_a
  end
end
