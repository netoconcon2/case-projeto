class Admin::AppliesController < ApplicationController
  before_action :set_company, only: %i[show validate]
  before_action :authorize_admin

  def index
    @page = params[:page] || 1
    @companies = ApplyPolicy::Scope.new(current_user, Company).resolve.page(@page)
    ## All queries
    @statuses = Company.translated_statuses.values_at(0, 3)
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
    authorize Company, :admin?
  end

	def show
	end

  def validate
    @company.validate!
    redirect_to admin_applies_path
  end

	private

	def set_company
		@company = Company.find(params[:apply_id])
	end
end
