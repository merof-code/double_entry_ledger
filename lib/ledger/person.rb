# typed: true
# frozen_string_literal: true

class Ledger::Person < ActiveRecord::Base
  belongs_to :personable, polymorphic: true, required: true
  has_many :person_account_balances, class_name: "Ledger::PersonAccountBalance", foreign_key: "ledger_person_id",
                                     inverse_of: :ledger_person
  has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_person_id", inverse_of: :ledger_person
end
