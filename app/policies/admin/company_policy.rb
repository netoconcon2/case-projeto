class Admin::CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where.not(status: 0)
    end
  end
end
