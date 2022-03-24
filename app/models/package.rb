class Package < ApplicationRecord
  include TranslateEnum
  monetize :price_cents, allow_nil: true

  validates :price, :words, :status, :name, presence: true
  validates :price, numericality: { greater_than: 1 }
  validates :words, numericality: { greater_than: 0 }

  enum status: {
    invisible: 0, # When this extra package is available to use
    visible: 1 # When just been created and not actived yet
  }

  translate_enum :status
end
