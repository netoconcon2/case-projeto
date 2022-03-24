class DocumentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all.order(updated_at: :desc)
      elsif user.manager?
        scope.where(company: user.company).order(updated_at: :desc)
      else
        scope.where(user: user).order(updated_at: :desc)
      end
    end
  end

  def index?
    user.admin? || user.company.validated? || user.company.completed?
  end

  def show?
    # everyone from the company can see the show page
    access_to_plan? && authorized_person?
  end

  def create?
    # employees/managers can create if they have an active plan
    user.company&.plan?
  end

  def update?
    # only the creator or the company's manager can update it
    from_company? && authorized_person?
  end

  def translate?
    # only the creator or the company's manager can translate the
    # document, and only if there's an active plan for the company
    access_to_plan? && authorized_person?
  end

  def destroy?
    # only the creator or the company's manager can destroy it
    from_company? && manager_or_owner?
  end

  def editor?
    # only employees/managers can create, if they have an active plan
    (from_company? && authorized_person? && record.translated?) || (admin? && record.being_reviewed?)
  end

  def export?
    # only the creator or the company's manager can export it
    from_company? && authorized_person?
  end

  def export_original?
    # only the creator or the company's manager can export it
    from_company? && authorized_person?
  end

  def export_bicolumn?
    # only the creator or the company's manager can export it
    from_company? && authorized_person?
  end

  def export_rich_text?
    # only the creator or the company's manager can export it
    from_company? && authorized_person?
  end

  def select_glossaries?
    # only the creator or the company's manager can select glossaries and only
    # if the text has already been translated
    from_company? && authorized_person? && record.translated_text?
  end

  private

  def authorized_person?
    user.admin? || (user.manager? || record.user == user)
  end

  def manager_or_owner?
    user.admin? || (user.manager? || record.user == user)
  end

  def from_company?
    user.admin? || (user.company == record.company)
  end

  def access_to_plan?
    user.admin? || (from_company? && (user.company.plan? || user.company.available_words.positive?))
  end
end
