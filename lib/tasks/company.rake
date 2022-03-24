namespace :company do
  desc "Update all companies plan scopes"
  task update_company_words: :environment do
  	companies = Company.all
  	companies.each do |company|
  		company.perform_plan_scope_job
  	end
  end

end
