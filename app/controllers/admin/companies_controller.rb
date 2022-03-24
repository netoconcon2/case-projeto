class Admin::CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update destroy validate deny]
  before_action :authorize_admin

  def index
    @page = params[:page] || 1
    @companies = policy_scope([:admin, Company])
    ## All queries
    @statuses = Company.translated_statuses.values_at(1, 2)
    @name = params[:query] && params[:query][:name] ? params[:query][:name] : ""
    @status = params[:query] && params[:query][:status] ? params[:query][:status] : ""
    @date_start = params[:query] && params[:query][:date_start] ? params[:query][:date_start] : ""
    @date_end = params[:query] && params[:query][:date_end] ? params[:query][:date_end] : ""
    if params[:query]
      @companies = @companies.search_by_text(@name) if @name.present?
      @companies = @companies.search_by_status(@status * " ") if @status.present?
      if @date_start.present? && @date_end.present?
        @companies = @companies.where(created_at: Date.parse(@date_start)...Date.parse(@date_end))
      elsif @date_start.present?
        @companies = @companies.where('created_at >= ?', Date.parse(@date_start))
      elsif @date_end.present?
        @companies = @companies.where('created_at <= ?', Date.parse(@date_end))
      end
    end
    @companies = @companies.page(@page)
  end

  def show
    @page = params[:page] || 1
    @users = @company.users.order(created_at: :desc).page(@page)
    # @plan = PagarMe::Plan.find_by_id(@company.plan.pagarme_id)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.save ? (redirect_to admin_companies_path) : (render :new)
  end

  def edit
    @users = User.where(role: [1], company: @company).map do |user|
      [user.email, user.id]
    end
  end

  def cancel_plan
    company = Company.find(params[:company_id])
    plan = company.plan
    subscription = PagarMe::Subscription.find_by_id(company.pagarme_subscription_id)
    begin
      subscription.cancel
    rescue
      error = true
    end
    # @company.available_words = 0 # Company will keep the words left

    unless error
      company.plan = nil
      company.pagarme_subscription_id = nil
      company.status = 1
      company.save
    end
    flash[:alert] = t('alert.error_cancel') if error
    redirect_to admin_plan_path(plan)
  end

  def validate
    @company.validate!
    redirect_to admin_company_path(@company)
  end

  def deny
    @company.denied!
    redirect_to admin_company_path(@company)
  end

  def update
    if @company.update(company_params)
      redirect_to admin_company_path(@company)
    else
      render :edit
    end
  end

  def destroy
  end

  private

  def company_params
    company_params_allowed = %i[name cnpj street street_number zip_code neighborhood phone country city state street_line_2]
    company_params_allowed.push(:status, :user_id, :available_words) if current_user.admin?
    params.require(:company).permit(company_params_allowed)
  end

  def set_company
    @company = Company.find(params[:id] || params[:company_id])
  end
end
