class Admin::DocumentsController < ApplicationController
  before_action :set_document, only: %i[update]
  before_action :authorize_admin

  def update
    authorize @document

    if @document.update(doc_params)
      if @document.was_translated
        @document.translated! unless @document.translated?

        notice = t('notice.doc_ready')

        # send email to owner of document saying translation is ready
        TranslationMailer.with(document_id: @document.id).ready.deliver_later
      else
        @document.being_reviewed! unless @document.being_reviewed?

        notice = t('notice.doc_not_available')
      end

      redirect_to documents_path, notice: notice
    else
      render @document
    end
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def doc_params
    params.require(:document).permit(:original_text, :doc, :was_translated, :translated_text)
  end
end
