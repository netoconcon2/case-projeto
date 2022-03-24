class Term < ApplicationRecord
  belongs_to :glossary

  validates :source, :target, presence: true

  has_paper_trail only: %i[source target],
                  on: %i[update create]
end
