class DocumentGlossaryPolicy < ApplicationPolicy
  def create?
    authorized_person? && document_from_company? && glossary_from_company?
  end

  private

  def authorized_person?
    user.admin? || (user.manager? || record.document.user == user)
  end

  def document_from_company?
    user.admin? || (user.company == record.document.company)
  end

  def glossary_from_company?
    user.admin? || (user.company == record.glossary.company)
  end
end
