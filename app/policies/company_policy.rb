class CompanyPolicy < ApplicationPolicy
  ## for company show
  class Scope < Scope
    def resolve
      scope.where(company: user.company).where.not(id: user.id)
    end
  end

  def show?
    not_ready? ? user.owner? : user.manager?
  end

  def update?
    (owner? && user.company == record && !user.pj?) || admin?
  end

  def destroy?
    user.admin?
  end

  def subscribe?
    !record.review? && owner?
  end

  def cancel_plan?
    user.admin?
  end

  # if works for the company, user's authorized
  def employee?
    user.company == record
  end

  # if user is a manager and does not have a company
  # or if user is an admin, user's authorized to
  # create a company
  def create?
    (user.manager? && user.company.nil?) || user.admin?
  end

  # check if the user is the manager of the company
  def manager?
    user.manager? && user.company == record
  end

  def finance?
    user.company.present? && special_access? && record == user.company
  end

  def not_ready?
    record.review? || record.denied?
  end
end
