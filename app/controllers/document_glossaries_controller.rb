class DocumentGlossariesController < ApplicationController
  def create
    document = Document.find(params[:document_id])
    params[:document_glossaries].each_pair do |key, value|
      glossary = Glossary.find(key[/\d+\z/].to_i)
      doc_glossary = DocumentGlossary.find_by(document: document, glossary: glossary) || DocumentGlossary.new(document: document, glossary: glossary)
      authorize doc_glossary

      if value == "1"
        doc_glossary.save unless doc_glossary.persisted?
      else
        doc_glossary.destroy
      end
    end
  end

  private

  def doc_glossary_params
    params.require(:document_glossary).permit(:document_glossaries, :document_id)
  end
end
