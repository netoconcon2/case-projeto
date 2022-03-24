# Preview all emails at http://localhost:3000/rails/mailers/translation_mailer
class TranslationMailerPreview < ActionMailer::Preview
  def review
    TranslationMailer.with(user_id: User.first.id, document_id: Document.first.id).review
  end

  def ready
    TranslationMailer.with(document_id: Document.first.id).ready
  end
end
