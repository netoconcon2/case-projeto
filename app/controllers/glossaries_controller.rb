class GlossariesController < ApplicationController
  before_action :set_glossary, only: %i[show edit update destroy import_terms create_terms]
  before_action :authorize_glossary, except: %i[index new create]

  def index
    @page = params[:page] || 1
    @glossaries = policy_scope(Glossary).order(:name)
    authorize Glossary

    ## Search
    @name = params[:query] && params[:query][:name] ? params[:query][:name] : ""
    @glossaries = @glossaries.search_by_text(@name) if params[:query] && @name.present?

    @glossaries = @glossaries.page(@page)
  end

  def show; end

  def new
    @glossary = Glossary.new
    authorize @glossary
  end

  def create
    @glossary = Glossary.new(glossary_params)
    authorize @glossary
    @glossary.company = current_user.admin? ? Company.first : current_user.company

    if @glossary.save
      import_xlsx unless params[:glossary][:xlsx].nil?

      respond_to do |format|
        flash.now[:notice] = I18n.t('notice.imported_terms', { count: @new_terms.length }) unless params[:glossary][:xlsx].nil?
        format.html { redirect_to @glossary }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('glossaries_list', partial: 'glossaries/glossary_row', locals: { glossary: @glossary }),
            turbo_stream.update("flash", partial: "shared/flashes")
          ]
        end
      end
    else
      render :new, status: :unprocessable_entity # this is needed to make sure the modal doesn't close when there an error
    end
  end

  def edit; end

  def update
    if @glossary.update(glossary_params)
      respond_to do |format|
        format.html { redirect_to @glossary }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@glossary, partial: 'glossaries/glossary_row', locals: { glossary: @glossary })
        end
      end
    else
      render :edit, status: :unprocessable_entity # this is needed to make sure the modal doesn't close when there an error
    end
  end

  def destroy
    @glossary.destroy

    respond_to do |format|
      format.html { redirect_to glossaries_path }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@glossary) }
    end
  end

  def import_terms; end

  def create_terms
    if params[:glossary][:xlsx].nil?
      render :import_terms, status: :unprocessable_entity # this is needed to make sure the modal doesn't close when there an error
    else
      import_xlsx
      flash.now[:notice] = I18n.t('notice.imported_terms', { count: @new_terms.length })
      render turbo_stream: [
        turbo_stream.after(:'new-term', partial: 'glossaries/terms_rows', locals: { terms: @new_terms }),
        turbo_stream.update("flash", partial: "shared/flashes")
      ]
    end
  end

  private

  def glossary_params
    params.require(:glossary).permit(:name, :language_1, :language_2)
  end

  def authorize_glossary
    authorize @glossary
  end

  def set_glossary
    @glossary = Glossary.find(params[:id] || params[:glossary_id])
  end

  def import_xlsx
    xlsx_file = params[:glossary][:xlsx]
    header = params[:glossary][:has_header] == '1'
    xlsx = Roo::Spreadsheet.open(xlsx_file)
    @new_terms = []
    xlsx.each_with_index do |row, index|
      next if index.zero? && header

      term = Term.new(source: row[0], target: row[1])
      term.glossary = @glossary
      @new_terms << term if term.save
    end
    @new_terms
  end
end
