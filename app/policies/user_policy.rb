class UserPolicy < ApplicationPolicy
  def update?
    record == user || user.admin?
  end

  def destroy?
    user.admin?
  end
end
