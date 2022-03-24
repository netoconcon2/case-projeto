class DocumentGlossary < ApplicationRecord
  belongs_to :document
  belongs_to :glossary

  validates :document, uniqueness: { scope: :glossary }
end
