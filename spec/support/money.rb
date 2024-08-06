# frozen_string_literal: true

Money.locale_backend = :currency

Money.locale_backend = :i18n
Money.default_currency = Money::Currency.new("USD")
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
