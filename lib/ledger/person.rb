# typed: true
# frozen_string_literal: true

# TODO: make option to connect users person class
# A polymorph association to the records
class Ledger::Person < ActiveRecord::Base
  has_many :transfers, through: :entries, source: :ledger_transfer
  has_many :documents, through: :transfers, source: :ledger_document
  belongs_to :personable, polymorphic: true, required: true
  has_many :account_balances, class_name: "Ledger::AccountBalance", foreign_key: "person_id",
                              inverse_of: :person
  has_many :entries, class_name: "Ledger::Entry", foreign_key: "person_id", inverse_of: :person
end
