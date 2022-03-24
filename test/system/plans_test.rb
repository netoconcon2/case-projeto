require "application_system_test_case"

class PlansTest < ApplicationSystemTestCase
  setup do
    @plans = Plan.all
    @plan = plans(:visible_one)
    @new_plan = plans(:visible_two)
    @admin = users(:siriguejo)
    @manager = users(:reginald)
    @pj = users(:jabba)
    @pj_no_plan = users(:jarjar)
    @no_company = users(:new_user)
  end

  test "only visible plans appear in public page" do
    login_as @manager

    visit "/plans"

    assert_selector ".card-plan", count: @plans.where(status: 2).count
  end

  test "visiting the plans index" do
    visit root_url

    click_on I18n.t('shared.navbar.prices')
    assert_current_path plans_path
    assert_selector "h1", text: I18n.t('plans.index.choose_a_plan')

    login_as @manager

    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.plans'), exact_text: true).click
    assert_current_path plans_path
    assert_selector "h1", text: I18n.t('plans.index.choose_a_plan')

    logout(:user)

    login_as @pj

    visit root_url
    find('a', text: I18n.t('shared.dashboard_navbar.plans'), exact_text: true).click
    assert_current_path plans_path
    assert_selector "h1", text: I18n.t('plans.index.choose_a_plan')
  end

  test "button to cancel or subscribe should only appear to validated companies" do
    visit plans_url

    assert_no_selector ".btn-orange", text: I18n.t('plans.index.cancel_subs')
    assert_no_selector ".btn-orange", text: I18n.t('plans.index.choose_plan')

    login_as users(:neto)

    visit plans_url

    assert_no_selector ".btn-orange", text: I18n.t('plans.index.cancel_subs')
    assert_no_selector ".btn-orange", text: I18n.t('plans.index.choose_plan')

    logout :user

    login_as @manager

    visit plans_url

    assert_selector ".btn-orange", text: I18n.t('plans.index.cancel_subs')
    assert_selector ".btn-orange", text: I18n.t('plans.index.choose_plan')
  end

  test "admin can see all plans" do
    login_as @admin
    visit "/admin/plans"

    assert_selector ".card-square", count: @plans.count
  end

  test "admin can see plans by status" do
    login_as @admin
    visit "/admin/plans"

    find(:css, "#plan_status_all").set(false)

    assert_no_selector ".card-square", wait: 10
    find(:css, "#status_0[value='inactive']").set(true)
    assert_selector ".card-square", count: Plan.where(status: 'inactive').count, wait: 10
    assert_selector ".card-square h3", text: "Plano Criado"

    find(:css, "#status_0[value='inactive']").set(false)
    find(:css, "#status_1[value='active']").set(true)
    assert_selector ".card-square", count: Plan.where(status: 'active').count, wait: 10
    assert_selector ".card-square h3", text: "Plano Ativado"

    find(:css, "#status_1[value='active']").set(false)
    find(:css, "#status_2[value='published']").set(true)
    assert_selector ".card-square", count: Plan.where(status: 'published').count, wait: 10
    assert_selector ".card-square h3", text: "Plano Visivel"

    find(:css, "#status_2[value='published']").set(false)
    find(:css, "#status_3[value='discarded']").set(true)
    assert_selector ".card-square", count: Plan.where(status: 'discarded').count, wait: 10
    assert_selector ".card-square h3", text: "Plano Desativado"
  end

  test "admin can create a new plan" do
    planNum = Plan.count
    login_as @admin
    visit "/admin/plans/new"

    fill_in "plan_name", with: "Teste"
    fill_in "plan_price_cents", with: 1000
    fill_in "plan_days", with: 1
    fill_in "plan_trial_days", with: 1
    fill_in "plan_charges", with: 1
    fill_in "plan_installments", with: 1
    fill_in "plan_words", with: 100

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

    find("#subscribe-#{@new_plan.id}").click
    assert_current_path plan_subscribe_path(plan_id: @new_plan)
  end

  test "subscribing to a plan as manager" do
    login_as @manager
    visit plans_url

    find("#subscribe-#{@new_plan.id}").click
    assert_current_path plan_subscribe_path(plan_id: @new_plan)
  end
end
