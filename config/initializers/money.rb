MoneyRails.configure do |config|

  # set the default currency
  config.default_currency = :brl

  # Specify a rounding mode
  config.rounding_mode = BigDecimal::ROUND_HALF_UP

  config.locale_backend = :currency

  config.register_currency = {
      :id                  => :brl,
      :priority            => 1,
      :iso_code            => "BRL",
      :name                => "Real",
      :symbol              => "R$",
      :symbol_first        => true,
      :subunit             => "Cent",
      :subunit_to_unit     => 100,
      :thousands_separator => ".",
      :decimal_mark        => ","
  }
end
