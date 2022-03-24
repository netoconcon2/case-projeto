class User < ApplicationRecord
  include TranslateEnum
  include PgSearch::Model

  before_create :set_role
  after_create :create_pj_company

  belongs_to :company, optional: true
  has_many :invitations, class_name: 'User', as: :invited_by
  has_many :documents, dependent: :destroy
  has_many :text_chunks, foreign_key: 'responsible_id'
  has_many :docs_for_review, -> { distinct }, through: :text_chunks, source: :document
  has_many :glossaries, as: :glossary
  has_one :owned_company, class_name: 'Company', foreign_key: 'user_id', dependent: :destroy
  paginates_per 10

  enum role: {
    manager: 1, # company owner CREATED
    pj: 2, # liberal CREATED
    employee: 3 # funcionario da empresa INVITED
  }
  translate_enum :role
  attribute :which_role, :integer
  User.roles.each_key { |role| define_method("#{role}?") { self.role == role && !admin } }

  validate :company_from_pj_user_allows_only_one_user, :pj_user_cannot_enter_in_companies
  validates :first_name, :last_name, presence: true
  validates :role, presence: true, unless: :which_role
  validates :which_role, inclusion: { in: [1, 2, 3] }, on: :create, if: ->(user) { user.role.nil? }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  pg_search_scope :search_by_text,
                  against: { email: 'A' },
                  associated_against: {
                    company: { name: 'B' }
                  },
                  using: {
                    trigram: {},
                    tsearch: { prefix: true, any_word: true }
                  }
  pg_search_scope :search_by_role,
                  against: :role,
                  using: {
                    tsearch: { any_word: true }
                  }

  def owner?
    company&.owner == self
  end

  def name
    "#{first_name} #{last_name}"
  end

  def create_pj_company
    return unless pj?

    company = Company.create(name: "#{email} Company", status: 1, owner: self)
    self.company = company
    save
  end

  private

  def set_role
    return unless role.nil?

    self.role = which_role
  end

  def company_from_pj_user_allows_only_one_user
    return unless company&.owner&.pj? && company.owner != self && company.users.size >= 1

    errors.add(:company, :more_than_one_user)
  end

  def pj_user_cannot_enter_in_companies
    return unless pj? && company && company.owner != self && company.users.size >= 1

    errors.add(:company, :pj_cannot_belong)
  end
end
