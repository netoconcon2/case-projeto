class Api::V1::UsersController < Api::V1::BaseController
  def counter
    @users = User.all
  end
end
