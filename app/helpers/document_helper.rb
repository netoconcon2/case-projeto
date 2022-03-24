module DocumentHelper
  def render_show_by_status(document, chunks, user)
    case document.status
    when 'original'
      if user.admin?
        # Admin should be able to read the text, but not use the translate form
        render 'documents/document_texts' do
          render 'documents/original_text_field', document: document
        end
      else
        render 'documents/translate_form', document: document, user: user
      end
    when 'being_translated', 'being_reviewed'
      render 'documents/document_texts' do
        render 'documents/original_text_field', document: document
      end
    when 'translated'
      render 'documents/document_texts' do
        (render 'documents/original_text_field', document: document) + (render 'documents/translation_text_field', document: document, chunks: chunks)
      end
    end
  end

  def document_status_icons
    {
      'original' => 'fas fa-exclamation-triangle text-danger me-1',
      'being_translated' => 'far fa-clock text-warning me-1',
      'being_reviewed' => 'fas fa-spell-check text-warning me-1',
      'translated' => 'fas fa-check text-success me-1'
    }
  end

  def index_action_buttons(document, user)
    button_see(document, user) + button_edit(document, user) + button_destroy(document, user)
  end

  private

  def button_see(document, user)
    # Same as policy(document).show?
    return unless access_to_plan?(document, user) && authorized_person?(document, user)

    link_to(document, data: { tippy_content: t('documents.index.see_document') }) do
      (tag.i class: %w[fas fa-eye mx-1]) +
        (tag.span class: %w[visibility-hidden] do
          t('documents.index.see_document')
        end)
    end
  end

  def button_edit(document, user)
    # Same as policy(document).update?
    return unless from_company?(document, user) && manager_or_owner?(document, user)

    link_to(edit_document_path(document), data: { turbo_frame: 'modal', turbo: true, tippy_content: t('documents.index.edit_document') }) do
      (tag.i class: %w[fas fa-pen mx-1]) +
        (tag.span class: %w[visibility-hidden] do
          t('documents.index.edit_document')
        end)
    end
  end

  def button_destroy(document, user)
    # Same as policy(document).destroy?
    return unless from_company?(document, user) && manager_or_owner?(document, user)

    link_to(document, method: :delete, data: { confirm: t('alert.are_you_sure'), turbo: true, tippy_content: t('documents.index.delete_document') }) do
      (tag.i class: %w[fas fa-trash mx-1]) +
        (tag.span class: %w[visibility-hidden] do
          t('documents.index.delete_document')
        end)
    end
  end

  def button_editor(document, user)
    # Same as policy(document).editor?
    return unless (from_company?(document, user) && authorized_person?(document, user) && document.translated?) || (admin?(user) && document.being_reviewed?)

    link_to(document_editor_path(document), data: { tippy_content: t('documents.index.editor_document') }) do
      (tag.i class: %w[fas fa-edit mx-1]) +
        (tag.span class: %w[visibility-hidden] do
          t('documents.index.editor_document')
        end)
    end
  end

  def authorized_person?(document, user)
    user.admin? || (user.manager? || document.user == user)
  end

  def manager_or_owner?(document, user)
    user.admin? || (user.manager? || document.user == user)
  end

  def from_company?(document, user)
    user.admin? || (user.company == document.company)
  end

  def access_to_plan?(document, user)
    user.admin? || (from_company?(document, user) && user.company.plan?)
  end
end
