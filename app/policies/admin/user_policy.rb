class Admin::UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where.not(admin: true).order(created_at: :desc)
    end
  end
end
