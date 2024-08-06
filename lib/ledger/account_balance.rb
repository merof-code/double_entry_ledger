# frozen_string_literal: true
# typed: true

module Ledger
  # Holds account balances for Person for a specific account from chart of accounts
  # at a specific date - accounting period
  # TODO: use the way plutus provides tenancy support.
  # Or better, make the user use person class and make it tenant, but the transfer will need to have tenant, as well as
  # entries
  class AccountBalance < ActiveRecord::Base
    include Comparable # read Locking::Lock#initialize
    extend T::Sig
    belongs_to :person, class_name: "Ledger::Person", foreign_key: "ledger_person_id",
                        inverse_of: :account_balances, required: true
    belongs_to :account, class_name: "Ledger::Account", foreign_key: "ledger_account_id",
                         inverse_of: :account_balances, required: true

    before_validation :set_date_to_first_day_of_month

    validates :date, presence: true,
                     uniqueness: { scope: %i[ledger_account_id ledger_person_id balance_currency] }
    validate :date_cannot_be_earlier_than_last

    monetize :balance_cents, as: :balance, with_model_currency: :balance_currency, numericality: {
      greater_than_or_equal_to: 0
    }

    scope :for_person_and_account, lambda { |person, account|
      where(person:, account:)
    }

    def <=>(other)
      balance_cents <=> other.balance_cents
    end

    private

    # TODO: check that this is not a closed period or smth
    def set_date_to_first_day_of_month
      self.date = date.beginning_of_month if date.present?
    end

    def date_cannot_be_earlier_than_last
      last_balance = AccountBalance.where(ledger_account_id:,
                                          ledger_person_id:).order(date: :desc).first
      return unless last_balance && date < last_balance.date

      errors.add(:date, "cannot be earlier than the last entry's date within the same ledger account and person")
    end

    def to_s
      "id:#{id}@#{date} #{balance}#{balance.currency} for #{person.id}"
    end
  end
end
