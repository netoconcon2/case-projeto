class TextChunksController < ApplicationController
  before_action :set_chunk, :authorize_chunk, only: %i[confirm versions]

  def update
    @text_chunk = TextChunk.find(params[:id] || params[:text_chunk_id])
    # Authorized people: admin, company manager, document user
    authorize @text_chunk, :admin_or_doc_authorized?

    respond_to do |format|
      format.turbo_stream do
        @text_chunk.update(text_chunk_params)
        render turbo_stream: turbo_stream.replace("chunk_status_#{@text_chunk.id}".to_sym, partial: 'documents/chunk_confirm_btn', locals: { txt_chunk: @text_chunk })
      end
    end
  end

  def confirm
    @text_chunk.approved!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("chunk_status_#{@text_chunk.id}".to_sym, partial: 'documents/chunk_confirm_btn', locals: { txt_chunk: @text_chunk })
      end
    end
  end

  def versions
    respond_to do |f|
      f.turbo_stream { render turbo_stream: turbo_stream.update('modal', partial: 'documents/chunk_versions') }
    end
  end

  def glossaries
    document = Document.find(params[:document_id])
    text_chunk = TextChunk.find(params[:text_chunk_id])
    @terms = document.terms.where("? ~* source", text_chunk.original)
    authorize document, :editor?

    respond_to do |f|
      f.turbo_stream { render turbo_stream: turbo_stream.update(:glossaries_terms, partial: 'text_chunks/terms') }
      f.json { render json: { terms: @terms.map(&:source) } }
    end
  end

  private

  def authorize_chunk
    authorize @text_chunk, :admin_or_doc_authorized?
  end

  def set_chunk
    @text_chunk = TextChunk.find(params[:id] || params[:text_chunk_id])
  end

  def text_chunk_params
    params.require(:text_chunk).permit(:rich_translated)
  end
end
