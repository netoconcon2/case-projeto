class GlossaryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all.order('lower(name)')
      else
        scope.where(company: user.company).order('lower(name)')
      end
    end
  end

  def index?
    # only admins or users from validated or completed companies
    admin? || validated_company?
  end

  def new?
    # only admins or users from validated or completed companies
    admin? || validated_company?
  end

  def create?
    # only admins or users from validated or completed companies
    admin? || validated_company?
  end

  def show?
    # only admins and users from the glossary's company can see
    admin? || (from_company? && validated_company?)
  end

  def edit?
    # only admins and users from the glossary's company can edit page
    admin? || (from_company? && validated_company?)
  end

  def update?
    # only admins and users from the glossary's company can update it
    admin? || (from_company? && validated_company?)
  end

  def destroy?
    # only admins and users from the glossary's company can destroy it
    admin? || (from_company? && validated_company?)
  end

  def import_terms?
    # only admins and users from the glossary's company can import terms
    admin? || (from_company? && validated_company?)
  end

  def create_terms?
    # only admins and users from the glossary's company can import terms
    admin? || (from_company? && validated_company?)
  end

  private

  def authorized_person?
    user.admin? || (user.manager? || record.user == user)
  end

  def from_company?
    user.admin? || (user.company == record.company)
  end

  def validated_company?
    company? && (user.company.validated? || user.company.completed?)
  end
end
