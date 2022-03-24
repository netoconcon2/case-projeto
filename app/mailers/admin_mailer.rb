class AdminMailer < ApplicationMailer
  def text_chunk_error
    admins = User.where(admin: true)
    @text_chunk = TextChunk.find(params[:text_chunk_id])
    @document = Document.find(@text_chunk.document.id)

    admins.each do |admin|
      mail(to: admin.email)
    end
  end
end
