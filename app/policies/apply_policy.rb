class ApplyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(status: [0, 3])
    end
  end
end
