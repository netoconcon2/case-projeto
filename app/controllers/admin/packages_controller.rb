class Admin::PackagesController < ApplicationController
  before_action :set_package, only: %i[edit update]
  before_action :authorize_admin

  def index
    @packages = policy_scope(Package)
  end

  def show
    @package = Package.find(params[:id])
  end

  def status
    @statuses = params[:plan][:status] if params[:plan]
    @statuses ? @plans = Plan.where(status: @statuses) : @plans = []
    authorize Plan, :admin?
    @statuses = params[:package][:status] if params[:package]
    @statuses ? @packages = Package.where(status: @statuses).order([:status, :id]) : @packages = []

    @locale = I18n.locale
    respond_to do |f|
      f.json do
        render json: {
          plans: render_to_string(
            partial: 'admin/packages/status',
            formats: :html,
            layout: false
          )
        }
      end
    end
  end

  def new
    @package = Package.new(price: nil)
  end

  def create
    @package = Package.new(package_params)
    if @package.save
      redirect_to admin_packages_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @package.update(package_params) ? (redirect_to admin_packages_path) : (render :edit)
  end

  def destroy
    @package = Package.find(params[:id])
    @package.destroy
    redirect_to admin_packages_path
  end

  def visualize!
    @package = Package.find(params[:package_id])
    authorize @package, :not_published?
    @package.visible!
    redirect_to admin_packages_path
  end

  def invisiblize!
    @package = Package.find(params[:package_id])
    @package.invisible!
    @package.save
    redirect_to admin_packages_path
  end

  def pagarme_transaction(card)
    package_id = params["order"]["package"].to_i
    package = Package.find(package_id)
    company = current_user.company
    company.update_available_words(package.words)
    redirect_to root_path
  end

  private

  def set_package
    @package = Package.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :price, :words)
  end
end
