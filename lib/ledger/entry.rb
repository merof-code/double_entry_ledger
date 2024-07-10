# typed: true

class Ledger::Entry < ActiveRecord::Base
  belongs_to :ledger_transfer, class_name: "Ledger::Transfer", foreign_key: "ledger_transfer_id",
                               inverse_of: :ledger_entries, required: true
  belongs_to :ledger_account, class_name: "Ledger::Account", foreign_key: "ledger_account_id",
                              inverse_of: :ledger_entries, required: true
  belongs_to :ledger_person, class_name: "Ledger::Person", foreign_key: "ledger_person_id", inverse_of: :entries,
                             required: true

  validates :ledger_transfer_id, presence: true
  validates :ledger_account_id, presence: true
  validates :ledger_person_id, presence: true
  validates :is_debit, inclusion: { in: [true, false] }
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount_currency, presence: true, length: { is: 3 }

  monetize :amount
  # TODO: check if Monetize will work in model. if it is needed at all
  # TODO: add person, add cost center
end
