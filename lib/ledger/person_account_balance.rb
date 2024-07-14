# typed: true

class Ledger::PersonAccountBalance < ActiveRecord::Base
  belongs_to :person, class_name: "Ledger::Person", foreign_key: "ledger_person_id",
                      inverse_of: :person_account_balances, required: true
  belongs_to :account, class_name: "Ledger::Account", foreign_key: "ledger_account_id",
                       inverse_of: :person_account_balances, required: true

  before_validation :set_date_to_first_day_of_month
  validates :date, presence: true,
                   uniqueness: { scope: %i[ledger_account_id ledger_person_id], message: "should be unique within the scope of ledger account and person" }
  validate :date_cannot_be_earlier_than_last

  monetize :balance_cents, as: :balance, with_model_currency: :balance_currency

  private

  def set_date_to_first_day_of_month
    self.date = date.beginning_of_month if date.present?
  end

  def date_cannot_be_earlier_than_last
    last_balance = Ledger::PersonAccountBalance.where(ledger_account_id:,
                                                      ledger_person_id:).order(date: :desc).first
    return unless last_balance && date < last_balance.date

    errors.add(:date, "cannot be earlier than the last entry's date within the same ledger account and person")
  end
end
