class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!, :set_locale, :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = t('alert.unauthorize_page')
    redirect_to root_path
  end

  def configure_permitted_parameters
    invite_params = %i[which_role first_name last_name]
    invite_params.push(:company_id) if current_user&.admin?
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[which_role first_name last_name])
    devise_parameter_sanitizer.permit(:invite, keys: invite_params)
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  private

  def after_sign_in_path_for(resource)
    resource.company.nil? && !current_user.admin? ? new_company_path : root_path
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def authorize_admin
    authorize current_user, :admin?
  end

  def set_locale
    I18n.locale = params.fetch(:locale, I18n.default_locale).to_sym
    gon.translations = I18n::JS.filtered_translations.to_json
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  def set_current_user
    Current.user = current_user
  end
end
