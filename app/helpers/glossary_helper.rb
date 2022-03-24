module GlossaryHelper
  def language_select_options
    Glossary::LANGUAGES.map do |language|
      [t("languages.#{language}"), language]
    end
  end

  def languages(glossary)
    "#{t("languages.#{glossary.language_1}")}, #{t("languages.#{glossary.language_2}")}"
  end
end
