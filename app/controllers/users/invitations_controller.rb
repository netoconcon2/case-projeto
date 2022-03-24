class Users::InvitationsController < Devise::InvitationsController
  before_action :user_from_invitation_token, only: %i[destroy]
  prepend_before_action :resource_from_invitation_token, only: %i[edit]
  prepend_before_action :require_no_authentication, only: %i[edit update]

  def destroy
    user = User.find_by(invitation_token: params[:invitation_token])
    user.destroy
    flash[:notice] = I18n.t('flash.invitation_removed')
    redirect_to company_path
  end

  def new
    authorize current_user, :validated_not_pj?
    @company = Company.find(params[:company]) if params[:company]
    self.resource = resource_class.new
    respond_to do |f|
      f.json do
        render json: {
          form: render_to_string(
            partial: 'users/invitations/new',
            formats: :html,
            layout: false
          )
        }
      end
    end
  end

  def create
    authorize current_user, :validated_not_pj?
    @company = Company.find(params[:user][:company_id]) if params[:user] && params[:user][:company_id].present?
    @page = 1
    @users = @company.users.order(created_at: :desc).page(@page) if @company.present?

    respond_to do |format|
      format.html { super }
      format.js do
        self.resource = invite_resource
        render :create, resource: resource
      end
    end
  end

  protected

  def resource_from_invitation_token
    params[:invitation_token] = params[:invitation_token].delete_prefix('3D')

    super
  end

  def user_from_invitation_token
    return if params[:invitation_token] && User.find_by(invitation_token: params[:invitation_token])

    flash[:error] = I18n.t('flash.invitation_not_found')
    redirect_to company_path
  end

  def invite_resource(&block)
    company_params = current_user.admin? ? invite_params[:company_id] : current_inviter.company.id
    resource_class.invite!({ first_name: invite_params["first_name"],
                             last_name: invite_params["last_name"],
                             email: invite_params["email"],
                             which_role: invite_params["which_role"],
                             company_id: company_params }, current_inviter, &block)
  end

  private

  def authorize_invite
    authorize User, :special_access?
  end
end
