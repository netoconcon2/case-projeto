class TermPolicy < ApplicationPolicy
  def new?
    # only admins or users from validated or completed companies
    admin? || (from_company? && validated_company?)
  end

  def editor_new?
    # only admins or users from validated or completed companies
    admin? || validated_company?
  end

  def create?
    # only admins or users from validated or completed companies
    admin? || (from_company? && validated_company?)
  end

  def editor_create?
    # only admins or users from validated or completed companies
    admin? || (from_company? && validated_company?)
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

  private

  def from_company?
    user.company == record.glossary.company
  end

  def validated_company?
    company? && (user.company.validated? || user.company.completed?)
  end
end
