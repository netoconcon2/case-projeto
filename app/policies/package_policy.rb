class PackagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(status: "visible")
    end
  end

  def not_published?
    admin? && record.invisible?
  end

  def checkout?
    user.company.completed?
  end
end
