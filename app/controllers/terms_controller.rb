class TermsController < ApplicationController
  before_action :set_term, :authorize_term, only: %i[edit update destroy show]
  before_action :set_glossary, only: %i[new create editor_create]
  before_action :new_term, only: %i[new editor_new]
  before_action :create_term, only: %i[create editor_create]

  def show; end

  def new; end

  def editor_new
    @page = params[:page] || ''
    @document = Document.find(params[:document])
    if params[:term]
      params[:term][:glossary].present? ? @glossary = Glossary.find(params[:term][:glossary]) : @term.valid?
    end
    @glossaries =policy_scope(Glossary).where(language_1: @document.source, language_2: @document.target).order(:name)
  end

  def create
    respond_to do |f|
      if @term.save
        f.turbo_stream { render turbo_stream: turbo_stream.replace(:'new-term', partial: 'terms/row', locals: { term: @term }) }
      else
        f.turbo_stream { render turbo_stream: turbo_stream.replace(:'new-term', partial: 'terms/new') }
      end
    end
  end

  def editor_create
    @glossaries = policy_scope(Glossary)
    @page = '2'
    @document = Document.find(params[:document])

    respond_to do |f|
      if @term.save
        f.turbo_stream
      else
        f.turbo_stream { render turbo_stream: turbo_stream.replace(:'editor-new-term', partial: 'terms/form', locals: { page: '2', document: @document }), status: 422 }
      end
    end
  end

  def edit; end

  def update
    respond_to do |f|
      if @term.update(term_params)
        f.turbo_stream { render turbo_stream: turbo_stream.replace("term-#{@term.id}".to_sym, partial: 'terms/row_content', locals: { term: @term }) }
      else
        f.turbo_stream { render turbo_stream: turbo_stream.replace("term-#{@term.id}".to_sym, partial: 'terms/edit') }
      end
    end
  end

  def destroy
    @term.destroy

    respond_to do |format|
      format.html { redirect_to glossary_path(@term.glossary) }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("term-#{@term.id}") }
    end
  end

  private

  def term_params
    params.require(:term).permit(:source, :target)
  end

  def set_term
    @term = Term.find(params[:id] || params[:term_id])
  end

  def set_glossary
    @glossary = Glossary.find(params[:glossary_id] || params[:glossary])
  end

  def new_term
    @term = Term.new(glossary: @glossary)
    authorize @term
  end

  def create_term
    @term = Term.new(term_params)
    @term.glossary = @glossary

    authorize @term
  end

  def authorize_term
    authorize @term
  end
end
