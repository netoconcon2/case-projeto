class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update]

  def show
    @page = params[:page] || 1
    @users = CompanyPolicy::Scope.new(current_user, User).resolve.page(@page)
    if current_user.owner?
      @invitations = User.created_by_invite.where(company: current_user.company).where.not(invitation_token: nil)
    elsif current_user.manager?
      @invitations = User.created_by_invite.where(invited_by_id: current_user.id).where.not(invitation_token: nil)
    end

    current_user.company ? (authorize @company) : (authorize current_user, :company?)
  end

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(company_params)
    @company.status = 0
    authorize @company

    @company.owner = current_user

    if @company.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
    authorize @company, :update?
  end

  def update
    authorize @company
    if @company.update(company_params)
      @company.review! if @company.denied?
      redirect_to company_path
    else
      render :edit
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def company_params
    params.require(:company).permit(:name, :cnpj, :street, :street_number, :zip_code, :neighborhood, :phone, :country, :city, :state, :street_line_2)
  end
end
