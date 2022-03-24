class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  def home
    @user = User.new
    if user_signed_in?
      get_admin_dash_infos if current_user.admin?
      get_company_dash_infos if current_user.company
      render 'pages/dashboard', page: "dashboard"
    end
  end

  private

  def get_admin_dash_infos
    @apply_number = Company.where(status: "review").count
    @revisions_number = Document.being_reviewed.count
  end

  def get_company_dash_infos
    @company = current_user.company
    docs = @company.documents
    original_docs    = docs.original.count
    translating_docs = docs.being_translated.count
    reviewing_docs   = docs.being_reviewed.count
    translated_docs  = docs.translated.count
    @doc_counts = [original_docs, translating_docs, reviewing_docs, translated_docs]

    docs_per_user = docs.group_by{ |doc| doc.user }.map{ |user, docs| [user.name, docs.size]}
    @users_names = docs_per_user.map(&:first)
    @n_docs_per_user = docs_per_user.map(&:last)

    @words_to_translate = docs.original.sum{ |doc| doc.original_text.split.size }
  end
end
