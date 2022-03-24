class PlanPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(status: 2)
    end
  end

  def subscribe?
    user.company.completed?
  end
end
