class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def admin?
    user.admin?
  end

  def admin_or_doc_authorized?
    admin? || doc_autorized?
  end

  def owner?
    user.owner?
  end

  def company?
    !user.company.nil?
  end

  def doc_autorized?
    record.document.user == user || (record.document.company == user.company && user.manager?)
  end

  def plan?
    special_access? && (user.admin? || user.company&.plan?)
  end

  def special_access?
    user.manager? || user.owner? || user.admin?
  end

  def validated?
    special_access? && (user.admin? || user.company.validated? || user.company.completed?)
  end

  def validated_not_pj?
    validated? && !user.pj?
  end

  # ---------------------------- STANDARD BEHAVIOUR ----------------------------

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # ---------------------------------- SCOPE -----------------------------------
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
