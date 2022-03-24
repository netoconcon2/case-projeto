module SelectHelper
  def states_list
    %w(AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO)
  end

  def month_number_list
    %w(01 02 03 04 05 06 07 08 09 10 11 12)
  end

  def year_list
    %w(21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41)
  end

  def language_pairs
    Document::POSSIBLE_LANGUAGE_PAIRS.to_h do |pair|
      pair_languages = pair.split("_")
      pair_label = "#{pair_languages[0].capitalize} -> #{pair_languages[1].capitalize}"
      [pair_label, pair]
    end
  end
end
