# typed: true
# frozen_string_literal: true

class Ledger::Person < ActiveRecord::Base
  belongs_to :personable, polymorphic: true, required: true
  has_many :account_balances, class_name: "Ledger::AccountBalance", foreign_key: "ledger_person_id",
                              inverse_of: :person
  has_many :entries, class_name: "Ledger::Entry", foreign_key: "ledger_person_id", inverse_of: :person
end
