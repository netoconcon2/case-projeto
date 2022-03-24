require "mobile_system_test_case"

class MobilePlansTest < MobileSystemTestCase
  setup do
    @plans = Plan.all
    @plan = plans(:visible_one)
    @admin = users(:siriguejo)
    @manager = users(:reginald)
    @pj = users(:jabba)
    @pj_no_plan = users(:jarjar)
    @no_company = users(:new_user)
  end

  test "only visible plans appear in public page" do
    visit "/plans"
    assert_selector ".plan-card", count: @plans.where(status: 2).count
  end

  test "admin can see all plans" do
    login_as @admin
    visit "/admin/plans"

    assert_selector ".card-square", count: @plans.count
  end

  test "admin can see plans by status" do
    login_as @admin
    visit "/admin/plans"

    find(:css, "#dropdownSelectBtn").click()
    find(:css, "#plan_status_all").set(false)
    find(:css, "#status_0[value='inactive']").set(true)
    find(:css, "#dropdownSelectBtn").click()
    assert_selector ".card-square", count: Plan.where(status: 'inactive').count
    assert_selector ".card-square h3", text: "Plano Criado"

    find(:css, "#dropdownSelectBtn").click()
    find(:css, "#status_0[value='inactive']").set(false)
    find(:css, "#status_1[value='active']").set(true)
    find(:css, "#dropdownSelectBtn").click()
    assert_selector ".card-square", count: Plan.where(status: 'active').count
    assert_selector ".card-square h3", text: "Plano Ativado"

    find(:css, "#dropdownSelectBtn").click()
    find(:css, "#status_1[value='active']").set(false)
    find(:css, "#status_2[value='published']").set(true)
    find(:css, "#dropdownSelectBtn").click()
    assert_selector ".card-square", count: Plan.where(status: 'published').count
    assert_selector ".card-square h3", text: "Plano Visivel"

    find(:css, "#dropdownSelectBtn").click()
    find(:css, "#status_2[value='published']").set(false)
    find(:css, "#status_3[value='discarded']").set(true)
    find(:css, "#dropdownSelectBtn").click()
    assert_selector ".card-square", count: Plan.where(status: 'discarded').count
    assert_selector ".card-square h3", text: "Plano Desativado"
  end

  test "admin can create a new plan" do
    planNum = Plan.count
    login_as @admin
    visit "/admin/plans/new"

    fill_in "plan_name", with: "Teste"
    fill_in "plan_price", with: 1
    fill_in "plan_days", with: 1
    fill_in "plan_trial_days", with: 1
    fill_in "plan_charges", with: 1
    fill_in "plan_installments", with: 1
    fill_in "plan_invoice_reminder", with: 1

    click_on 'Criar Plano'

    assert_current_path admin_plans_path
    assert_selector ".card-square", count: planNum + 1
    assert_selector ".card-square h3", text: "Teste"
  end

  test "manager user visiting admin plan pages" do
    login_as @manager

    visit "/admin/plans/new"
    assert_current_path root_path
    visit "/admin/plans"
    assert_current_path root_path
  end

  test "pj user visiting admin plan pages" do
    login_as @pj

    visit "/admin/plans/new"
    assert_current_path root_path
    visit "/admin/plans"
    assert_current_path root_path
  end

  test "user without company visiting admin plan pages" do
    login_as @no_company

    visit "/admin/plans/new"
    assert_current_path root_path
    visit "/admin/plans"
    assert_current_path root_path
  end

  test "subscribing to a plan as pj" do
    login_as @pj_no_plan
    visit plans_url

    find("#subscribe-#{@plan.id}").click
    assert_current_path plan_subscribe_path(@plan.id)
  end

  test "subscribing to a plan as manager" do
    login_as @manager
    visit plans_url

    find("#subscribe-#{@plan.id}").click
    assert_current_path plan_subscribe_path(@plan.id)
  end

  test "admin can see all subscribers of a plan" do
    login_as @admin
    @plan

    visit "/admin/plans/#{@plan.id}"

    assert_selector ".mt-2", count: @plan.companies.count
  end

  test "admin can cancel a subscription" do
    subscribers = @plan.companies.count

    login_as @admin
    @plan

    visit "/admin/plans/#{@plan.id}"

    find(".btn-warning").click
    assert_selector ".mt-2", count: @plan.companies.count - 1

  end

  test "admin cannot disable a plan with subscribers" do
    subscribers = @plan.companies.count

    login_as @admin
    @plan

    visit "/admin/plans/#{@plan.id}"

    if subscribers.zero?
      assert_selector ".btn-deactivate", count: 1
    else
      assert_selector ".btn-deactivate", count: 0
    end
  end
end
