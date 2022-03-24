class Admin::PlansController < ApplicationController
  before_action :set_company
  before_action :authorize_admin

  def index
    @plans = policy_scope([:admin, Plan]).order(:id)
    @statuses = Plan.statuses.keys
    authorize Plan, :admin?
  end

  def show
    @plan = Plan.find(params[:id])
    authorize @plan, :admin?
  end

  def status
    @statuses = params[:plan][:status] if params[:plan]
    @statuses ? @plans = Plan.where(status: @statuses).order([:status, :id]) : @plans = []
    authorize Plan, :admin?
    @locale = I18n.locale
    respond_to do |f|
      f.json do
        render json: {
          plans: render_to_string(
            partial: 'admin/plans/status',
            formats: :html,
            layout: false
          )
        }
      end
    end
  end

  # def show
  #   authorize @plan
  # end

  def new
    @plan = Plan.new
    authorize @plan, :admin?
  end

  def create
    @plan = Plan.new(plan_params)
    authorize @plan, :admin?
    if @plan.save
      redirect_to admin_plans_path
    else
      render :new
    end
  end

  def edit
    @plan = Plan.find(params[:id])
    authorize @plan, :admin?
  end

  def update
    @plan = Plan.find(params[:id])
    authorize @plan, :admin?
    if @plan.update(plan_params)
      redirect_to admin_plans_path
    else
      render :edit
    end
  end

  def activate
    @plan = Plan.find(params[:plan_id])
    authorize @plan, :admin?
    @plan.set_pagarme_plan
    redirect_to admin_plans_path
  end

  def publish
    @plan = Plan.find(params[:plan_id])
    authorize @plan, :admin?
    @plan.published!
    redirect_to admin_plans_path
  end

  def deactivate
    @plan = Plan.find(params[:plan_id])
    authorize @plan, :admin?
    if @plan.companies.empty?
      @plan.discarded!
      redirect_to admin_plans_path
    else
      flash[:alert] = t('alert.plan_not_disabled')
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def plan_params
    params.require(:plan).permit(:name, :price_cents, :days, :trial_days, :charges, :installments, :invoice_reminder, :words, :include_review)
  end
end
