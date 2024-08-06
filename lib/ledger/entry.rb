# frozen_string_literal: true
# typed: true

# The main point of the entire gem, double entries, it should theoretically be not touched by user nor edited, at all
class Ledger::Entry < ActiveRecord::Base
  belongs_to :transfer, class_name: "Ledger::Transfer", foreign_key: "ledger_transfer_id", inverse_of: :entries,
                        required: true
  belongs_to :account, class_name: "Ledger::Account", foreign_key: "ledger_account_id", inverse_of: :entries,
                       required: true
  belongs_to :person, class_name: "Ledger::Person", foreign_key: "ledger_person_id", inverse_of: :entries,
                      optional: true

  validates :is_debit, inclusion: { in: [true, false] }
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true, length: { is: 3 }

  monetize :amount_cents, as: :amount, with_model_currency: :amount_currency

  def debit!
    self.is_debit = true
    save!
  end
end
