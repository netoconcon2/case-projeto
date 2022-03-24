module NavbarHelper
  def admin_links
    link_to(admin_plans_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.manage_plans') }) do
      "#{inline_svg_tag('plan.svg', aria_hidden: true)}
      <p>#{t('.manage_plans')}</p>".html_safe
    end +
      link_to(admin_packages_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.manage_packages') }) do
        "#{inline_svg_tag('add.svg', aria_hidden: true)}
        <p>#{t('.manage_packages')}</p>".html_safe
      end +
      link_to(admin_companies_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.manage_companies') }) do
        "#{inline_svg_tag('company.svg', aria_hidden: true)}
        <p>#{t('.manage_companies')}</p>".html_safe
      end +
      link_to(admin_applies_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.applies') }) do
        "#{inline_svg_tag('apply.svg', aria_hidden: true)}
        <p>#{t('.applies')}</p>".html_safe
      end +
      link_to(admin_users_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.manage_users') }) do
        "#{inline_svg_tag('users.svg', aria_hidden: true)}
        <p>#{t('.manage_users')}</p>".html_safe
      end
  end

  def access_company_links
    links = if policy(current_user).special_access?
              link_to(plans_path, class: "dash-nav-item f-column f-center", id: 'navbar-plans', data: { tippy_content: t('.plans') }) do
                "#{inline_svg_tag('presentation.svg', aria_hidden: true)}
                <p>#{t('.plans')}</p>".html_safe
              end +
                link_to(packages_path, class: "dash-nav-item f-column f-center",  id: 'navbar-packages', data: { tippy_content: t('.additional_package') }) do
                  "#{inline_svg_tag('add.svg', aria_hidden: true)}
                  <p>#{t('.additional_package')}</p>".html_safe
                end
            end
    if policy(current_user.company).show?
      links += link_to(company_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.company') }) do
        "#{inline_svg_tag('company.svg', aria_hidden: true)}
        <p>#{t('.company')}</p>".html_safe
      end
    end
    links
  end

  def documents_link
    link_to(documents_path, class: "dash-nav-item f-column f-center", id: 'navbar-documents', data: { tippy_content: t('.documents') }) do
      "#{inline_svg_tag('document.svg', aria_hidden: true)}
      <p>#{t('.documents')}</p>".html_safe
    end
  end

  def glossaries_link
    link_to(glossaries_path, class: 'dash-nav-item f-column f-center', data: { tippy_content: t('.glossaries') }) do
      "#{image_tag('glossary.png', aria_hidden: true)}
      <p>#{t('.glossaries')}</p>".html_safe
    end
  end

  def register_company_link
    link_to(new_company_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.register_company') }) do
      "#{inline_svg_tag('company.svg', aria_hidden: true)}
      <p>#{t('.register_company')}</p>".html_safe
    end
  end

  def company_link
    return unless policy(current_user.company).show?

    link_to(company_path, class: "dash-nav-item f-column f-center", data: { tippy_content: t('.company') }) do
      "#{inline_svg_tag('company.svg', aria_hidden: true)}
      <p>#{t('.company')}</p>".html_safe
    end
  end

  def plans_packages_links
    link_to(plans_path, class: "dash-nav-item f-column f-center", id: 'navbar-plans', data: { tippy_content: t('.see_plans') }) do
        "#{inline_svg_tag('plan.svg', aria_hidden: true)}
        <p>#{current_user.company ? t('.plans') : t('.see_plans')}</p>".html_safe
      end +
      link_to(packages_path, class: "dash-nav-item f-column f-center", id: 'navbar-packages', data: { tippy_content: t('.see_packages') }) do
        "#{inline_svg_tag('add.svg', aria_hidden: true)}
        <p>#{current_user.company ? t('.additional_package') : t('.see_packages')}</p>".html_safe
      end
  end

  def navbar_links
    case
    # ADMIN LINKS
    when current_user.admin?
      documents_link + glossaries_link + admin_links
    # MANAGER WITHOUT COMPANY LINKS
    when !current_user.company
      register_company_link + plans_packages_links
    # MANAGER COMPANY IN REVIEW (NOT VALIDATED YET) LINKS
    when current_user.company.review?
      plans_packages_links + company_link
    # MANAGER AND PJ LINKS
    when policy(current_user).special_access?
      documents_link + glossaries_link + plans_packages_links + company_link
    # EMPLOYEE LINKS
    when current_user.company.completed? || current_user.company.validated?
      documents_link + glossaries_link
    end
  end
end
