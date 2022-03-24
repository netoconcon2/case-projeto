class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :authorize_admin

  def index
    @page = params[:page] || 1
    @users = policy_scope([:admin, User]).page(@page)
    ## All queries
    @roles = User.translated_roles
    @name = params[:query] && params[:query][:name] ? params[:query][:name] : ""
    @role = params[:query] && params[:query][:role] ? params[:query][:role] : ""
    @date_start = params[:query] && params[:query][:date_start] ? params[:query][:date_start] : ""
    @date_end = params[:query] && params[:query][:date_end] ? params[:query][:date_end] : ""
    if params[:query]
      @users = @users.search_by_text(@name).page(@page) if @name.present?
      @users = @users.search_by_role(@role * " ") if @role.present?
      if @date_start.present? && @date_end.present?
        @users = @users.where(created_at: Date.parse(@date_start)...Date.parse(@date_end))
      elsif @date_start.present?
        @users = @users.where('created_at >= ?', Date.parse(@date_start))
      elsif @date_end.present?
        @users = @users.where('created_at <= ?', Date.parse(@date_end))
      end
    end
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :company_id, :role)
  end
end
