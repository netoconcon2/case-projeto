class UserMailer < ApplicationMailer
  def welcome
    @user = User.last

    mail(to: @user.email, subject: 'Welcome to Decode')
  end
end
