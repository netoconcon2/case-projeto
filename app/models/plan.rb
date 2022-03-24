class Plan < ApplicationRecord
  include TranslateEnum
  has_many :companies, dependent: :nullify
  has_many :users, through: :companies
  # delegate :users, to: :companies, allow_nil: true

  enum status: {
    inactive: 0,  # not visible and not activated at pagarme
    active: 1,    # not visible but activated at pagarme
    published: 2, # visible and activated at pagarme
    discarded: 3  # not visible, activated at pagarme but discarded
  }

  translate_enum :status

  validates :words, presence: true
  validates :name, presence: true

  monetize :price, as: :price_cents

  validates :price, numericality: { greater_than: 1 }
  validates :words, :days, numericality: { greater_than: 0 }

  validates :pagarme_id, absence: { message: :not_inactive_plan }, if: :inactive?
  validates :pagarme_id, presence: { message: :inactive_plan }, unless: :inactive?

  def set_pagarme_plan
    # Create a Plan in Pagarme's DB

    plan = PagarMe::Plan.new(
      {
        name: name,
        days: days,
        installments: installments,
        amount: price_cents.to_i,
        payment_methods: 'credit_and_boleto'
      }
    )

    plan.create # this is a pagarme method

    self.pagarme_id = plan.id
    active!

    # raise "There was an error creating the plan" unless plan.id
  end
end
