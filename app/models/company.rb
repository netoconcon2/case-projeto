class Company < ApplicationRecord
  include TranslateEnum
  include PgSearch::Model
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  belongs_to :plan, optional: true
  has_many :users, dependent: :nullify
  has_many :documents, dependent: :destroy
  has_many :glossaries, dependent: :destroy
  has_many :transactions

  paginates_per 10

  after_create :update_owner
  before_destroy :delete_employees, prepend: true

  validate  :owner_must_have_right_role, :owner_must_belong_to_company
  validates :name, :owner, presence: true
  validates :name, uniqueness: true
  # validates :plan, presence: { message: :plan_blank }, if: :completed?
  validates :available_words, numericality: { greater_than_or_equal_to: 0 }
  validates :cnpj,
            :street,
            :street_number,
            :zip_code,
            :neighborhood,
            :phone,
            :country,
            :city,
            :state,
            presence: true, if: :company?
  validates :cnpj,
            :street,
            :street_number,
            :street_line_2,
            :zip_code,
            :neighborhood,
            :phone,
            :country,
            :city,
            :state,
            absence: true, if: :pj?
  validates :cnpj, length: { in: 14..18 }, format: { with: /\A\d{2}\.?\d{3}\.?\d{3}\/?\d{4}-?\d{2}\z/, message: :bad_format }, if: :company?

  enum status: {
    review: 0,
    validated: 1,
    completed: 2,
    denied: 3
  }
  translate_enum :status

  enum plan_status: {
    active: "active",
    pending: "pending",
    unpaid: "unpaid",
    canceled: "canceled",
    ended: "ended",
    paid: "paid"
  }
  translate_enum :plan_status

  pg_search_scope :search_by_text,
                  against: { name: 'A', cnpj: 'B' },
                  associated_against: {
                    owner: { email: 'C' },
                    users: { email: 'D' }
                  },
                  using: {
                    trigram: {},
                    tsearch: { prefix: true, any_word: true }
                  }
  pg_search_scope :search_by_status,
                  against: :status,
                  using: {
                    tsearch: { any_word: true }
                  }

  def subscribe(plan)
    return if review?

    self.plan = plan
    update_available_words(plan.words)
    complete! if validated?
    save
  end

  def company?
    owner&.manager?
  end

  def pj?
    owner&.pj?
  end

  def plan?
    plan.present?
  end

  def review!
    update(status: 'review') if denied?
  end

  def validate!
    update(status: 'validated') if review?
  end

  def complete!
    update(status: 'completed') if validated?
  end

  def update_available_words(number)
    self.available_words += number
    save
  end

  def get_subscription_infos
    subscrition_id = self.pagarme_subscription_id.to_i
    subscription = PagarMe::Subscription.find_by_id(subscription_id)
    @plan_name = subscription["plan"]["name"]
    @plan_price = subscription["plan"]["amount"]
    @plan_day = subscription["plan"]["days"]
    @charges = subscription["charges"]
    @installments = subscription["installments"]

    @current_transaction = subscription["current_transaction"]
  end

  def check_if_already_updated?
    # TO CHECK IF THIS COMPANY HAD WORDS UPDATED IN THE CURRENT MONTH
    last_update = self.last_words_updated
    current_date = Date.today

    (last_update <= current_date && last_update.month != current_date.month)
  end

  def check_subscription_status?
    subscription_id = self.subscription_id.to_i
    subscription = PagarMe::Subscription.find_by_id(subscription_id)
    status = subscription["status"]
    current_month = Date.today.month
    charge_date = subscription["current_transaction"]["date_updated"]

    (charge_date.month == current_month && status == "paid")
  end

  def perform_plan_scope_job
    # EXECUTE PLAN SCOPE JOB
    PlanScopeJob.perform_later(self.id)
  end

  private

  def owner_must_have_right_role
    return unless owner && !owner.manager? && !owner.pj?

    errors.add(:owner, :not_right_role)
  end

  def owner_must_belong_to_company
    return unless owner && owner.company.present? && owner.company != self

    errors.add(:owner, :must_belong_to_the_same_company)
  end

  def delete_employees
    users.where.not(id: owner.id).destroy_all
  end

  def update_owner
    owner.update(company: self)
  end
end
