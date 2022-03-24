class TranslationMailer < ApplicationMailer
  def review
    @user = User.find(params[:user_id])
    @document = Document.find(params[:document_id])
    @company = @document.company

    mail(to: @user.email)
  end

  def ready
    @document = Document.find(params[:document_id])
    @user = @document.user

    mail(to: @user.email)
  end
end
