require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  setup do
    @plan = plans(:visible_one)
    @sparrow = companies(:sparrow)
    @northern = companies(:northern)
    @disney = companies(:disney)
    @walter = users(:walter)
  end

  test "should not save a company without an owner" do
    company_test = Company.new(cnpj: "11.111.111/1111-11", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", name: "Test Company")

    assert_not company_test.valid?
    assert company_test.errors.messages[:owner].present?
  end

  test "address required if owner's account is for companies" do
    user_test = User.create(email: "teste@gmail.com", password: "senha123", role: 1)
    company_test = Company.new(name: "Test 1023 Company", cnpj: "11.111.111/1111-11", owner: user_test)

    assert_not company_test.valid?
    assert_equal 8, company_test.errors.messages.size
  end

  test "cnpj required if owner's account is for companies" do
    user_test = User.create(email: "teste@gmail.com", password: "senha123", role: 1)
    company_test = Company.new(street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", name: "Test 1023 Company", owner: user_test)

    assert_not company_test.valid?
    assert company_test.errors.messages[:cnpj].present?
  end

  test "cnpj has a specific format" do
    user_test = User.create(email: "teste@gmail.com", password: "senha123", role: 1)
    company_test = Company.new(cnpj: "11.1111.111.11111", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", name: "Test 1023 Company", owner: user_test)
    company_test2 = Company.new(cnpj: "imtrollhaha", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", name: "Test 1023 Company", owner: user_test)

    assert_not company_test.valid?
    assert company_test.errors.messages[:cnpj].present?
    assert_not company_test2.valid?
    assert company_test2.errors.messages[:cnpj].present?
  end

  test "should not save a company without a name" do
    user_test = User.create(email: "teste@gmail.com", password: "senha123", role: 1)
    company_test = Company.new(cnpj: "11.111.111/1111-11", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", owner: user_test)

    assert_not company_test.valid?
    assert company_test.errors.messages[:name].present?
  end

  test "not defined status should be automatically set as review" do
    company_test = Company.new(name: "Test Company")
    assert_equal "review", company_test.status
  end

  test "respective numbers should return right company status" do
    company_test1 = Company.new(name: "Test 1 Company", status: 0)
    company_test2 = Company.new(name: "Test 2 Company", status: 1)
    company_test3 = Company.new(name: "Test 3 Company", status: 2)

    assert_equal "review", company_test1.status, "status as 0 should return company status as review"
    assert_equal "validated", company_test2.status, "status as 1 should return company status as validated"
    assert_equal "completed", company_test3.status, "status as 2 should return company status as completed"
  end

  test "subscribe method should not works in company with review status" do
    assert_nil @northern.subscribe(@plan), "#subscribe method added a plan to a company in review status"
  end

  test "subscribe method should change company status from validated to completed and add a plan" do
    assert @disney.subscribe(@plan), "#subscribe method wasn't successful"
    assert_equal "completed", @disney.status, "#subscribe method hasn't changed the status"
    assert_equal @plan, @disney.plan, "#subscribe method hasn't updated the plan"
  end

  test "should check if the company has a plan" do
    assert @sparrow.plan?, "#plan? method hasn't returned true"
  end

  test "#validate! method should works only in companies with review status" do
    assert_nil @sparrow.validate!, "#validate! works in a company with complete status"
    assert @northern.validate!, "#validate! not works in a company with review status"
  end

  test "#complete! method should works only in companies with validated status" do
    assert_nil @northern.complete!, "#complete! works in a company with review status"
    @disney.plan = plans(:visible_one)
    assert @disney.complete!, "#complete! not works in a company with validated status"
  end

  test "after destroy a company #delete_employees should be called" do
    @disney.destroy
    assert_empty User.where(email: 'mickey@mouse.com'), "a manager was not deleted after company destroyed"
    assert_empty User.where(email: 'donald@duck.quack'), "a employee was not deleted after company destroyed"
    assert_equal @walter, User.find(@disney.owner.id), "company owner was also deleted"
  end

  test "after destroy a company the owner should persist and company_id nullify" do
    @disney.destroy
    assert_nil User.find(@disney.owner.id).company, "the company id from owner isn't nil"
  end

  test "after create a company the owner should update the company id" do
    test_user = User.create(first_name: "Teste", last_name: "Ferreira",email:"teste@teste.com", password: "123123", role: 1)
    company_test = Company.create(cnpj: "11.111.111/1111-11", street: "Lorem Ipsum street", street_number: 111, zip_code: "04242-424", city: "Townsville", country: "Brazil", state: "Somewhere", phone: "(11) 96666-6666", neighborhood: "Limoeiro", name: "Company Test", owner: test_user)
    assert_equal company_test, test_user.company, "the company_id from owner has not been updated"
  end

  test "all documents should be deleted after company destruction" do
    doc_test = Document.create(company: @sparrow)
    @sparrow.destroy
    assert_raises ActiveRecord::RecordNotFound, "document test was not deleted after company was destroyed" do
      Document.find(doc_test.id)
    end
    assert_empty Document.where(company: @sparrow), "after destroy company, not all documents was destroyed too"
  end
end
