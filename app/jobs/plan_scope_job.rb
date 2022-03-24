class PlanScopeJob < ApplicationJob
  queue_as :scope

  def perform(company_id)
  	company = Company.find(company_id)
  	return unless company.plan
  	
  	plan = company.plan

  	unless company.check_if_already_updated? #=> true altready updated / false need to update
      if company.check_subscription_status? #=> the current subscription status is "paid"?
  		  company.words += plan.words
      end
  	end
  end
end
