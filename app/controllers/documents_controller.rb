class DocumentsController < ApplicationController
  before_action :set_document, except: %i[index new create]
  before_action :authorize_doc, except: %i[index new create translate chunk_search confirm_all_chunks row_number]
  before_action :set_chunks, only: %i[show translation editor chunk_search confirm_all_chunks export export_original export_bicolumn export_rich_text]

  def index
    @page = params[:page] || 1
    @documents = policy_scope(Document)
    ## All queries
    @title = params[:query] && params[:query][:title] ? params[:query][:title] : ""
    @status = params[:query] && params[:query][:status] ? params[:query][:status] : ""
    @date_start = params[:query] && params[:query][:date_start] ? params[:query][:date_start] : ""
    @date_end = params[:query] && params[:query][:date_end] ? params[:query][:date_end] : ""
    if params[:query]
      @documents = @documents.search_by_text(@title) if @title.present?
      @documents = @documents.search_by_status(@status * " ") if @status.present?
      if @date_start.present? && @date_end.present?
        @documents = @documents.where(created_at: DateTime.parse(@date_start)...DateTime.parse(@date_end).end_of_day)
      elsif @date_start.present?
        @documents = @documents.where('created_at >= ?', DateTime.parse(@date_start))
      elsif @date_end.present?
        @documents = @documents.where('created_at <= ?', DateTime.parse(@date_end).end_of_day)
      end
    end
    @documents = @documents.page(@page)
  end

  def show
    @base_url = request.base_url
    respond_to do |format|
      format.html {}
      format.turbo_stream { render turbo_stream: turbo_stream.replace("turbo_editor_doc_#{@document.id}", partial: 'documents/simple_editor', locals: { document: @document, chunks: @chunks, user: current_user }) }
    end
  end

  def new
    @document = Document.new
    authorize @document
  end

  def create
    @documents = policy_scope(Document)
    @document = Document.new(doc_params)
    @document.user = current_user
    @document.company = current_user.company
    @document.status = 0
    doc = params[:document][:doc]
    unless doc.nil?
      doc = Docx::Document.open(doc.tempfile)

      # Saves the original formatting
      @document.rich_original = doc.paragraphs.map { |p| p.to_html }.join

      # Extracts the text for translation
      raw_text = doc.doc.xpath('//w:document//w:body//w:p').map do |p_node|
        Docx::Elements::Containers::Paragraph.new(p_node)
      end
      raw_text.reject! { |p| p.text_runs.empty? }
      @document.original_text = ""
      raw_text.each { |t| @document.original_text += "#{t}\n" }
    end

    authorize @document

    @document.save ? (redirect_to @document) : (render :new)
  end

  def edit
    @users = User.where(company_id: current_user.company.id)
  end

  def update
    previous_text = @document.original_text
    previous_lang = @document.from_to_language

    content = []
    doc = params[:document][:doc]
    unless doc.nil?
      doc = Docx::Document.open(doc.tempfile)
      doc.doc.xpath('//w:document//w:body//w:tbl | //w:document//w:body//w:p').map do |node|
        if node.name == "p"
          content << node.text
        elsif node.name == 'tbl'
          node.xpath('w:tr').each do |tr_node|
            tr_node.xpath('w:tc').each do |tc_node|
              content << tc_node.text
            end
          end
        end
      end
      @document.original_text = content * "\n"
    end

    if @document.update(doc_params)
      # update document user
      @document.user = User.find(doc_params[:user_id]) if doc_params[:user_id].present?

      # reset the translation in case the original text changes
      if previous_text != @document.original_text || previous_lang != @document.from_to_language
        @document.translated_text = nil
        @document.was_translated = false
        @document.status = 0
        @document.save
      end

      # format user name to be shown in the document index page
      document_user_name = current_user.admin? ? @document.company.name : "#{@document.user.first_name.capitalize} #{@document.user.last_name.capitalize}"

      respond_to do |format|
        format.html { redirect_to @document }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("document-#{@document.id}-title", @document.title),
            turbo_stream.update("document-#{@document.id}-user", document_user_name )
          ]
        end
      end

    else
      render :edit, status: :unprocessable_entity # this is needed to make sure the modal doesn't close when there an error
    end
  end

  def translate
    authorize @document, :update?

    new_original = params[:document] ? params[:document][:original_text] : @document.original_text
    true_original = @document.original_text

    source_language = params[:document] ? params[:document][:source] : @document.source
    target_language = params[:document] ? params[:document][:target] : @document.target
    new_from_to = Document.new(source: params[:document][:source], target: params[:document][:target]).from_to_language
    true_from_to = @document.from_to_language

    translated = @document.was_translated
    notice = nil
    alert = nil

    #       original text changed     OR   no translation yet   OR   from_to_language changed...
    if (new_original != true_original ||       !translated      ||  new_from_to != true_from_to)

      # change the current text if a new text was given
      @document.original_text = new_original
      @document.source = source_language
      @document.target = target_language
      @document.was_translated = false

      @document.save

      # if the package still allows
      if new_original.split.size <= current_user.company.available_words
        # translate the text and save the document
        if send_document_to_translation
          company = current_user.company

          company.available_words -= new_original.split.size
          company.total_translated += new_original.split.size

          @document.status = 1

          @document.save if company.save

          @status = 'OK'
          notice = 'Documento enviado para tradução!'
        else
          @status = 'TRANSLATION-ERROR'
          alert = I18n.t('alert.error_translation')
        end
      else
        @status = 'NO-WORDS'
        alert = I18n.t('alert.no_words_available')
      end
    else
      @status = 'NOT-CHANGED'
      alert = I18n.t('alert.not_changed')
    end

    respond_to do |format|
      format.html do
        if notice
          redirect_to @document, notice: notice
        else
          redirect_to @document, alert: alert
        end
      end
      format.json do
        render json: {
          status: @status, original: @document.original_text, translated: @document.translated_text
        }
      end
    end
  end

  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_path, notice: t('notice.doc_removed') }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("document-row-#{@document.id}") }
    end
  end

  def editor
    respond_to do |format|
      format.html
      format.turbo_stream { render turbo_stream: turbo_stream.replace("turbo_editor_doc_#{@document.id}", partial: 'documents/editor_turbo') }
    end
  end

  def chunk_search
    authorize @document, :editor?

    case_sensitive = params[:search][:sensitive_case] == "0" ? "~*" : "~"

    @chunks = @chunks.where("original #{case_sensitive} ?", Regexp.escape(params[:search][:original])) if params[:search][:original].present?
    @chunks = @chunks.where("translated #{case_sensitive} ?", Regexp.escape(params[:search][:translated])) if params[:search][:translated].present?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:tableChunks, partial: 'documents/chunk_row')
      end
    end
  end

  def confirm_all_chunks
    authorize @document, :editor?

    @chunks.each do |chunk|
      current_user.admin? ? chunk.approved! : chunk.reviewed!
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:tableChunks, partial: 'documents/chunk_row')
      end
    end
  end

  def row_number
    authorize @document, :editor?
  end

  def export
    option = 'Translated' # this will be shown in the file name

    rendered_document = Caracal::Document.render "#{@document.title} - #{option}.docx" do |docx|
      @chunks.map { |chunk| docx.p chunk.translated }
    end

    download_docx(rendered_document, option)
  end

  def export_original
    option = 'Original' # this will be shown in the file name

    rendered_document = Caracal::Document.render "#{@document.title} - #{option}.docx" do |docx|
      @chunks.map { |chunk| docx.p chunk.original }
    end

    download_docx(rendered_document, option)
  end

  def export_bicolumn
    option = 'Bicolumn' # this will be shown in the file name

    rendered_document = Caracal::Document.render "#{@document.title} - #{option}.docx" do |docx|
      @chunks.map do |chunk|
        docx.table [[chunk.original, chunk.translated]] do
          # Table formatting settings
          border_color  'd3d3d3'
          border_line   :single
          border_size   4
        end
      end
    end

    download_docx(rendered_document, option)
  end

  def export_rich_text
    option = 'Rich Text' # this will be shown in the file name

    rich_text_html = @chunks.map(&:rich_translated).join
    rendered_document = Htmltoword::Document.create(rich_text_html)

    download_docx(rendered_document, option)
  end

  def select_glossaries
    @glossaries = policy_scope(Glossary).where(language_1: @document.source, language_2: @document.target).order(:name)
  end

  private

  def set_document
    @document = Document.find(params[:id] || params[:document_id])
  end

  def authorize_doc
    authorize @document
  end

  def doc_params
    params.require(:document).permit(:title, :original_text, :doc, :source, :target, :user_id)
  end

  def send_document_to_translation
    TranslateJob.perform_later(@document.id)
  end

  def set_chunks
    @chunks = @document.text_chunks.order(order: :asc)
  end

  def download_docx(rendered_document, option)
    send_data(
      rendered_document,
      filename: "#{@document.title} - #{option}.docx",
      type: 'application/docx'
    )
  end
end
