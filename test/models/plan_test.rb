require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test "new plan should have status inactive and pagarme_id nil" do
    plan = Plan.new(name: "Plano Criado", price: 1, days: 1, trial_days: 1, charges: 1, installments: 1, invoice_reminder: 1)
    assert_equal "inactive", plan.status
    assert_nil plan.pagarme_id
  end

  test "respective numbers should return right plan status" do
    plan_in = Plan.new(status: 0)
    plan_ac = Plan.new(status: 1)
    plan_pub = Plan.new(status: 2)
    plan_dis = Plan.new(status: 3)

    assert_equal "inactive", plan_in.status, "plan status 0 should return inactive"
    assert_equal "active", plan_ac.status, "plan status 1 should return active"
    assert_equal "published", plan_pub.status, "plan status 2 should return published"
    assert_equal "discarded", plan_dis.status, "plan status 3 should return discarded"
  end

  test "inactive plans can't have pagarme_id" do
    plan = Plan.new(name: "Plan Inactive Test", price: 1, days: 1, trial_days: 1, charges: 1, installments: 1, invoice_reminder: 1, pagarme_id: 777)
    assert_not plan.valid?
    assert_equal I18n.t('activerecord.errors.models.plan.attributes.pagarme_id.not_inactive_plan'), plan.errors.messages[:pagarme_id][0]
  end

  test "should have pagarme id unless plan is inactive" do
    plan_active = Plan.new(name: "Plan Active Test", price: 1, days: 1, trial_days: 1, charges: 1, installments: 1, invoice_reminder: 1, status: 1)
    plan_published = Plan.new(name: "Plan Published Test", price: 1, days: 1, trial_days: 1, charges: 1, installments: 1, invoice_reminder: 1, status: 2)
    plan_discarded = Plan.new(name: "Plan Discarded Test", price: 1, days: 1, trial_days: 1, charges: 1, installments: 1, invoice_reminder: 1, status: 3)

    assert_not plan_active.valid?
    assert_not plan_published.valid?
    assert_not plan_discarded.valid?

    assert_equal I18n.t('activerecord.errors.models.plan.attributes.pagarme_id.inactive_plan'), plan_active.errors.messages[:pagarme_id][0]
    assert_equal I18n.t('activerecord.errors.models.plan.attributes.pagarme_id.inactive_plan'), plan_published.errors.messages[:pagarme_id][0]
    assert_equal I18n.t('activerecord.errors.models.plan.attributes.pagarme_id.inactive_plan'), plan_discarded.errors.messages[:pagarme_id][0]
  end

  test "plan inlcude review default is false" do
    plan = Plan.new
    assert_not plan.include_review
  end

  test "plan include review can be either true or false" do
    plan_with_review = Plan.new(name: "Plan test", price: 10, words: 100, days: 30, status: 0, include_review: true)
    plan_without_review = Plan.new(name: "Plan test", price: 10, words: 100, days: 30, status: 0, include_review: false)

    assert plan_with_review.valid?
    assert plan_with_review.include_review
    assert plan_without_review.valid?
  end
end
