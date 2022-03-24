class Glossary < ApplicationRecord
  include PgSearch::Model

  attr_accessor :has_header, :xlsx

  has_many :terms, dependent: :destroy
  belongs_to :company, optional: true
  has_many :document_glossaries, dependent: :destroy
  has_many :documents, through: :document_glossaries

  paginates_per 10

  validates :name, :language_1, :language_2, presence: true
  validates :language_1, :language_2, inclusion: { in: LANGUAGES }
  validate :languages_diff

  pg_search_scope :search_by_text,
                  against: { name: 'A' },
                  using: {
                    trigram: {},
                    tsearch: { prefix: true, any_word: true }
                  }

  private

  def languages_diff
    return unless language_1 && language_2 && language_1 == language_2

    errors.add(:language_2, :languages_should_be_different)
  end
end
