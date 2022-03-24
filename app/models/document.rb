class Document < ApplicationRecord
  include TranslateEnum
  include PgSearch::Model

  # associations
  has_one_attached :doc
  belongs_to :company
  belongs_to :user
  has_many :text_chunks, dependent: :destroy
  has_many :responsibles, -> { distinct }, through: :text_chunks, class_name: 'User'
  has_many :document_glossaries, dependent: :destroy
  has_many :glossaries, through: :document_glossaries
  has_many :terms, through: :glossaries

  paginates_per 10

  enum status: {
    original: 0,
    being_translated: 1,
    being_reviewed: 2,
    translated: 3
  }
  translate_enum :status

  # validates :doc, attached: true, content_type: { in: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', message: 'is not a Docx file' }
  validates :original_text, presence: true
  validates :title, presence: true, uniqueness: { scope: :company }
  validates :target, :source, presence: true, inclusion: { in: LANGUAGES }
  validate :different_target_source_language

  pg_search_scope :search_by_text,
                  against: { title: 'A' },
                  associated_against: {
                    user: { email: 'B' }
                  },
                  using: {
                    trigram: {},
                    tsearch: { prefix: true, any_word: true }
                  },
                  order_within_rank: "documents.created_at DESC"
  pg_search_scope :search_by_status,
                  against: :status,
                  using: {
                    tsearch: { any_word: true }
                  },
                  order_within_rank: "documents.created_at DESC"

  # broadcasts
  after_update_commit :broadcast_update

  # methods
  def responsible?(user)
    responsibles.include?(user)
  end

  def from_to_language
    "#{source}_#{target}"
  end

  def translate
    return if original_text.blank?

    client = Google::Cloud::Translate.translation_service
    project_id = ENV['GCP_PROJECT_ID']
    location_id = ENV['GCP_LOCATION_ID']
    parent = client.location_path project: project_id, location: location_id
    model = "#{parent}/models/#{model_id}"

    begin
      # split the text in chunks of 20000 bytes ~= 20000 chars
      paragraphs = original_text.split(/\n+/).reject { |paragraph| paragraph =~ /^\W*$/ }

      text_chunks = []
      chunk = ''
      paragraphs.each_with_index do |p, i|
        if (chunk + "#{p}\n").length > 20_000
          text_chunks << chunk
          chunk = ''
        end
        chunk += "#{p}\n"
        text_chunks << chunk if i == (paragraphs.length - 1)
      end
      # text_chunks = original_text.unpack("a20000" * ((original_text.length / 20_000) + (original_text.size % 20_000 > 0 ? 1 : 0)) )
      text_chunks.map! do |str|
        begin
          str.encode("ISO-8859-1").encode("UTF-8")
        rescue Encoding::UndefinedConversionError => e
          str.encode("UTF-8")
        end
      end

      self.translated_text = ""

      text_chunks.each do |text_chunk|
        begin
          response = client.translate_text(
            parent: parent,
            contents: [text_chunk],
            model: model,
            mime_type: 'text/plain',
            source_language_code: source,
            target_language_code: target
          )

          response.translations.each do |translation|
            text_chunks_create(translation.translated_text, text_chunk)
            self.translated_text += translation.translated_text
          end
        rescue Google::Cloud::ResourceExhaustedError => e
          sleep(30) # if (ind != text_chunks.size - 1)
          retry
        end
      end

      return true
    rescue Google::Cloud::InvalidArgumentError => e
      puts(e)

      return false
    end

    return false
  end

  private

  def different_target_source_language
    return unless source == target

    errors.add(:target, :same_language)
  end

  def text_chunks_create(translation, original)
    translation_chunks = translation.split(/\n+/)
    original_chunks = original.split(/\n+/)
    begin
      doc_pairs = [original_chunks, translation_chunks].transpose
    rescue IndexError
      chunk = TextChunk.create(original: original, translated: translation, document: self, order: text_chunks.count + 1)
      AdminMailer.with(text_chunk_id: chunk.id).text_chunk_error.deliver_later
    else
      doc_pairs.each do |p|
        TextChunk.create(original: p.first, translated: p.last, document: self, order: text_chunks.count + 1)
      end
    end
  end

  def model_id
    trained_models = {
      en_pt: "TRL4243290249494528000",
      pt_en: "TRL5509364694739058688"
    }

    trained_models[from_to_language.to_sym]
  end

  def broadcast_update
    broadcast_replace_to :documents, target: "document-show-#{id}", locals: { document: self, chunks: text_chunks, user: Current.user }
    broadcast_replace_to :documents, target: "document-status-#{id}", partial: "documents/document_row_status", locals: { document: self }
  end
end
