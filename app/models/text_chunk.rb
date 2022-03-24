class TextChunk < ApplicationRecord
  include TranslateEnum

  # callbacks
  before_validation :set_rich_translated, on: :create
  before_update :update_translated, :set_edited
  after_save    :doc_translated

  has_paper_trail if: proc { |t| t.saved_change_to_status? && t.saved_change_to_translated? && !t.repeated_translated_value? },
                  only: %i[status translated],
                  on: %i[update create]

  belongs_to :document
  belongs_to :responsible, class_name: 'User', optional: true

  enum status: {
    approved: 0,
    reviewed: 1, # This status will not be used anymore (reviewer feature was cancelled)
    translated: 2,
    edited: 3
  }
  translate_enum :status

  validates :original, :translated, :order, presence: true
  validates :rich_translated, presence: true, on: :create
  validates :rich_translated, format: { with: /\A<(div|h1|h2|h3)>.+<\/(div|h1|h2|h3)>\z/ }
  validates :order, uniqueness: { scope: :document }, numericality: { greater_than: 0 }
  validate :responsible_user

  def repeated_translated_value?
    return false if versions.length.zero?

    versions.map { |v| v.event == "create" ? v.changeset["translated"][1] : v.reify.translated }.include?(translated_before_last_save)
  end

  def need_review?
    translated? || edited?
  end

  private

  def doc_translated
    return unless approved? && !document.translated? && document.text_chunks.where.not(status: 0).count.zero?

    document.translated_text = ""
    document.text_chunks.order(order: :asc).each { |chunk| document.translated_text += "#{chunk.translated}\n" }
    document.translated!
  end

  def update_translated
    return unless rich_translated && rich_translated_changed?

    self.translated = Nokogiri::HTML(rich_translated).text
  end

  def set_edited
    return unless rich_translated_changed? && !status_changed? && !edited?

    self.status = 3
  end

  def set_rich_translated
    return unless translated

    self.rich_translated = "<div>#{translated}</div>"
  end

  def responsible_user
    return if responsible.nil? || responsible.admin? || responsible == document.user || (responsible.manager? && responsible.company == document.company)

    errors.add(:responsible, :wrong_role)
  end
end
