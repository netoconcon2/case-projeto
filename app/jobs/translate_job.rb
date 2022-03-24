class TranslateJob < ApplicationJob
  queue_as :translations

  def perform(document_id)
    doc = Document.find(document_id)

    if doc.translate
      doc.status = 3
      doc.was_translated = true
      doc.save

      User.where(admin: true).each do |user|
        TranslationMailer.with(user_id: user.id, document_id: doc.id).review.deliver_later
      end
    end
  end
end
